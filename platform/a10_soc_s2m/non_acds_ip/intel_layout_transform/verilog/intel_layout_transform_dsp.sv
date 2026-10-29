// Copyright 2015-2023 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

`resetall
`undefineall
`default_nettype none

module intel_layout_transform_dsp  #(
  string FAMILY
) (
  input  wire         clk,
  input  wire         i_en_input,
  input  wire         i_en_pipeline,
  input  wire  [31:0] i_ay,
  input  wire  [31:0] i_az,
  input  wire  [31:0] i_ax,
  output logic [31:0] o_result  // o_result = i_ay * i_az + i_ax
);

if (FAMILY == "Arria 10") begin : GEN_A10

  // See port list in acdskit/20.3/<buildno>/linux64/modelsim_ae/altera/verilog/src/twenty_atoms.sv
  twentynm_fp_mac  #(
    .ax_clock("0"),
    .ay_clock("0"),
    .az_clock("0"),
    .accumulate_clock("NONE"),
    .accum_pipeline_clock("NONE"),
    .accum_adder_clock("NONE"),
    .ax_chainin_pl_clock("1"),
    .mult_pipeline_clock("1"),
    .adder_input_clock("1"),
    .use_chainin("false"),
    .operation_mode("sp_mult_add"),
    .adder_subtract("false"),
    .output_clock("1")
  ) accum_dsp (
    .clk({1'b0,clk,clk}),
    .ena({1'b0,i_en_pipeline,i_en_input}),
    .aclr(2'b00),
    .ay(i_ay),
    .az(i_az),
    .ax(i_ax),
    .chainin(32'b0),
    .resulta(o_result)
  );

end else if (FAMILY == "Stratix 10") begin : GEN_S10

  // See port list in acdskit/20.3/<buildno>/linux64/modelsim_ae/altera/verilog/src/fourteen_atoms.sv
  fourteennm_fp_mac  #(
    .ax_clock("0"),
    .ay_clock("0"),
    .az_clock("0"),
    .accumulate_clock("NONE"),
    .accum_pipeline_clock("NONE"),
    .accum_2nd_pipeline_clock("NONE"),
    .accum_adder_clock("NONE"),
    .ax_chainin_pl_clock("1"),
    .ax_chainin_2nd_pl_clock("1"),
    .mult_pipeline_clock("1"),
    .mult_2nd_pipeline_clock("1"),
    .adder_input_clock("1"),
    .output_clock("1"),
    .clear_type("NONE"),
    .use_chainin("false"),
    .operation_mode("sp_mult_add"),
    .adder_subtract("false")
  ) accum_dsp (
    .clk({1'b0,clk,clk}),
    .ena({1'b0,i_en_pipeline,i_en_input}),
    .ay(i_ay),
    .az(i_az),
    .ax(i_ax),
    .chainin(32'b0),
    .accumulate(1'b0),
    .resulta(o_result),
    .mult_overflow(),
    .mult_underflow(),
    .mult_invalid(),
    .mult_inexact(),
    .adder_overflow(),
    .adder_underflow(),
    .adder_invalid(),
    .adder_inexact(),
    .chainout()
  );

end else if (FAMILY == "Agilex") begin : GEN_AGX

  // See port list in acdskit/20.3/<buildno>/linux64/modelsim_ae/altera/verilog/src/tennm_atoms.sv
  tennm_fp_mac  #(
    .fp32_adder_a_clken("0"),
    .fp32_mult_a_clken("0"),
    .fp32_mult_b_clken("0"),
    .accumulate_clken("no_reg"),
    .accum_pipeline_clken("no_reg"),
    .accum_2nd_pipeline_clken("no_reg"),
    .accum_adder_clken("no_reg"),
    .fp32_adder_a_chainin_pl_clken("1"),     // first pipeline stage at adder a input
    .fp32_adder_a_chainin_2nd_pl_clken("1"), // second pipeline stage at adder a input
    .adder_input_clken("1"), // third pipeline stage at adder a input and multiplier output
    .mult_pipeline_clken("1"),
    .mult_2nd_pipeline_clken("1"),
    .adder_pl_clken("no_reg"),  // second-level adder in fp16 mult_add
    .output_clken("1"),
    .clear_type("NONE"),
    .use_chainin("false"),
    .operation_mode("fp32_mult_add"),
    .fp32_adder_subtract("false")
  ) accum_dsp (
    .clk(clk),
    .ena({1'b1,i_en_pipeline,i_en_input}),
    .accumulate(1'b0),
    .fp32_mult_a(i_ay),
    .fp32_mult_b(i_az),
    .fp32_adder_a(i_ax),
    .fp32_chainin(32'b0),
    .fp32_result(o_result),

    .fp32_mult_overflow(),
    .fp32_mult_underflow(),
    .fp32_mult_invalid(),
    .fp32_mult_inexact(),
    .fp32_adder_overflow(),
    .fp32_adder_underflow(),
    .fp32_adder_invalid(),
    .fp32_adder_inexact(),
    .fp32_chainout()
  );

end else begin
  $fatal("Unknown device family");
end

endmodule
