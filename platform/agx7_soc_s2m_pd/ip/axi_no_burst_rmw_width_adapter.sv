// Copyright 2025-2026 Altera Corporation.
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


// Single-beat transactions only (burst/LEN ports present but ignored).
// Reads and writes are mutually exclusive on the slave side.
// This module is included in AGX7 SOC Coredla example design because the H2F AXI addresswidth 
// in HPS paremeters does not exceed 32. Quartus settles for 32 for any higher addresss width selected in HPS settings
// This IP can be replaced later as and when AXI width adapter becomes available in Altera IP Catalog.
// Fixed 32-bit slave -> 512-bit master AXI width adapter (read-modify-write).
// Master ports must be 512-bit data / 64-bit strobe; slave ports must be 32/4.

`default_nettype none

module axi_no_burst_rmw_width_adapter #(
    parameter ADDR_WIDTH = 32
) (
    input  wire                    clk,
    input  wire                    resetn,

    // ================= SLAVE (32-bit) =================
    input  wire [ADDR_WIDTH-1:0]   S_AWADDR,
    input  wire                    S_AWVALID,
    output logic                   S_AWREADY,

    input  wire [7:0]              S_AWLEN,
    input  wire [2:0]              S_AWSIZE,
    input  wire [1:0]              S_AWBURST,

    input  wire [31:0]             S_WDATA,
    input  wire [3:0]              S_WSTRB,
    input  wire                    S_WVALID,
    output logic                   S_WREADY,

    output logic                   S_BVALID,
    input  wire                    S_BREADY,

    input  wire [ADDR_WIDTH-1:0]   S_ARADDR,
    input  wire                    S_ARVALID,
    output logic                   S_ARREADY,

    input  wire [7:0]              S_ARLEN,
    input  wire [2:0]              S_ARSIZE,
    input  wire [1:0]              S_ARBURST,

    output logic [31:0]            S_RDATA,
    output logic                   S_RVALID,
    output logic                   S_RLAST,
    input  wire                    S_RREADY,

    input  wire [3:0]              S_AWID,
    output logic [3:0]             S_BID,

    input  wire [3:0]              S_ARID,
    output logic [3:0]             S_RID,

    // ================= MASTER (512-bit) =================
    output logic [ADDR_WIDTH-1:0]  M_AWADDR,
    output logic [7:0]             M_AWLEN,
    output logic [2:0]             M_AWSIZE,
    output logic [1:0]             M_AWBURST,
    output logic [2:0]             M_AWPROT,
    output logic                   M_AWVALID,
    input  wire                    M_AWREADY,

    output logic [511:0]           M_WDATA,
    output logic [63:0]            M_WSTRB,
    output logic                   M_WVALID,
    output logic                   M_WLAST,
    input  wire                    M_WREADY,

    input  wire                    M_BVALID,
    output wire                    M_BREADY,

    output logic [ADDR_WIDTH-1:0]  M_ARADDR,
    output logic [7:0]             M_ARLEN,
    output logic [2:0]             M_ARSIZE,
    output logic [1:0]             M_ARBURST,
    output logic [2:0]             M_ARPROT,
    output logic                   M_ARVALID,
    input  wire                    M_ARREADY,

    input  wire [511:0]            M_RDATA,
    input  wire                    M_RVALID,
    output wire                    M_RREADY
);

    localparam [3:0] WR_IDLE       = 4'd0;
    localparam [3:0] WR_RMW_AR     = 4'd1;
    localparam [3:0] WR_RMW_WAIT_R = 4'd2;
    localparam [3:0] WR_SEND_AW    = 4'd3;
    localparam [3:0] WR_SEND_W     = 4'd4;
    localparam [3:0] WR_WAIT_B     = 4'd5;
    localparam [3:0] WR_RESP       = 4'd6;

    localparam [2:0] RD_IDLE    = 3'd0;
    localparam [2:0] RD_SEND_AR = 3'd1;
    localparam [2:0] RD_WAIT_R  = 3'd2;
    localparam [2:0] RD_RESP    = 3'd3;

    logic [3:0] wr_state;
    logic [2:0] rd_state;

    logic                  aw_seen;
    logic                  w_seen;
    logic [ADDR_WIDTH-1:0] awaddr_q;
    logic [31:0]           wdata_q;
    logic [3:0]            wstrb_q;
    logic [3:0]            awid_q;
    logic [3:0]            wr_index;

    logic [ADDR_WIDTH-1:0] araddr_q;
    logic [3:0]            arid_q;
    logic [3:0]            rd_index;

    logic [511:0] rmw_rdata;
    logic [511:0] rmw_wdata;
    logic [511:0] rd_buffer;

    // If M_RVALID is high when AR completes, drain that stale beat (RREADY=1,
    // no capture) before accepting the response for this transaction.
    logic rd_drain_r;
    logic wr_drain_r;

    wire [ADDR_WIDTH-1:0] aw_line_addr = {awaddr_q[ADDR_WIDTH-1:6], 6'b0};
    wire [ADDR_WIDTH-1:0] ar_line_addr = {araddr_q[ADDR_WIDTH-1:6], 6'b0};

    wire wr_busy = (wr_state != WR_IDLE);
    wire rd_busy = (rd_state != RD_IDLE);

    assign M_BREADY = (wr_state == WR_SEND_W) || (wr_state == WR_WAIT_B);
    assign M_RREADY = (wr_state == WR_RMW_WAIT_R) || (rd_state == RD_WAIT_R);

    // Byte merge within one 32-bit word (fixed width, no variable part-select)
    function [31:0] merge_word;
        input [31:0] old_w;
        begin
            merge_word = {
                wstrb_q[3] ? wdata_q[31:24] : old_w[31:24],
                wstrb_q[2] ? wdata_q[23:16] : old_w[23:16],
                wstrb_q[1] ? wdata_q[15:8]  : old_w[15:8],
                wstrb_q[0] ? wdata_q[7:0]   : old_w[7:0]
            };
        end
    endfunction

    // Constant-index lane mux (16 x 32-bit) — Quartus-safe
    always_comb  begin
        rmw_wdata = rmw_rdata;
        M_WSTRB   = 64'd0;

        case (wr_index)
            4'd0:  begin rmw_wdata[31:0]    = merge_word(rmw_rdata[31:0]);    M_WSTRB[3:0]    = wstrb_q; end
            4'd1:  begin rmw_wdata[63:32]   = merge_word(rmw_rdata[63:32]);   M_WSTRB[7:4]    = wstrb_q; end
            4'd2:  begin rmw_wdata[95:64]   = merge_word(rmw_rdata[95:64]);   M_WSTRB[11:8]   = wstrb_q; end
            4'd3:  begin rmw_wdata[127:96]  = merge_word(rmw_rdata[127:96]);  M_WSTRB[15:12]  = wstrb_q; end
            4'd4:  begin rmw_wdata[159:128] = merge_word(rmw_rdata[159:128]); M_WSTRB[19:16]  = wstrb_q; end
            4'd5:  begin rmw_wdata[191:160] = merge_word(rmw_rdata[191:160]); M_WSTRB[23:20]  = wstrb_q; end
            4'd6:  begin rmw_wdata[223:192] = merge_word(rmw_rdata[223:192]); M_WSTRB[27:24]  = wstrb_q; end
            4'd7:  begin rmw_wdata[255:224] = merge_word(rmw_rdata[255:224]); M_WSTRB[31:28]  = wstrb_q; end
            4'd8:  begin rmw_wdata[287:256] = merge_word(rmw_rdata[287:256]); M_WSTRB[35:32]  = wstrb_q; end
            4'd9:  begin rmw_wdata[319:288] = merge_word(rmw_rdata[319:288]); M_WSTRB[39:36]  = wstrb_q; end
            4'd10: begin rmw_wdata[351:320] = merge_word(rmw_rdata[351:320]); M_WSTRB[43:40]  = wstrb_q; end
            4'd11: begin rmw_wdata[383:352] = merge_word(rmw_rdata[383:352]); M_WSTRB[47:44]  = wstrb_q; end
            4'd12: begin rmw_wdata[415:384] = merge_word(rmw_rdata[415:384]); M_WSTRB[51:48]  = wstrb_q; end
            4'd13: begin rmw_wdata[447:416] = merge_word(rmw_rdata[447:416]); M_WSTRB[55:52]  = wstrb_q; end
            4'd14: begin rmw_wdata[479:448] = merge_word(rmw_rdata[479:448]); M_WSTRB[59:56]  = wstrb_q; end
            default: begin rmw_wdata[511:480] = merge_word(rmw_rdata[511:480]); M_WSTRB[63:60]  = wstrb_q; end
        endcase
    end



    // -------------------------------------------------------------------------
    // Slave AW/W capture
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!resetn) begin
            aw_seen  <= 1'b0;
            w_seen   <= 1'b0;
            awaddr_q <= {ADDR_WIDTH{1'b0}};
            wdata_q  <= 32'd0;
            wstrb_q  <= 4'd0;
            awid_q   <= 4'd0;
            wr_index <= 4'd0;
        end else begin
            // Clear when B handshake completes (use S_BREADY only — old S_BVALID
            // is still 0 on the first cycle of WR_RESP, same bug as S_RVALID)
            if (wr_state == WR_RESP && S_BREADY) begin
                aw_seen <= 1'b0;
                w_seen  <= 1'b0;
            end

            if (S_AWVALID && S_AWREADY) begin
                awaddr_q <= S_AWADDR;
                awid_q   <= S_AWID;
                wr_index <= S_AWADDR[5:2];
                aw_seen  <= 1'b1;
            end

            if (S_WVALID && S_WREADY) begin
                wdata_q <= S_WDATA;
                wstrb_q <= S_WSTRB;
                w_seen  <= 1'b1;
            end
        end
    end

    always_comb begin
        S_AWREADY = (wr_state == WR_IDLE) && !rd_busy && !aw_seen;
        S_WREADY  = (wr_state == WR_IDLE) && !rd_busy && !w_seen;
    end

    // -------------------------------------------------------------------------
    // Slave AR capture
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!resetn) begin
            araddr_q <= {ADDR_WIDTH{1'b0}};
            arid_q   <= 4'd0;
            rd_index <= 4'd0;
        end else if (S_ARVALID && S_ARREADY) begin
            araddr_q <= S_ARADDR;
            arid_q   <= S_ARID;
            rd_index <= S_ARADDR[5:2];
        end
    end

    always_comb begin
        S_ARREADY = (rd_state == RD_IDLE) && !wr_busy;
    end

    // -------------------------------------------------------------------------
    // Write FSM
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!resetn) begin
            wr_state  <= WR_IDLE;
            wr_drain_r <= 1'b0;
            M_AWADDR  <= {ADDR_WIDTH{1'b0}};
            M_AWLEN   <= 8'd0;
            M_AWSIZE  <= 3'd0;
            M_AWBURST <= 2'd0;
            M_AWPROT  <= 3'd0;
            M_AWVALID <= 1'b0;
            M_WDATA   <= 512'd0;
            M_WVALID  <= 1'b0;
            M_WLAST   <= 1'b0;
            S_BVALID  <= 1'b0;
            S_BID     <= 4'd0;
        end else begin
            M_AWVALID <= 1'b0;
            M_WVALID  <= 1'b0;
            M_WLAST   <= 1'b0;

            case (wr_state)

                WR_IDLE: begin
                    S_BVALID <= 1'b0;
                    if (aw_seen && w_seen)
                       begin 
                         wr_state <= WR_RMW_AR;
                       end
                end

                WR_RMW_AR: begin
                    if (M_ARVALID && M_ARREADY) begin
                        wr_state   <= WR_RMW_WAIT_R;
                        wr_drain_r <= M_RVALID;
                    end
                end

                WR_RMW_WAIT_R: begin
                    if (wr_drain_r) begin
                        if (M_RVALID && M_RREADY)
                           begin
                            wr_drain_r <= 1'b0;
                           end
                    end else if (M_RVALID && M_RREADY) begin
                        rmw_rdata <= M_RDATA;
                        wr_state  <= WR_SEND_AW;
                    end
                end

                WR_SEND_AW: begin
                    M_AWADDR  <= aw_line_addr;
                    M_AWLEN   <= 8'd0;
                    M_AWSIZE  <= 3'd6;
                    M_AWBURST <= 2'b01;
                    M_AWPROT  <= 3'b000;
                    M_AWVALID <= 1'b1;

                    if (M_AWVALID && M_AWREADY) begin
                        M_AWVALID <= 1'b0;
                        wr_state  <= WR_SEND_W;
                    end
                end

                WR_SEND_W: begin
                    M_WDATA  <= rmw_wdata;
                    M_WVALID <= 1'b1;
                    M_WLAST  <= 1'b1;

                    if (M_WVALID && M_WREADY) begin
                        M_WVALID <= 1'b0;
                        M_WLAST  <= 1'b0;
                        if (M_BVALID && M_BREADY)
                            begin
                             wr_state <= WR_RESP;
                            end
                        else
                            begin
                             wr_state <= WR_WAIT_B;
                            end
                    end
                end

                WR_WAIT_B: begin
                    if (M_BVALID && M_BREADY)
                        begin
                         wr_state <= WR_RESP;
                        end
                end

                WR_RESP: begin
                    S_BVALID <= 1'b1;
                    S_BID    <= awid_q;
                    if (S_BREADY)
                        begin
                         wr_state <= WR_IDLE;
                        end
                end

                default: wr_state <= WR_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Read FSM
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!resetn) begin
            rd_state   <= RD_IDLE;
            rd_drain_r <= 1'b0;
            S_RDATA  <= 32'd0;
            S_RVALID <= 1'b0;
            S_RLAST  <= 1'b0;
            S_RID    <= 4'd0;
        end else begin
            case (rd_state)

                RD_IDLE: begin
                    S_RVALID <= 1'b0;
                    S_RLAST  <= 1'b0;
                    if (S_ARVALID && S_ARREADY)
                    begin
                        rd_state <= RD_SEND_AR;
                    end
                end

                RD_SEND_AR: begin
                    if (M_ARVALID && M_ARREADY) begin
                        rd_state   <= RD_WAIT_R;
                        rd_drain_r <= M_RVALID;
                    end
                end

                RD_WAIT_R: begin
                    if (rd_drain_r) begin
                        if (M_RVALID && M_RREADY)
                        begin
                            rd_drain_r <= 1'b0;
                        end
                    end else if (M_RVALID && M_RREADY) begin
                        rd_buffer <= M_RDATA;
                        rd_state  <= RD_RESP;
                    end
                end

                RD_RESP: begin
                    case (rd_index)
                        4'd0:  S_RDATA <= rd_buffer[31:0];
                        4'd1:  S_RDATA <= rd_buffer[63:32];
                        4'd2:  S_RDATA <= rd_buffer[95:64];
                        4'd3:  S_RDATA <= rd_buffer[127:96];
                        4'd4:  S_RDATA <= rd_buffer[159:128];
                        4'd5:  S_RDATA <= rd_buffer[191:160];
                        4'd6:  S_RDATA <= rd_buffer[223:192];
                        4'd7:  S_RDATA <= rd_buffer[255:224];
                        4'd8:  S_RDATA <= rd_buffer[287:256];
                        4'd9:  S_RDATA <= rd_buffer[319:288];
                        4'd10: S_RDATA <= rd_buffer[351:320];
                        4'd11: S_RDATA <= rd_buffer[383:352];
                        4'd12: S_RDATA <= rd_buffer[415:384];
                        4'd13: S_RDATA <= rd_buffer[447:416];
                        4'd14: S_RDATA <= rd_buffer[479:448];
                        default: S_RDATA <= rd_buffer[511:480];
                    endcase

                    S_RVALID <= 1'b1;
                    S_RLAST  <= 1'b1;
                    S_RID    <= arid_q;

                    if (S_RREADY) 
                        begin
                         rd_state <= RD_IDLE;
                        end
                end

                default: begin
                    S_RVALID <= 1'b0;
                    S_RLAST  <= 1'b0;
                    rd_state <= RD_IDLE;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Shared master AR (RREADY is combinational above)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!resetn) begin
            M_ARADDR  <= {ADDR_WIDTH{1'b0}};
            M_ARLEN   <= 8'd0;
            M_ARSIZE  <= 3'd0;
            M_ARBURST <= 2'd0;
            M_ARPROT  <= 3'd0;
            M_ARVALID <= 1'b0;
        end else begin
            M_ARVALID <= 1'b0;

            if (wr_state == WR_RMW_AR) begin
                M_ARADDR  <= aw_line_addr;
                M_ARLEN   <= 8'd0;
                M_ARSIZE  <= 3'd6;
                M_ARBURST <= 2'b01;
                M_ARPROT  <= 3'b000;
                M_ARVALID <= 1'b1;
            end
            else if (rd_state == RD_SEND_AR) begin
                M_ARADDR  <= ar_line_addr;
                M_ARLEN   <= 8'd0;
                M_ARSIZE  <= 3'd6;
                M_ARBURST <= 2'b01;
                M_ARPROT  <= 3'b000;
                M_ARVALID <= 1'b1;
            end
        end
    end

endmodule

`resetall

