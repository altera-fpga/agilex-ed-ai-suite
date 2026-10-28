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
import json
import shutil
from pathlib import Path

import numpy as np

try:
    import torch
    from transformers import AutoTokenizer
except ImportError as exc:
    raise ImportError(
        f"Missing dependency ({exc.name}). Install with:\n"
        "  pip install torch transformers\n"
        "See README.md for setup instructions."
    ) from exc

from common import DDR_VALID_MODELS as VALID_MODELS
from common import (extract_tinystories_weights, load_tinystories_model,
                    print_token, require_model_dir)
from fpga_ai_suite.spatial.flow import run_flow
from fpga_ai_suite.spatial.layers import (Accumulator, Activation, Add,
                                          Add_bias, Argmax, Constant,
                                          Convert_lanes,
                                          Directed_acyclic_graph, Dot,
                                          Fragment_dag, Loop_controller,
                                          Matmul, Memory, Multiply_bias,
                                          Normalize, Repeater, Reshape, Rom,
                                          Router, Sequential, Softmax,
                                          Split_dot, Transpose, Tril)


class CausalMask(Directed_acyclic_graph):
    def __init__(self, num_lanes, tensor_len, num_layers, num_heads):
        self.tensor_len = tensor_len
        self.num_layers = num_layers
        self.num_heads = num_heads
        self.num_lanes = num_lanes
        super().__init__(module_name="causal_mask")

    def init_topology(self):
        self.input = self.create_input("din", 16, self.num_lanes, dtype="BF16")
        self.output = self.create_output("dout", 16, self.num_lanes, dtype="BF16")
        self.causal_mask = self.add_node(
            Tril(value=-np.inf, num_lanes=self.num_lanes, dw=16, dtype="BF16")
        )
        self.causal_mask_repeater = self.add_node(
            Repeater(
                repeat=self.num_heads * self.num_layers,
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )

    def forward(self, din):
        causal_mask = self.causal_mask(din)
        causal_mask = self.causal_mask_repeater(causal_mask)
        return (causal_mask,)


class GPTNeoTransformerReusableLayer(Directed_acyclic_graph):

    def __init__(
        self,
        num_lanes,
        tensor_len,
        hidden_size,
        intermediate_size,
        num_layers,
        num_heads,
        transformer_weights,
        qkv_split,
        postproc_split,
        weight_channels,
    ):
        self.tensor_len = tensor_len
        self.hidden_size = hidden_size
        self.intermediate_size = intermediate_size
        assert hidden_size % num_heads == 0
        self.size_of_head = hidden_size // num_heads
        self.num_layers = num_layers
        self.num_heads = num_heads
        self.transformer_weights = transformer_weights
        self.num_lanes = num_lanes
        self.qkv_split = qkv_split
        self.postproc_split = postproc_split
        self.weight_channels = weight_channels
        super().__init__(module_name="gptneo_reusable_layer")

    def init_topology(self):
        self.input = self.create_input("din", 16, self.num_lanes, dtype="BF16")
        self.output = self.create_output("dout", 16, self.num_lanes, dtype="BF16")
        for i in range(self.weight_channels):
            self.create_weight_port(f"weights{i}", internal_rd_channel_width=32)

        self.ln_1 = self.add_node(
            Sequential(
                "ln1",
                [
                    Normalize(num_lanes=self.num_lanes, epsilon=1e-5),
                    Multiply_bias(
                        bias=self.transformer_weights["ln1"]["m1"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        dw_bias=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                    Add_bias(
                        bias=self.transformer_weights["ln1"]["b1"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        dw_bias=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                ],
            )
        )
        self.repeater = self.add_node(
            Repeater(repeat=3, num_lanes=self.num_lanes, dw=16, dtype="BF16")
        )
        self.router = self.add_node(
            Router(num_channels=3, num_lanes=self.num_lanes, dw=16, dtype="BF16")
        )
        restructure_attention_weights = (
            lambda x: x.reshape(-1, self.num_heads, self.hidden_size, self.size_of_head)
            .transpose(0, 2, 1, 3)
            .reshape(-1, self.hidden_size, self.hidden_size)
        )
        self.q_lanes_in = self.add_node(
            Convert_lanes(num_lanes_in=self.num_lanes, num_lanes_out=8, dw=16, dtype="BF16")
        )
        self.q_lanes_out = self.add_node(
            Convert_lanes(num_lanes_in=8, num_lanes_out=self.num_lanes, dw=16, dtype="BF16")
        )
        self.q = self.add_node(
            Split_dot(
                weights=restructure_attention_weights(self.transformer_weights["attention"]["q_w"]),
                num_lanes_in=8,
                num_lanes_out=8,
                num_split_input=1,
                num_split_output=self.qkv_split,
                num_channels=self.weight_channels,
                dtype="BF16",
                mif_init=False,
            )
        )

        self.k_lanes_in = self.add_node(
            Convert_lanes(num_lanes_in=self.num_lanes, num_lanes_out=8, dw=16, dtype="BF16")
        )
        self.k_lanes_out = self.add_node(
            Convert_lanes(num_lanes_in=8, num_lanes_out=self.num_lanes, dw=16, dtype="BF16")
        )
        self.k = self.add_node(
            Split_dot(
                weights=restructure_attention_weights(self.transformer_weights["attention"]["k_w"]),
                num_lanes_in=8,
                num_lanes_out=8,
                num_split_input=1,
                num_split_output=self.qkv_split,
                num_channels=self.weight_channels,
                dtype="BF16",
                mif_init=False,
            )
        )

        self.v_lanes_in = self.add_node(
            Convert_lanes(num_lanes_in=self.num_lanes, num_lanes_out=8, dw=16, dtype="BF16")
        )
        self.v_lanes_out = self.add_node(
            Convert_lanes(num_lanes_in=8, num_lanes_out=self.num_lanes, dw=16, dtype="BF16")
        )
        self.v = self.add_node(
            Split_dot(
                weights=restructure_attention_weights(self.transformer_weights["attention"]["v_w"]),
                num_lanes_in=8,
                num_lanes_out=8,
                num_split_input=1,
                num_split_output=self.qkv_split,
                num_channels=self.weight_channels,
                dtype="BF16",
                mif_init=False,
            )
        )
        self.q_out = self.add_node(
            Reshape(
                output_shape=(self.num_heads, 1, self.size_of_head),
                input_shape=(1, 1, self.hidden_size),
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.k_out = self.add_node(
            Reshape(
                output_shape=(self.num_heads, 1, self.size_of_head),
                input_shape=(1, 1, self.hidden_size),
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.v_out = self.add_node(
            Reshape(
                output_shape=(self.num_heads, 1, self.size_of_head),
                input_shape=(1, 1, self.hidden_size),
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.iindex_rom = self.add_node(
            Rom(
                weights=np.arange(self.tensor_len * self.num_heads * self.num_layers)
                .reshape(self.num_layers, self.num_heads, self.tensor_len)
                .transpose(2, 0, 1)
                .reshape(-1, 1, 1),
                num_lanes=1,
                dw=(self.tensor_len * self.num_heads * self.num_layers - 1).bit_length(),
                dtype="UINT",
            )
        )
        self.register_rom_dependency(self.iindex_rom.node, self.k_out.node.outputs.dout)
        self.oindex_rom = self.add_node(
            Rom(
                weights=np.arange(self.tensor_len * self.num_heads * self.num_layers).reshape(
                    -1, 1, 1
                ),
                num_lanes=1,
                dw=(self.tensor_len * self.num_heads * self.num_layers - 1).bit_length(),
                dtype="UINT",
            )
        )
        self.register_rom_dependency(self.oindex_rom.node, self.k_out.node.outputs.dout, pkt_multiplier=self.tensor_len)
        self.k_cache = self.add_node(
            Memory(
                memory_depth=self.tensor_len * self.num_heads * self.num_layers,
                p_in=self.num_heads,
                p_out=self.tensor_len * self.num_heads,
                total_iterations=self.tensor_len * self.num_layers,
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.v_cache = self.add_node(
            Memory(
                memory_depth=self.tensor_len * self.num_heads * self.num_layers,
                p_in=self.num_heads,
                p_out=self.tensor_len * self.num_heads,
                total_iterations=self.tensor_len * self.num_layers,
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.k_reshape = self.add_node(
            Reshape(
                output_shape=(self.num_heads, self.tensor_len, self.size_of_head),
                input_shape=(self.tensor_len * self.num_heads, 1, self.size_of_head),
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.v_reshape = self.add_node(
            Reshape(
                output_shape=(self.num_heads, self.tensor_len, self.size_of_head),
                input_shape=(self.tensor_len * self.num_heads, 1, self.size_of_head),
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.k_t = self.add_node(Transpose(num_lanes=self.num_lanes, dw=16, dtype="BF16"))
        self.qkt = self.add_node(
            Matmul(
                num_lanes_a=self.num_lanes,
                num_lanes_b=self.num_lanes,
                dw_in=16,
                dw_out=16,
                dtype="BF16",
            )
        )

        self.zero_const = self.add_node(
            Constant(
                value=0.0,
                m=self.tensor_len,
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.register_rom_dependency(self.zero_const.node, self.input)
        # Need to fragment to support multiple loop iterations using same causal mask
        causal_mask = CausalMask(self.num_lanes, self.tensor_len, self.num_layers, self.num_heads)
        self.causal_mask = self.add_node(
            Fragment_dag(causal_mask, self.num_layers*self.num_heads, self.num_heads)
        )

        self.add_causal_mask = self.add_node(Add(num_lanes=self.num_lanes, dw=16, dtype="BF16"))

        self.softmax = self.add_node(Softmax(self.num_lanes))
        self.attention_out = self.add_node(
            Matmul(
                num_lanes_a=self.num_lanes,
                num_lanes_b=self.num_lanes,
                dw_in=16,
                dw_out=16,
                dtype="BF16",
            )
        )
        self.out_mul = self.add_node(
            Dot(
                weights=self.transformer_weights["attention"]["o_w"],
                num_lanes_in=self.num_lanes,
                num_lanes_out=self.num_lanes,
                dtype="BF16",
                mif_init=False,
            )
        )
        self.accumulator = self.add_node(
            Accumulator(
                num_packets=self.num_heads,
                num_lanes=self.num_lanes,
                dw_in=16,
                dtype="BF16",
            )
        )
        self.out_add_bias = self.add_node(
            Add_bias(
                bias=self.transformer_weights["attention"]["o_b"],
                num_lanes=self.num_lanes,
                dw_in=16,
                dw_out=16,
                dw_bias=16,
                num_packets_per_weight=1,
                dtype="BF16",
            )
        )
        self.sum_1 = self.add_node(Add(num_lanes=self.num_lanes, dw=16, dtype="BF16"))
        self.postprocessing1 = self.add_node(
            Sequential(
                "postproc_1",
                [
                    Normalize(num_lanes=self.num_lanes, epsilon=1e-5),
                    Multiply_bias(
                        bias=self.transformer_weights["post"]["m1"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                    Add_bias(
                        bias=self.transformer_weights["post"]["b1"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        dw_bias=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                    Convert_lanes(num_lanes_in=self.num_lanes, num_lanes_out=8, dw=16, dtype="BF16"),
                ],
            )
        )
        self.post_proc_dot1 = self.add_node(
            Split_dot(
                weights=self.transformer_weights["post"]["d1"],
                num_lanes_in=8,
                num_lanes_out=8,
                num_split_input=1,
                num_split_output=self.postproc_split,
                num_channels=self.weight_channels,
                dtype="BF16",
                mif_init=False,
            )
        )
        self.postprocessing2 = self.add_node(
            Sequential(
                "postproc_2",
                [
                    Convert_lanes(num_lanes_in=8, num_lanes_out=self.num_lanes, dw=16, dtype="BF16"),
                    Add_bias(
                        bias=self.transformer_weights["post"]["b2"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        dw_bias=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                    Activation("gelu", self.num_lanes),
                    Convert_lanes(num_lanes_in=self.num_lanes, num_lanes_out=8, dw=16, dtype="BF16"),
                ],
            )
        )
        self.post_proc_dot2 = self.add_node(
            Split_dot(
                weights=self.transformer_weights["post"]["d2"],
                num_lanes_in=8,
                num_lanes_out=8,
                num_split_input=1,
                num_split_output=self.postproc_split,
                num_channels=self.weight_channels,
                dtype="BF16",
                mif_init=False,
            )
        )
        self.postprocessing3 = self.add_node(
            Sequential(
                "postproc_3",
                [
                    Convert_lanes(num_lanes_in=8, num_lanes_out=self.num_lanes, dw=16, dtype="BF16"),
                    Add_bias(
                        bias=self.transformer_weights["post"]["b3"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        dw_bias=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                ],
            )
        )
        self.sum_2 = self.add_node(Add(num_lanes=self.num_lanes, dw=16, dtype="BF16"))

        for i in range(self.weight_channels):
            self.weights[f"weights{i}"].connect(
                [
                    self.q.node.weights[f"weights{i}"],
                    self.k.node.weights[f"weights{i}"],
                    self.v.node.weights[f"weights{i}"],
                    self.post_proc_dot1.node.weights[f"weights{i}"],
                    self.post_proc_dot2.node.weights[f"weights{i}"],
                ]
            )

        self.weights.weights0.connect(self.out_mul.node.weights.weights)

    def forward(self, din):
        x = self.ln_1(din)
        x = self.repeater(x)
        r = self.router(x)
        q = r[0]
        q = self.q_lanes_in(q)
        q = self.q(q)
        q = self.q_lanes_out(q)
        q = self.q_out(q)
        k = r[1]
        k = self.k_lanes_in(k)
        k = self.k(k)
        k = self.k_lanes_out(k)
        k = self.k_out(k)
        iindex = self.iindex_rom()
        oindex = self.oindex_rom()
        k = self.k_cache(k, iindex, oindex)
        k = self.k_reshape(k)
        k_t = self.k_t(k)
        v = r[2]
        v = self.v_lanes_in(v)
        v = self.v(v)
        v = self.v_lanes_out(v)
        v = self.v_out(v)
        v = self.v_cache(v, iindex, oindex)
        v = self.v_reshape(v)
        qkt = self.qkt(q, k_t)
        zero = self.zero_const()
        causal_mask = self.causal_mask(zero)
        qkt = self.add_causal_mask(qkt, causal_mask)
        qkt = self.softmax(qkt)
        attn = self.attention_out(qkt, v)
        attn = self.out_mul(attn)
        attn = self.accumulator(attn)
        attn = self.out_add_bias(attn)
        sum_1 = self.sum_1(din, attn)
        postproc = self.postprocessing1(sum_1)
        postproc = self.post_proc_dot1(postproc)
        postproc = self.postprocessing2(postproc)
        postproc = self.post_proc_dot2(postproc)
        postproc = self.postprocessing3(postproc)
        sum_2 = self.sum_2(sum_1, postproc)
        return (sum_2,)


class GPTNeoTransformerMultiLayer_cached(Directed_acyclic_graph):

    def __init__(
        self,
        num_lanes,
        tensor_len,
        hidden_size,
        intermediate_size,
        num_layers,
        num_heads,
        transformer_weights,
        qkv_split,
        postproc_split,
        lm_head_num_split,
        weight_channels,
    ):
        self.tensor_len = tensor_len
        self.hidden_size = hidden_size
        self.intermediate_size = intermediate_size
        assert hidden_size % num_heads == 0
        self.size_of_head = hidden_size // num_heads
        self.num_layers = num_layers
        self.num_heads = num_heads
        self.transformer_weights = transformer_weights
        self.num_lanes = num_lanes

        self.lm_head_out_num_lanes = 25
        self.lm_head_num_split = lm_head_num_split
        self.qkv_split = qkv_split
        self.postproc_split = postproc_split
        self.weight_channels = weight_channels

        super().__init__(module_name="gptneo_transformer_v5_ddr")

    def init_topology(self):
        self.input = self.create_input("din", 16, self.num_lanes, dtype="BF16")
        self.output = self.create_output("dout", int(np.ceil(np.log2(10000))), 1, dtype="UINT")
        for i in range(self.weight_channels):
            self.create_weight_port(
                f"weights{i}",
                internal_rd_channel_width=2 * 16 * 8,  # Split_dot uses a hard coded 8 num lanes.
                ddr_addr_width=32,
                ddr_channel_width=512,
                bank=i,
            )

        self.layer_loop = self.add_node(
            Loop_controller(
                GPTNeoTransformerReusableLayer(
                    self.num_lanes,
                    self.tensor_len,
                    self.hidden_size,
                    self.intermediate_size,
                    self.num_layers,
                    self.num_heads,
                    self.transformer_weights,
                    self.qkv_split,
                    self.postproc_split,
                    self.weight_channels,
                ),
                num_iters=self.num_layers,
                num_lanes=self.num_lanes,
                dw=16,
                dtype="BF16",
            )
        )
        self.ln_final = self.add_node(
            Sequential(
                "finalproc",
                [
                    Normalize(num_lanes=self.num_lanes, epsilon=1e-5),
                    Multiply_bias(
                        bias=self.transformer_weights["lnf"]["m1"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                    Add_bias(
                        bias=self.transformer_weights["lnf"]["b1"],
                        num_lanes=self.num_lanes,
                        dw_in=16,
                        dw_out=16,
                        dw_bias=16,
                        num_packets_per_weight=1,
                        dtype="BF16",
                    ),
                ],
            )
        )
        self.lm_head_input_convert = self.add_node(
            Convert_lanes(num_lanes_in=self.num_lanes, num_lanes_out=8, dw=16, dtype="BF16")
        )

        self.lm_head = self.add_node(
            Split_dot(
                weights=new_weights["lm_head"]["d1"],
                num_split_input=1,
                num_split_output=self.lm_head_num_split,
                num_channels=self.weight_channels,
                num_lanes_in=8,
                num_lanes_out=self.lm_head_out_num_lanes,
                dtype="BF16",
                mif_init=True,
            )
        )
        self.argmax = self.add_node(
            Argmax("MAX", num_lanes=self.lm_head_out_num_lanes, dw=16, dtype="BF16")
        )

        for i in range(self.weight_channels):
            self.weights[f"weights{i}"].connect(
                [
                    self.layer_loop.node.weights[f"weights{i}"],
                    self.lm_head.node.weights[f"weights{i}"],
                ]
            )

    def forward(self, din):
        x = self.layer_loop(din)
        x = self.ln_final(x)
        x = self.lm_head_input_convert(x)
        x = self.lm_head(x)
        _, argmax = self.argmax(x)
        return (argmax,)


def spark_generate_tiny_story(
    input_ids,
    num_lanes,
    max_length,
    hidden_size,
    intermediate_size,
    num_layers,
    num_heads,
    new_weights,
    qkv_split,
    postproc_split,
    lm_head_num_split,
    weight_channels,
    embed_idx,
    run_sim=True,
    compile=False,
    save_model=False,
    generate_pta=False,
):
    initial_len = input_ids.shape[-1]
    input_ids = torch.cat((input_ids, torch.zeros((1, max_length - initial_len + 1))), dim=-1).int()
    model = GPTNeoTransformerMultiLayer_cached(
        num_lanes,
        max_length,
        hidden_size,
        intermediate_size,
        num_layers,
        num_heads,
        new_weights,
        qkv_split,
        postproc_split,
        lm_head_num_split,
        weight_channels,
    )
    inputs = []
    outputs = []
    for i in range(max_length):
        input_embed = embed_idx(input_ids[0][i], i)
        inputs.append(input_embed.reshape(1, 1, hidden_size).float().numpy())
        model_out = model(din=input_embed.reshape(1, 1, hidden_size).float().numpy())
        outputs.append(model_out[0])
        if i < initial_len:
            # Prefill: echo the prompt token that was just consumed.
            print_token(tokenizer, input_ids[0][i])
        if i + 1 >= initial_len:
            next_token = model_out[0][0][0][0]
            input_ids[0][i + 1] = next_token
            print_token(tokenizer, next_token)

    print()
    model.inputs.din.data = np.array(inputs).reshape(-1, 1, hidden_size)
    model.outputs.dout.data = np.array(outputs).reshape(-1, 1, 1)
    ret = run_flow(
        model,
        sim=run_sim,
        recompile=True,
        quartus_compile=compile,
        save_model=save_model,
        output_path="saved_model" if save_model else None,
        generate_pta=generate_pta,
    )
    if ret != 0:
        raise RuntimeError(f"run_flow failed with exit code {ret}")
    return tokenizer.decode(input_ids[0], skip_special_tokens=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--model",
        type=str,
        required=True,
        choices=VALID_MODELS,
        help="TinyStories size (DDR requires 3M+): one of " + ", ".join(VALID_MODELS),
    )
    parser.add_argument("--sim", action="store_true", help="Runs VCS simulation with inputs/outputs from emulation")
    parser.add_argument("--compile", action="store_true", help=" Runs quartus compile and prints Fmax, ALM, DSP and M20k usage at the end.")
    parser.add_argument("--save-model", action="store_true", help="Serialize the model to saved_model/ without running emulation")
    parser.add_argument("--generate-pta", action="store_true", help="Generate a PTA file without simulation or Quartus compilation")

    args = parser.parse_args()

    print("Now processing TinyStories-{}".format(args.model))
    model_path = require_model_dir(args.model)

    tokenizer_config = Path("ReducedTokenizerConfig")
    new_path = Path(f"TinyStories-{args.model}-v10k")
    # copy tokenizer
    if not tokenizer_config.is_dir():
        raise FileNotFoundError(
            "Bundled './ReducedTokenizerConfig' directory not found.\n"
            "Run this script from the tiny_story/ directory "
            "(beside README.md and ReducedTokenizerConfig/)."
        )
    if new_path.exists():
        shutil.rmtree(new_path)
    shutil.copytree(tokenizer_config, new_path)
    # patch weights
    orig_tokens = json.loads((model_path / "vocab.json").read_text())
    new_tokens = json.loads((new_path / "vocab.json").read_text())
    model_original = load_tinystories_model(
        model_path, torch_dtype=torch.bfloat16
    )
    orig_embedding = model_original.transformer.wte.weight
    old_index = []
    new_index = []
    for k, v in new_tokens.items():
        new_index.append(v)
        old_index.append(orig_tokens[k])
    new_embedding = torch.zeros(10000, orig_embedding.shape[1], dtype=orig_embedding.dtype)
    new_embedding[new_index] = orig_embedding[old_index]
    model_original.transformer.wte.weight.data = new_embedding
    model_original.lm_head.weight.data = new_embedding
    # patch config
    config = json.loads((model_path / "config.json").read_text())
    config["bos_token_id"] = 9999
    config["eos_token_id"] = 9999
    config["vocab_size"] = 10000
    (new_path / "config.json").write_text(json.dumps(config))

    if args.model == "3M":
        num_lanes = 8
        hidden_size = 128
        num_layers = 8
        qkv_split = 4
        postproc_split = 4
        lm_head_num_split = 4
        weight_channels = 2
    elif args.model == "8M":
        num_lanes = 16
        hidden_size = 256
        num_layers = 8
        qkv_split = 4
        postproc_split = 4
        lm_head_num_split = 4
        weight_channels = 4
    elif args.model == "28M":
        num_lanes = 16
        hidden_size = 512
        num_layers = 8
        qkv_split = 8
        postproc_split = 24
        lm_head_num_split = 40
        weight_channels = 4
    elif args.model == "33M":
        num_lanes = 16
        hidden_size = 768
        num_layers = 4
        qkv_split = 8
        postproc_split = 24
        lm_head_num_split = 40
        weight_channels = 4

    tensor_len = 32

    tokenizer = AutoTokenizer.from_pretrained(new_path, torch_dtype=torch.bfloat16)

    assert tokenizer.vocab_size == 10000
    prompt = "Once upon"
    input_ids = tokenizer.encode(prompt, return_tensors="pt")
    assert len(input_ids) > 0
    # expected = model_original.generate(input_ids, max_length = tensor_len, num_beams=1, pad_token_id=tokenizer.eos_token_id)
    # expected_text = tokenizer.decode(expected[0], skip_special_tokens=True)
    # print("Expected:")
    # print(expected_text)

    intermediate_size = 4 * hidden_size
    num_heads = 16

    new_weights, embed_idx = extract_tinystories_weights(
        model_original, num_layers, num_heads, hidden_size
    )
    actual_text = spark_generate_tiny_story(
        input_ids,
        num_lanes,
        tensor_len,
        hidden_size,
        intermediate_size,
        num_layers,
        num_heads,
        new_weights,
        qkv_split,
        postproc_split,
        lm_head_num_split,
        weight_channels,
        embed_idx,
        run_sim=args.sim,
        compile=args.compile,
        save_model=args.save_model,
        generate_pta=args.generate_pta,
    )
    print("Actual:")
    print(actual_text)
