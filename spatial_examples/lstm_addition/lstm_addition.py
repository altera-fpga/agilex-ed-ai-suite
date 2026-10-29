# Copyright 2025 Altera Corporation.
#
# This software and the related documents are Altera copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Altera's prior written
# permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the
# License.

import argparse
from pathlib import Path

import numpy as np
from fpga_ai_suite.spatial.flow import run_flow
from fpga_ai_suite.spatial.layers import (Directed_acyclic_graph, Linear, Lstm,
                                          Repeater, Sequential, Softmax)
from tensorflow import keras

DIGITS = 5
MAXLEN = DIGITS + 1 + DIGITS
chars = "0123456789+ "


class CharacterTable:
    """Given a set of characters:
    + Encode them to a one-hot integer representation
    + Decode the one-hot or integer representation to their character output
    + Decode a vector of probabilities to their character output
    """

    def __init__(self, chars):
        """Initialize character table.
        # Arguments
            chars: Characters that can appear in the input.
        """
        self.chars = sorted(set(chars))
        self.char_indices = dict((c, i) for i, c in enumerate(self.chars))
        self.indices_char = dict((i, c) for i, c in enumerate(self.chars))

    def encode(self, C, num_rows):
        """One-hot encode given string C.
        # Arguments
            C: string, to be encoded.
            num_rows: Number of rows in the returned one-hot encoding. This is
                used to keep the # of rows for each data the same.
        """
        x = np.zeros((num_rows, len(self.chars)))
        for i, c in enumerate(C):
            x[i, self.char_indices[c]] = 1
        return x

    def decode(self, x, calc_argmax=True):
        """Decode the given vector or 2D array to their character output.
        # Arguments
            x: A vector or a 2D array of probabilities or one-hot representations;
                or a vector of character indices (used with `calc_argmax=False`).
            calc_argmax: Whether to find the character index with maximum
                probability, defaults to `True`.
        """
        if calc_argmax:
            x = x.argmax(axis=-1)
        return "".join(self.indices_char[x] for x in x)


class Lstm_addition(Directed_acyclic_graph):
    def __init__(self, weights, max_len, dw, num_lanes):
        self.weight_data = weights
        self.max_len = max_len
        self.dw = dw
        self.num_lanes = num_lanes
        super().__init__(module_name="lstm_addition")

    def init_topology(self):
        self.din = self.create_input("din", 16, 4, "BF16")
        self.dout = self.create_output("dout", 16, 4, "BF16")
        self.create_weight_port("weights", internal_rd_channel_width=32)
        self.sequential = self.add_node(
            Sequential(
                "sequential",
                [
                    Lstm(
                        self.weight_data["lstm0"],
                        128,
                        self.max_len,
                        128,
                        self.num_lanes,
                        self.num_lanes,
                        self.dw,
                        return_sequences=False,
                    ),
                    Repeater(repeat=DIGITS + 1, num_lanes=self.num_lanes, dw=16, dtype="BF16"),
                    Lstm(
                        self.weight_data["lstm1"],
                        128,
                        DIGITS + 1,
                        128,
                        self.num_lanes,
                        self.num_lanes,
                        self.dw,
                        return_sequences=True,
                    ),
                    Linear(
                        weights=self.weight_data["dot"],
                        num_lanes_in=self.num_lanes,
                        num_lanes_out=self.num_lanes,
                        num_packets_per_weight=1,
                        dtype="BF16",
                        bias=self.weight_data["bias"],
                    ),
                    Softmax(self.num_lanes),
                ],
            )
        )
        self.connect(self.din, self.sequential.inputs.din)
        self.connect(self.sequential.outputs.dout, self.dout)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--sim", action="store_true")
    parser.add_argument("--compile", action="store_true")
    args = parser.parse_args()

    ctable = CharacterTable(chars)

    model_path = Path("lstm-addition") / "saved_model.pb"
    if not model_path.is_file():
        raise FileNotFoundError(
            f"Missing model file: {model_path!r}.\n"
            "Download with:\n"
            "  hf download keras-io/addition-lstm --local-dir ./lstm-addition\n"
            "See README.md for download instructions."
        )
    tf_model = keras.layers.TFSMLayer(
        model_path.parent.as_posix(), call_endpoint="serving_default"
    )

    prompt = "70997+25222"
    enc_prompt = ctable.encode(prompt[::-1], MAXLEN)[np.newaxis, ...]
    output = tf_model(enc_prompt)["dense"].numpy()
    dec_output = ctable.decode(np.argmax(output, axis=-1)[0], False)

    weights = {"lstm0": {}, "lstm1": {}}
    (
        weights["lstm0"]["k_i"],
        weights["lstm0"]["k_f"],
        weights["lstm0"]["k_c"],
        weights["lstm0"]["k_o"],
    ) = np.split(tf_model.weights[0].numpy(), 4, axis=1)
    (
        weights["lstm0"]["rk_i"],
        weights["lstm0"]["rk_f"],
        weights["lstm0"]["rk_c"],
        weights["lstm0"]["rk_o"],
    ) = np.split(tf_model.weights[1].numpy(), 4, axis=1)
    (
        weights["lstm0"]["b_i"],
        weights["lstm0"]["b_f"],
        weights["lstm0"]["b_c"],
        weights["lstm0"]["b_o"],
    ) = np.split(tf_model.weights[2].numpy(), 4, axis=0)
    (
        weights["lstm1"]["k_i"],
        weights["lstm1"]["k_f"],
        weights["lstm1"]["k_c"],
        weights["lstm1"]["k_o"],
    ) = np.split(tf_model.weights[3].numpy(), 4, axis=1)
    (
        weights["lstm1"]["rk_i"],
        weights["lstm1"]["rk_f"],
        weights["lstm1"]["rk_c"],
        weights["lstm1"]["rk_o"],
    ) = np.split(tf_model.weights[4].numpy(), 4, axis=1)
    (
        weights["lstm1"]["b_i"],
        weights["lstm1"]["b_f"],
        weights["lstm1"]["b_c"],
        weights["lstm1"]["b_o"],
    ) = np.split(tf_model.weights[5].numpy(), 4, axis=0)
    weights["dot"] = tf_model.weights[6].numpy()
    weights["bias"] = tf_model.weights[7].numpy()

    model = Lstm_addition(weights, MAXLEN, 16, 4)
    ac_output = model(din=enc_prompt.reshape(11, 1, 12))[0].reshape(1, 6, 12)
    ac_dec_output = ctable.decode(np.argmax(ac_output, axis=-1)[0], False)

    ret = run_flow(
        model, sim=args.sim, recompile=True, validate_timing=True, quartus_compile=args.compile
    )
    if ret != 0:
        raise RuntimeError(f"run_flow failed with exit code {ret}")

    print("Expected: " + prompt + " = " + dec_output)
    print("Actual: " + prompt + " = " + ac_dec_output)
