"""Magika file-type classifier for the Agilex 5 E-Series modular JTAG board.

This is external/spatial_examples/magika/magika_spatial.py resized to fit the
846 DSP / 1611 M20K / 222.4k ALM budget of agx5e_modular_spatial_jtag. 

The four things that were resized:

1. The four Conv_0 branches are fused into one 256->512 convolution.

2. num_lanes was reduced to 4.

3. The LayerNorm_0 scale/bias ROMs hold num_lanes copies and repeated.

4. The two 512-packet buffers inside NORMALIZATION ask for 511 packets.
   scfifo rounds its depth up to a power of two, and 512 packets plus the
   pipeline-latency margin lands one entry past 32768, doubling the RAM.
   Asking for 511 lands exactly on 32768. See NORMALIZATION for the capacity
   argument that makes this safe.
"""

import argparse
import os
from pathlib import Path

import numpy as np
import onnx
import onnxruntime as rt
from fpga_ai_suite.spatial import operations as op
from fpga_ai_suite.spatial.flow import run_flow
from fpga_ai_suite.spatial.layers import (Accumulator, Activation, Add,
                                          Add_bias, Argmax, Buffer, Conv2d,
                                          Convert_lanes,
                                          Directed_acyclic_graph, Dot,
                                          Multiply, Multiply_bias, Normalize,
                                          Repeater, Rescaling, Reshape, Rom,
                                          Rom_gather, Softmax, Sub, config)
from fpga_ai_suite.spatial.layers.model_saver import save_model
from magika import Magika
from magika.types import Seekable

# The board this is sized for.
DEVICE_FAMILY = "Agilex 5"
AGX5_DSP = 846
AGX5_M20K = 1611
AGX5_ALM = 222_400

# LayerNorm_0 normalizes across the 512 rows of the (512, 256) activation, so a
# whole frame has to be held while the sums are collected.
NORM_PACKETS = 512

# scfifo rounds up to a power of two and the buffer adds a latency margin on top
# of what it is asked for, so 512 would size the RAM for 1024 packets.
NORM_BUFFER_PACKETS = NORM_PACKETS - 1


class NORMALIZATION(Directed_acyclic_graph):
    """LayerNorm_0: normalize each of the 256 columns over the 512 rows.

    The two Buffer layers hold a frame while the mean and the variance are
    reduced out of it. They are asked for NORM_BUFFER_PACKETS rather than the
    512 packets a frame contains: a Buffer stops accepting SUB_VECTORS +
    DIN_LATENCY entries before it is full, so 511 packets of nominal depth
    accept 510.6 packets, and the consuming Sub/Multiply holds another 6.6 in
    its own input FIFO. That is 517 packets of slack against the 512 that have
    to be absorbed before the accumulator can release the mean.
    """

    def __init__(self, num_lanes):
        self.num_lanes = num_lanes
        super().__init__(module_name="NORMALIZATION")

    def init_topology(self):
        self.input = self.create_input("din", 16, self.num_lanes, dtype="BF16")
        self.output = self.create_output("dout", 16, self.num_lanes, dtype="BF16")

        self.accumulator_41 = self.add_node(Accumulator(num_lanes=self.num_lanes, num_packets=NORM_PACKETS))
        self.rescaling_44 = self.add_node(Rescaling(num_lanes=self.num_lanes, scaling_factor=0.001953125))
        self.repeater_46 = self.add_node(Repeater(num_lanes=self.num_lanes, repeat=NORM_PACKETS))
        self.buffer_47 = self.add_node(Buffer(num_lanes=self.num_lanes, num_packets=NORM_BUFFER_PACKETS))
        self.sub_47 = self.add_node(Sub(num_lanes=self.num_lanes))
        self.multiply_51 = self.add_node(Multiply(num_lanes=self.num_lanes))
        self.accumulator_52 = self.add_node(Accumulator(num_lanes=self.num_lanes, num_packets=NORM_PACKETS))
        self.buffer_54 = self.add_node(Buffer(num_lanes=self.num_lanes, num_packets=NORM_BUFFER_PACKETS))
        self.rescaling_64 = self.add_node(Rescaling(num_lanes=self.num_lanes, scaling_factor=0.001953125, offset=9.999999974752427e-7))
        self.sqrt_70 = self.add_node(Activation(num_lanes=self.num_lanes, activation="squareroot"))
        self.reciprocal_71 = self.add_node(Activation(num_lanes=self.num_lanes, activation="reciprocal"))
        self.repeater_71 = self.add_node(Repeater(num_lanes=self.num_lanes, repeat=NORM_PACKETS))
        self.multiply_75 = self.add_node(Multiply(num_lanes=self.num_lanes))

    def forward(self, din):
        h = self.accumulator_41(din)
        h = self.rescaling_44(h)
        h = self.repeater_46(h)
        h_47 = self.buffer_47(din)
        h_47 = self.sub_47(h_47, h)
        h_buffer = self.buffer_54(h_47)
        h = self.multiply_51(h_47, h_47)
        h = self.accumulator_52(h)
        h = self.rescaling_64(h)
        h = self.sqrt_70(h)
        h = self.reciprocal_71(h)
        h = self.repeater_71(h)
        h = self.multiply_75(h_buffer, h)
        return (h,)


class MAGIKA(Directed_acyclic_graph):
    def __init__(self, magika_weights):
        self.num_lanes = 4
        # Conv_0 is the whole runtime. Its weight ROM costs the same at any lane
        # count, so widen the input side and leave the output side at the
        # pipeline width: the accumulator RAM is sized by the output lanes.
        self.conv_num_lanes_in = 32

        self.magika_weights = magika_weights
        super().__init__(module_name="MAGIKA")

    def _broadcast_rom(self, weights):
        """Lay out a per-row LayerNorm_0 scale/bias as a (512, 1, num_lanes) ROM.

        The ROM feeds a repeater that turns each row into the 256 copies the
        elementwise stage consumes, so the ROM itself only has to hold one
        packet worth of copies.
        """
        return weights.transpose(1, 0, 2).repeat(self.num_lanes, axis=2)

    def init_topology(self):

        self.input = self.create_input("din", 9, 1, dtype="UINT")
        self.output = self.create_output("dout", 16, 2, dtype="BF16")

        self.reshape_17 = self.add_node(Reshape(dw=9, num_lanes=1, output_shape=(2048, 1, 1), dtype="UINT"))

        weights_17 = self.magika_weights["jax2tf_get_logits_/Const:0"]
        self.rom_gather_17 = self.add_node(Rom_gather(weights=weights_17, num_lanes=self.num_lanes))

        weights_20 = self.magika_weights[
            "jax2tf_get_logits_/pjit_get_logits_/MagikaV2/Dense_0/Reshape:0"
        ].flatten()
        self.add_bias_20 = self.add_node(Add_bias(bias=weights_20, num_lanes=self.num_lanes))

        self.gelu_0 = self.add_node(Activation(num_lanes=self.num_lanes, activation="gelu"))
        self.reshape_39 = self.add_node(Reshape(output_shape=(512, 1, 256), num_lanes=self.num_lanes))
        self.NORMALIZATION_0 = self.add_node(NORMALIZATION(num_lanes=self.num_lanes))

        weights_220 = self._broadcast_rom(
            self.magika_weights[
                "jax2tf_get_logits_/pjit_get_logits_/MagikaV2/LayerNorm_0/Reshape_2:0"
            ]
        )

        self.rom_220 = self.add_node(Rom(weights=weights_220, num_lanes=self.num_lanes))
        self.repeater_220 = self.add_node(Repeater(repeat=256 // self.num_lanes, num_lanes=self.num_lanes))
        self.reshape_220 = self.add_node(Reshape(output_shape=(512, 1, 256), num_lanes=self.num_lanes))
        self.register_rom_dependency(
            rom=self.rom_220.node, pkt_src=self.NORMALIZATION_0.node.outputs.dout, pkt_multiplier=1
        )
        self.multiply_74 = self.add_node(Multiply(num_lanes=self.num_lanes))

        weights_221 = self._broadcast_rom(
            self.magika_weights[
                "jax2tf_get_logits_/pjit_get_logits_/MagikaV2/LayerNorm_0/Reshape_3:0"
            ]
        )
        self.rom_221 = self.add_node(Rom(weights=weights_221, num_lanes=self.num_lanes))
        self.repeater_221 = self.add_node(Repeater(repeat=256 // self.num_lanes, num_lanes=self.num_lanes))
        self.reshape_221 = self.add_node(Reshape(output_shape=(512, 1, 256), num_lanes=self.num_lanes))
        self.register_rom_dependency(
            rom=self.rom_221.node, pkt_src=self.NORMALIZATION_0.node.outputs.dout, pkt_multiplier=1
        )

        self.add_78 = self.add_node(Add(num_lanes=self.num_lanes))

        # PART 2

        self.convert_lanes_98 = self.add_node(
            Convert_lanes(num_lanes_in=self.num_lanes, num_lanes_out=self.conv_num_lanes_in)
        )

        weights_98 = self.magika_weights[
            "jax2tf_get_logits_/pjit_get_logits_/MagikaV2/Conv_0/transpose_3:0"
        ].transpose(2, 3, 1, 0)
        self.conv_98 = self.add_node(
            Conv2d(
                weights=weights_98,
                input_size=(512, 1),
                kernel_size=(5, 1),
                num_lanes_in=self.conv_num_lanes_in,
                num_lanes_out=self.num_lanes,
            )
        )

        # PART 3

        weights_107 = self.magika_weights["const_fold_opt__209"].flatten()
        self.add_bias_107 = self.add_node(Add_bias(bias=weights_107, num_lanes=self.num_lanes))

        self.gelu_1 = self.add_node(Activation(num_lanes=self.num_lanes, activation="gelu"))
        self.accumulator_126 = self.add_node(Accumulator(num_packets=508, operation="MAX", num_lanes=self.num_lanes))

        weights_161 = self.magika_weights[
            "jax2tf_get_logits_/pjit_get_logits_/MagikaV2/LayerNorm_1/Reshape_2:0"
        ].flatten()
        self.multiply_bias_161 = self.add_node(Multiply_bias(bias=weights_161, num_lanes=self.num_lanes))
        self.normalize = self.add_node(Normalize(epsilon=9.999999974752427e-7, num_lanes=self.num_lanes))

        weights_165 = self.magika_weights[
            "jax2tf_get_logits_/pjit_get_logits_/MagikaV2/LayerNorm_1/Reshape_3:0"
        ].flatten()
        self.add_bias_165 = self.add_node(Add_bias(bias=weights_165, num_lanes=self.num_lanes))

        weights_174 = self.magika_weights["jax2tf_get_logits_/Const_24:0"]
        self.dot_174 = self.add_node(Dot(weights=weights_174, num_lanes_in=self.num_lanes, num_lanes_out=2))

        weights_177 = self.magika_weights[
            "jax2tf_get_logits_/pjit_get_logits_/MagikaV2/Dense_1/Reshape:0"
        ].flatten()
        self.add_bias_177 = self.add_node(Add_bias(bias=weights_177, num_lanes=2))

        self.argmax_180 = self.add_node(Argmax(operation="MAX", num_lanes=2))
        self.repeater_183 = self.add_node(Repeater(num_lanes=1, repeat=214))
        self.reshape_183 = self.add_node(Reshape(output_shape=(1, 1, 214), num_lanes=1))
        self.convert_lanes_183 = self.add_node(Convert_lanes(num_lanes_in=1, num_lanes_out=2))
        self.sub_184 = self.add_node(Sub(num_lanes=2))
        self.final_softmax = self.add_node(Softmax(num_lanes=2))

    def forward(self, din):
        h = self.reshape_17(din)
        h = self.rom_gather_17(h)
        h = self.add_bias_20(h)
        h = self.gelu_0(h)
        h_39 = self.reshape_39(h)
        h_75 = self.NORMALIZATION_0(h_39)

        h = self.rom_220()
        h = self.repeater_220(h)
        h = self.reshape_220(h)
        h_74 = self.multiply_74(h_75, h)

        h = self.rom_221()
        h = self.repeater_221(h)
        h = self.reshape_221(h)
        h = self.add_78(h_74, h)

        # PART 2

        h = self.convert_lanes_98(h)
        h = self.conv_98(h)

        # PART 3

        h_107 = self.add_bias_107(h)
        h = self.gelu_1(h_107)
        h = self.accumulator_126(h)
        h = self.normalize(h)
        h = self.multiply_bias_161(h)
        h = self.add_bias_165(h)
        h = self.dot_174(h)
        h_177 = self.add_bias_177(h)

        (h, v) = self.argmax_180(h_177)
        h = self.repeater_183(h)
        h = self.reshape_183(h)
        h = self.convert_lanes_183(h)
        h = self.sub_184(h_177, h)
        h = self.final_softmax(h)

        return (h,)


def preprocess_input(input_data):
    # Converts input file to a byte array and extracts features using Magika's helper
    from io import BytesIO
    from pathlib import Path

    magika_helper = Magika()
    if isinstance(input_data, Path):
        with open(input_data, "rb") as f:
            file_bytes = f.read()
    else:
        file_bytes = input_data

    result, features = magika_helper._get_result_or_features_from_seekable(Seekable(BytesIO(file_bytes)))
    assert features is not None, "Feature extraction failed."
    assert 1024 == magika_helper._model_config.beg_size == magika_helper._model_config.end_size
    assert 0 == magika_helper._model_config.mid_size
    my_inputs = np.array(features.beg[:1024] + features.end[-1024:], dtype=np.int32).reshape(1, 1, 2048)
    return my_inputs


def evaluate_output(output_scores):
    # Postprocesses the output scores to get the predicted
    from magika import Magika

    magika_helper = Magika()
    predicted_label_index = np.argmax(output_scores)
    predicted_label = magika_helper._target_labels_space[predicted_label_index]
    return predicted_label


def report_fit(resources):
    print(resources)
    print(
        f"AGX5 budget: DSP {resources['DSP']}/{AGX5_DSP}, "
        f"M20K {resources['M20K']}/{AGX5_M20K}, ALM {resources['ALM']}/{AGX5_ALM}"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--sim", action="store_true")
    parser.add_argument("--compile", action="store_true")
    parser.add_argument("--save-model", action="store_true",
                        help="Serialize the model to saved_model/ without running emulation")
    parser.add_argument("--generate-pta", action="store_true",
                        help="Run model forward, dump RTL, and generate MAGIKA.pta (no sim or Quartus compile)")
    parser.add_argument("--file", type=str, default=None)
    parser.add_argument("--dump-input-only", action="store_true", help="Only generate din.txt in dump_files/ without running emulation")
    parser.add_argument("--evaluate-output-only", type=str, default=None,
                        help="Evaluate output from a hex file (e.g. dump_files/golden_dout.txt) and print the predicted class")
    parser.add_argument("--output-dir", type=str,
                        default=str(Path(__file__).resolve().parent / "saved_model"),
                        help="Directory for the saved model, RTL and dump files")
    parser.add_argument("--gcc-path", type=Path,
                        default=Path("/p/psg/ctools/gcc/13.2.0/1/linux64/suse15/bin/"),
                        help="GCC used by VCS for --sim; the default toolchain cannot link it")
    args = parser.parse_args()

    config.Config.update_config("device_family", DEVICE_FAMILY)

    # Borrow helper functions from actual Magika
    magika_helper = Magika()

    magika_original = onnx.load(magika_helper._model_path)
    magika_weights = {}
    for initializer in magika_original.graph.initializer:
        magika_weights[initializer.name] = onnx.numpy_helper.to_array(initializer)

    model = MAGIKA(magika_weights)

    if args.file is not None:
        input = Path(args.file)
    else:
        input = b'# -*- coding: utf-8 -*-\nprint("Hello World!")'  # python

    if args.evaluate_output_only:
        # Read hex values from the output file and evaluate the predicted class
        output_file = args.evaluate_output_only
        assert os.path.isfile(output_file), f"Output file not found: {output_file}"
        scores = []
        with open(output_file, "r") as f:
            for line in f:
                line = line.strip()
                if line:
                    scores.append(op.hex_to_float(line, 16))
        output_scores = np.array(scores)
        print(f"Read {len(scores)} values from {output_file}")
        print("Predicted class:", evaluate_output(output_scores))
        exit(0)

    my_inputs = preprocess_input(input)

    if args.generate_pta:
        model(din=my_inputs)
        model.update_params()
        ret = run_flow(
            model,
            generate_pta=True,
            sim=False,
            quartus_compile=False,
            validate_timing=False,
        )
        if ret != 0:
            raise RuntimeError(f"run_flow failed with exit code {ret}")
        exit(0)

    if args.dump_input_only:
        # Assign input data to the model's input port and dump only input files
        model.inputs["din"].data = my_inputs
        dump_path = "dump_files"
        if not os.path.isdir(dump_path):
            os.mkdir(dump_path)
        for in_port in model.inputs.ports():
            with open(os.path.join(dump_path, f"{in_port.name}{in_port.bus_index}.txt"), "w") as f:
                for value in np.nditer(in_port.data, order="C"):
                    if in_port.dtype == "INT" or in_port.dtype == "UINT":
                        f.write(f"{int(value) & ((1 << in_port.dw) - 1):x}\n")
                    else:
                        hex_value = op.get_upper_bits_hex(value, in_port.dw)
                        f.write(f"{hex_value}\n")
        print(f"Generated input files in {dump_path}/ ({np.size(my_inputs)} values)")
        exit(0)

    # get intermediate output

    onnx_session = rt.InferenceSession(
        magika_original.SerializeToString(),
        providers=["CPUExecutionProvider"],
    )
    expected = onnx_session.run(["target_label"], {"bytes": my_inputs.reshape(1, 2048)})[0]
    expected = expected.flatten()

    actual = model(din=my_inputs)[0]

    resources = model.estimate_resource_utilization()
    report_fit(resources)
    actual = actual.flatten()
    print("Expected scores:")
    print(expected)
    print("Expected prediction:", evaluate_output(expected))
    print("Actual scores:")
    print(actual)
    print("Actual prediction:", evaluate_output(actual))
    print("Max abs score error vs ONNX:",
          float(np.max(np.abs(actual.astype(np.float64) - expected.astype(np.float64)))))

    save_model(model, args.output_dir)
    if args.save_model:
        print(f"Saved model to {args.output_dir}/")
        exit(0)

    ret = run_flow(
        model,
        sim=args.sim,
        recompile=True,
        validate_timing=True,
        quartus_compile=args.compile,
        validate_resource_usage=False,
        output_path=args.output_dir,
        gcc_path=args.gcc_path,
    )
    if ret != 0:
        raise RuntimeError(f"run_flow failed with exit code {ret}")