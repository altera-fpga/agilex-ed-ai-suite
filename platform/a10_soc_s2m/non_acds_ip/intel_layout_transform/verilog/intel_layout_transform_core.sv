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

module intel_layout_transform_core #(
  parameter FAMILY = "",
  parameter BIG_ENDIAN = 0,
  parameter IN_WIDTH =  24,
  parameter IN_SAMPLE_PLANES = 3,
  parameter IN_SAMPLE_PLANE_BITS  = 8,
  parameter OUT_WIDTH =  24

  ) (

  input  wire                   clk,
  input  wire                   rst,

  input  wire  [32*IN_SAMPLE_PLANES-1:0] csr_variance,
  input  wire  [32*IN_SAMPLE_PLANES-1:0] csr_mean,
  input  wire  [4:0]                     csr_c_vector,
  input  wire                            csr_endian,

  input  wire                            i_stream_in_tvalid,
  input  wire   [IN_WIDTH - 1 : 0]       i_stream_in_tdata,
  input  wire                            i_stream_in_tuser,
  input  wire                            i_stream_in_tlast,
  output logic                           o_stream_in_tready,

  output logic                           o_stream_out_tvalid,
  output logic  [OUT_WIDTH - 1 : 0]      o_stream_out_tdata,
  output logic                           o_stream_out_tuser,
  output logic                           o_stream_out_tlast,
  input  wire                            i_stream_out_tready
);


localparam L_CHANS = OUT_WIDTH/16; // FP16 output always.
localparam L_ADD   = IN_SAMPLE_PLANES;
localparam L_BITS  = (L_CHANS*IN_SAMPLE_PLANE_BITS);
localparam L_SHIFT = $clog2(L_CHANS);


logic [31:0] variance[IN_SAMPLE_PLANES-1:0];
logic [31:0] mean[IN_SAMPLE_PLANES-1:0];

  always_comb begin
    for(int i=0; i<IN_SAMPLE_PLANES;i++) begin
      variance[i] = csr_variance[i*32+:32];
      mean[i]     = csr_mean[i*32+:32];
    end
  end

logic [IN_SAMPLE_PLANE_BITS*32-1:0] data_c_vec;
logic [32-1:0] use_c_vec;

  always_comb begin
    data_c_vec = 'b0;
    use_c_vec = 'b0;
    for(int p=0;p<L_ADD;p++) begin
      data_c_vec[p*IN_SAMPLE_PLANE_BITS+:IN_SAMPLE_PLANE_BITS] = i_stream_in_tdata[p*IN_SAMPLE_PLANE_BITS+:IN_SAMPLE_PLANE_BITS];
      use_c_vec[p] = 1'b1;
    end
  end

logic [4:0]                    c_vector;
logic [4:0]                    c_vec_count;
logic                          c_vec_count_max;
logic                          uint_tvalid;
logic                          uint_tuser;
logic                          uint_tlast;
logic [L_BITS-1:0]             uint_data_sel;
logic [L_CHANS-1:0]            uint_use_sel;
logic [L_BITS-1:0]             uint_data;
logic [L_CHANS-1:0]            uint_use;
logic [OUT_WIDTH - 1 : 0]      out_data;

  assign c_vector = csr_c_vector >> L_SHIFT;

  assign o_stream_in_tready = c_vec_count_max & i_stream_out_tready;

  assign uint_data_sel = data_c_vec[c_vec_count*L_BITS+:L_BITS];
  assign uint_use_sel  = use_c_vec[c_vec_count*L_CHANS+:L_CHANS];
  assign c_vec_count_max = c_vec_count == c_vector;

  // ===============================================================
  // Input Padder.
  // Stall input until C_VEC_COUNT outputs have been generated
  // ===============================================================
  always @(posedge clk) begin
    if (rst) begin
      c_vec_count <= 'b0;
      uint_tvalid <= 1'b0;
      uint_tlast  <= 1'b0;
      uint_tuser  <= 1'b0;
    end else begin
      if (i_stream_out_tready) begin
        if (i_stream_in_tvalid) begin
          uint_tvalid <= 1'b1;
          uint_tuser  <= !c_vec_count    ? i_stream_in_tuser : 1'b0;
          uint_tlast  <= c_vec_count_max ? i_stream_in_tlast : 1'b0;
          if (c_vec_count_max) begin
            c_vec_count <= 'b0;
          end else
            c_vec_count <= c_vec_count + 1'b1;
          uint_data  <= uint_data_sel;
          uint_use   <= uint_use_sel;

        end else begin
          uint_tvalid <= 1'b0;
          uint_tuser  <= 1'b0;
          uint_tlast  <= 1'b0;
        end
      end
    end
  end

logic [4:0]        c_vec_count_idx;
logic [4:0]        c_vec_count_idx_d1;
logic [4:0]        c_vec_count_idx_d2;

localparam L_DSP_LATENCY = FAMILY == "Arria 10" ? 5 : 6;

logic [L_DSP_LATENCY:0]        fp16_tvalid;
logic [L_DSP_LATENCY:0]        fp16_tuser;
logic [L_DSP_LATENCY:0]        fp16_tlast;

  assign c_vec_count_idx = c_vec_count << L_SHIFT;


  // ===============================================================
  // Sideband signal delaylines
  // ===============================================================
  always_ff @(posedge clk) begin
    if (i_stream_out_tready) begin
      c_vec_count_idx_d1 <= c_vec_count_idx;
      c_vec_count_idx_d2 <= c_vec_count_idx_d1;

      fp16_tvalid <= {uint_tvalid,fp16_tvalid[$high(fp16_tvalid):1]};
      fp16_tuser  <= {uint_tuser,fp16_tuser[$high(fp16_tuser):1]};
      fp16_tlast  <= {uint_tlast,fp16_tlast[$high(fp16_tlast):1]};
    end
  end

  localparam BASE_EXP = 127 - 1; //-1 to compensate for the offset computed below

  // =======================================================================
  // Output Engines - Output-AXIS width / FP16
  // =======================================================================
  genvar c;
  generate
    for (c=0;c<L_CHANS;c++) begin : g_chan
      // Stage 1: Check for leading one, slicing the UINT in 2 halves for 4:1 MUX
      logic [7:0] sample;

      logic [1:0][3:0] exp_offset_nib;
      logic [1:0][7:0] shifted_val_nib;
      logic            uint_use_del;

      assign sample = uint_data[c*8+:8];

      always_ff @(posedge clk) begin
        if (i_stream_out_tready) begin
          uint_use_del <= uint_use[c];
        end
      end

      //4 LSBs
      always_ff @(posedge clk) begin
        if (i_stream_out_tready) begin
          exp_offset_nib[0]  <= 0;
          shifted_val_nib[0] <= 0;

          if (sample[3]) begin
            exp_offset_nib[0]  <= 4;
            shifted_val_nib[0] <= {sample[2:0], 5'b0};
          end else if (sample[2]) begin
            exp_offset_nib[0]  <= 3;
            shifted_val_nib[0] <= {sample[1:0], 6'b0};
          end else if (sample[1]) begin
            exp_offset_nib[0]  <= 2;
            shifted_val_nib[0] <= {sample[0], 7'b0};
          end else if (sample[0]) begin
            exp_offset_nib[0]  <= 1;
            shifted_val_nib[0] <= 0;
          end
        end
      end

      // 4 MSBs
      always_ff @(posedge clk) begin
        if (i_stream_out_tready) begin
          exp_offset_nib[1]  <= 0;
          shifted_val_nib[1] <= 0;

          if (sample[7]) begin
            exp_offset_nib[1]  <= 8;
            shifted_val_nib[1] <= {sample[6:0], 1'b0};
          end else if (sample[6]) begin
            exp_offset_nib[1]  <= 7;
            shifted_val_nib[1] <= {sample[5:0], 2'b0};
          end else if (sample[5]) begin
            exp_offset_nib[1]  <= 6;
            shifted_val_nib[1] <= {sample[4:0], 3'b0};
          end else if (sample[4]) begin
            exp_offset_nib[1]  <= 5;
            shifted_val_nib[1] <= {sample[3:0], 4'b0};
          end
        end
      end

      // Stage 2: Choosing between the top and bottom nibbles
      logic [7:0] exp_offset;
      logic [7:0] shifted_val;

      always_ff @(posedge clk) begin
        if (i_stream_out_tready) begin
          if (exp_offset_nib[1] > exp_offset_nib[0]) begin
            exp_offset  <= exp_offset_nib[1] + BASE_EXP;
            shifted_val <= shifted_val_nib[1];
          end else if (exp_offset_nib[0] > 0)  begin
            exp_offset  <= exp_offset_nib[0] + BASE_EXP;
            shifted_val <= shifted_val_nib[0];
          end else begin
            exp_offset  <= 0;
            shifted_val <= 0;
          end
        end
      end

      // Stage 3: Applying -me/var
      logic [31:0] fp32_val;

      // Pad to FP32
      assign fp32_val = {1'b0,  //sign bit
                         exp_offset, // Exponent
                         shifted_val, //Mantissa
                         15'b0}; // Mantissa zero padding



      logic [31:0] scaled_shifted_val;
      logic [31:0] variance_sel;
      logic [31:0] mean_sel;

      always_ff @(posedge clk) begin
        if (i_stream_out_tready) begin
          if (uint_use_del) begin
            variance_sel <= variance[c_vec_count_idx_d2+c];
            mean_sel     <= mean[c_vec_count_idx_d2+c];
          end else begin
            variance_sel <= 'b0;
            mean_sel     <= 'b0;
          end
        end
      end

      // ===============================================================
      // Output Y*Z+X in FP32
      // ===============================================================
      intel_layout_transform_dsp #(
        .FAMILY(FAMILY)
        ) u_dla_dsp_fp32_mult_add (
        .clk(clk),
        .i_en_input(i_stream_out_tready),
        .i_en_pipeline(i_stream_out_tready),
        .i_ay(fp32_val),
        .i_az(variance_sel),
        .i_ax(mean_sel),
        .o_result(scaled_shifted_val)  // o_result = i_ay * i_az + i_ax
        );

      // ===============================================================
      // FP32 to FP16 snip
      // ===============================================================
      logic [15:0] scaled_shifted_val_fp16;
      assign scaled_shifted_val_fp16 = {scaled_shifted_val[31],
        scaled_shifted_val[30],
        scaled_shifted_val[26:23],
        scaled_shifted_val[22:13]};

      assign out_data[(c+1)*16-1:c*16] = scaled_shifted_val_fp16;

    end
  endgenerate;

  assign o_stream_out_tvalid = fp16_tvalid[0];
  assign o_stream_out_tuser  = fp16_tuser[0];
  assign o_stream_out_tlast  = fp16_tlast[0];

  always_comb begin
    if (BIG_ENDIAN) begin
      for(int b=0;b<OUT_WIDTH/8;b++) begin
        o_stream_out_tdata[b*8+:8] = out_data[((OUT_WIDTH/8)-1-b)*8+:8];
      end
    end else begin
      o_stream_out_tdata = out_data;
    end
  end
endmodule


