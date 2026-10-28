// Copyright 2025 Altera Corporation.
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

// Byte-packing bridge from AXI-Stream (with TSTRB) to Avalon-ST.
//
// AXI-Stream may deliver partial beats where only some bytes are valid
// (indicated by TSTRB).  This bridge strips the invalid bytes and packs
// the valid ones contiguously into full-width Avalon-ST beats.
//
// PRODUCER CONTRACT (enforced structurally by dla_output_streamer):
//   - axi_tstrb is always all-ones except on the final beat of a packet,
//     where it is (1 << k) - 1 for some k <= DATA_WIDTH/8.  In other words
//     TSTRB is contiguous from bit 0; sparse strobes are not permitted.
//     This permits the simple "append at count + i" packing logic below
//     (see dla_output_streamer.sv strb_signal_normal/_last; covered by
//     the streamer's UVM scoreboard model comparison).
//   - axi_tlast is asserted only on a beat with axi_tvalid=1 and at least
//     one valid byte.  An empty packet (tlast on a zero-strobe beat with
//     empty accumulator) is not permitted; the packer would otherwise
//     latch flushing_r without ever generating a draining output beat.
//
// On TLAST, any residual bytes in the accumulator are flushed as a single
// zero-padded partial beat so the downstream consumer sees a clean packet
// boundary.  The host-side software is responsible for trimming the
// trailing pad bytes back to the model's logical output size.
//
// Architecture:
//   The module is split into two stages:
//
//     1. Input skid buffer (2 slots).  Absorbs one AXI beat of backpressure
//        latency so the master-facing axi_tready can be driven from a flop
//        rather than combinationally.  This removes the cross-module
//        ready-to-ready combinational path (avst_ready -> axi_tready) and
//        also keeps axi_tstrb out of the axi_tready fan-in.  axi_tready
//        is asserted whenever the skid will have room for another beat
//        next cycle; the 2-slot depth keeps throughput at one beat per
//        cycle in the steady state (one beat in, one beat out).
//
//     2. Packer core.  A double-wide accumulator (2 * DATA_WIDTH bits)
//        absorbs incoming valid bytes at an append pointer (count_r).
//        When at least DATA_WIDTH/8 bytes have been collected, the lower
//        DATA_WIDTH bits are emitted on Avalon-ST and the upper half
//        shifts down.  The 2x width guarantees that a new beat can always
//        be absorbed in the same cycle an output beat is emitted,
//        preventing pipeline bubbles.
//
//        State is computed in two phases each cycle:
//          a. "after_out" -- retire the bottom word if an output handshake
//             fires.
//          b. "next"      -- append new input bytes on top of the
//             after_out state, by left-shifting the input by
//             count_after_out bytes (a single barrel shifter shared with
//             the strobe) and merging into accum_after_out under a
//             per-byte enable derived from the shifted strobe.
//
//   Latency impact of the skid: a beat driven on axi_tdata/tstrb/tvalid is
//   visible to the packer core one cycle later, and flow-control changes
//   on the core's internal ready propagate back out to axi_tready with
//   one cycle of additional delay.  avst_valid/avst_data timing is
//   unchanged.  This 1-cycle bubble is benign for the streaming use case:
//   the egress SGDMA terminates a transfer on byte count, not on cycle
//   alignment, and the DLA's inference-count CSR is driven from internal
//   completion logic that does not depend on the bridge.

`default_nettype none

module axi_st_to_avalon_st_bridge #(
    parameter DATA_WIDTH = 128
) (
    input  wire                      clk,
    input  wire                      resetn,

    // AXI-Stream subordinate (sink)
    input  wire  [DATA_WIDTH-1:0]    axi_tdata,
    input  wire  [DATA_WIDTH/8-1:0]  axi_tstrb,  // byte-lane valid (must be contiguous from bit 0)
    input  wire                      axi_tvalid,
    output logic                     axi_tready,
    input  wire                      axi_tlast,   // end-of-packet

    // Avalon-ST source
    output logic [DATA_WIDTH-1:0]    avst_data,
    output logic                     avst_valid,
    input  wire                      avst_ready
);

    localparam BYTE_WIDTH  = DATA_WIDTH / 8;       // bytes per beat
    localparam ACCUM_BYTES = BYTE_WIDTH * 2;        // 2x capacity so input + residual always fits
    localparam ACCUM_WIDTH = ACCUM_BYTES * 8;
    localparam CNT_WIDTH   = $clog2(ACCUM_BYTES + 1);

    // ================================================================
    //  Reset synchronizer (asynchronous assert, synchronous deassert)
    //
    //  The incoming resetn is a board-level reset (in the platform top it
    //  is global_resetn & iopll_lock) that is NOT synchronized to clk --
    //  iopll_lock in particular originates in a different PLL domain than
    //  clk.  Feeding it straight into the datapath flops lets the reset
    //  *deassertion* edge violate recovery/removal, so different flops can
    //  leave reset on different clk edges and the recovering flops can go
    //  metastable -- bringing the skid buffer up in an inconsistent
    //  valid/ready state at startup.
    //
    //  This synchronizer keeps the assertion asynchronous (reset still
    //  takes effect immediately on the incoming edge) but makes the
    //  deassertion synchronous to clk: a short flop chain, async-cleared
    //  by the raw resetn and shifting in 1, so every datapath flop leaves
    //  reset on the same clk edge.  Downstream logic uses resetn_sync.
    //
    //  Note: the raw resetn still crosses PLL domains into the async-clear
    //  of the first stage here; that inter-PLL relationship is declared in
    //  post_pll_clock_groups.sdc (set_clock_groups -asynchronous), which
    //  remains required.
    // ================================================================
    localparam int RESET_SYNC_STAGES = 3;
    logic [RESET_SYNC_STAGES-1:0] resetn_sync_r;
    logic                         resetn_sync;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) resetn_sync_r <= '0;
        else         resetn_sync_r <= {resetn_sync_r[RESET_SYNC_STAGES-2:0], 1'b1};
    end
    assign resetn_sync = resetn_sync_r[RESET_SYNC_STAGES-1];

    // ================================================================
    //  Stage 1: Input skid buffer
    //  Two registered slots with registered axi_tready.
    //    - data_r / data_v_r: head slot, presented to the packer core.
    //    - skid_r / skid_v_r: overflow slot, populated only when the core
    //      is stalled while a new beat arrives.
    //    - Invariant: skid_v_r implies data_v_r (skid is never used
    //      without head).
    //  axi_tready goes low only when both slots will be full next cycle.
    // ================================================================

    // Packer-core-facing signals (head of skid)
    logic [DATA_WIDTH-1:0]   int_tdata;
    logic [DATA_WIDTH/8-1:0] int_tstrb;
    logic                    int_tvalid;
    logic                    int_tready;   // combinational, driven by packer core
    logic                    int_tlast;

    // Head + overflow storage and their valid bits.
    logic [DATA_WIDTH-1:0]   data_r;
    logic [DATA_WIDTH/8-1:0] data_strb_r;
    logic                    data_last_r;
    logic                    data_v_r;

    logic [DATA_WIDTH-1:0]   skid_r;
    logic [DATA_WIDTH/8-1:0] skid_strb_r;
    logic                    skid_last_r;
    logic                    skid_v_r;

    assign int_tdata  = data_r;
    assign int_tstrb  = data_strb_r;
    assign int_tlast  = data_last_r;
    assign int_tvalid = data_v_r;

    // In-flight handshakes this cycle
    wire skid_accept  = axi_tready && axi_tvalid;  // master -> skid
    wire skid_consume = int_tvalid && int_tready;  // skid   -> core

    // Next-cycle "skid full" status, used to drive registered axi_tready.
    // Skid is full next cycle iff:
    //   - it was full this cycle and the core is not draining, OR
    //   - it was not full but a beat is arriving while the head is full and
    //     the core is not draining (so the new beat must land in overflow).
    //
    // Note: the case (skid_v_r=1, skid_accept=1) cannot occur.  When skid is
    // full this cycle, axi_tready was driven low last cycle by skid_full_nxt,
    // so the master sees axi_tready=0 and skid_accept = axi_tready & axi_tvalid
    // is also 0.  We therefore don't need to consider it.
    logic skid_full_nxt;
    always_comb begin
        skid_full_nxt = skid_v_r;
        if (skid_v_r && skid_consume) begin
            skid_full_nxt = 1'b0;  // overflow promoted to head this cycle
        end else if (!skid_v_r && skid_accept && data_v_r && !skid_consume) begin
            skid_full_nxt = 1'b1;  // new beat fills the overflow slot
        end
    end

    always_ff @(posedge clk or negedge resetn_sync) begin
        if (!resetn_sync) begin
            data_v_r    <= 1'b0;
            skid_v_r    <= 1'b0;
            axi_tready  <= 1'b0;
        end else begin
            // Registered ready: assert whenever the skid will have room
            // for one more beat next cycle.
            axi_tready <= !skid_full_nxt;

            // Update head/overflow storage based on this cycle's accept/
            // consume handshakes.  Reachable {data_v_r, skid_v_r} states are
            // (0,0), (1,0) and (1,1); see the skid_full_nxt note for why
            // (skid_v_r=1, skid_accept=1) cannot occur (so case 2'b11 always
            // sees skid_v_r=0 and case 2'b10 with data_v_r=1 always sees
            // skid_v_r=0 too).
            unique case ({skid_accept, skid_consume})
                2'b00: ; // hold
                2'b01: begin
                    // Drain only.  Promote overflow to head if it exists;
                    // otherwise the head goes empty.
                    if (skid_v_r) begin
                        data_r       <= skid_r;
                        data_strb_r  <= skid_strb_r;
                        data_last_r  <= skid_last_r;
                        skid_v_r     <= 1'b0;
                    end else begin
                        data_v_r     <= 1'b0;
                    end
                end
                2'b10: begin
                    // Fill only.  Land the new beat in the empty slot.
                    // skid_v_r is guaranteed 0 here (see note above).
                    if (!data_v_r) begin
                        data_r       <= axi_tdata;
                        data_strb_r  <= axi_tstrb;
                        data_last_r  <= axi_tlast;
                        data_v_r     <= 1'b1;
                    end else begin
                        skid_r       <= axi_tdata;
                        skid_strb_r  <= axi_tstrb;
                        skid_last_r  <= axi_tlast;
                        skid_v_r     <= 1'b1;
                    end
                end
                2'b11: begin
                    // Simultaneous fill + drain.  skid_v_r is guaranteed 0
                    // here (the (1,1)+accept state is unreachable), so the
                    // head is the only beat present and we replace it
                    // directly with the incoming beat.
                    data_r       <= axi_tdata;
                    data_strb_r  <= axi_tstrb;
                    data_last_r  <= axi_tlast;
                end
            endcase
        end
    end

    // ================================================================
    //  Stage 2: Packer core
    // ================================================================

    logic [ACCUM_WIDTH-1:0] accum_r;    // byte accumulator (valid data packed from LSB)
    logic [CNT_WIDTH-1:0]   count_r;    // number of valid bytes currently in accum_r
    logic                   flushing_r; // set on TLAST; drains residual bytes then clears

    // Popcount of TSTRB gives the number of valid bytes in this AXI beat.
    // Because TSTRB is contiguous from bit 0, popcount == (highest set
    // strobe index) + 1.
    logic [CNT_WIDTH-1:0] num_valid_bytes;
    always_comb begin
        num_valid_bytes = '0;
        for (int i = 0; i < BYTE_WIDTH; i++) begin
            num_valid_bytes = num_valid_bytes + {{(CNT_WIDTH-1){1'b0}}, int_tstrb[i]};
        end
    end

    // ---------- Output handshake ----------
    // Emit a beat when:
    //   - Normal mode: a full word (BYTE_WIDTH bytes) has accumulated.
    //   - Flush mode:  any residual bytes remain (they go out zero-padded).
    assign avst_valid = (count_r >= CNT_WIDTH'(BYTE_WIDTH)) ||
                        (flushing_r && (count_r != '0));
    assign avst_data  = accum_r[DATA_WIDTH-1:0];

    // ---------- Phase 1: state after output retirement ----------
    // If an output handshake fires this cycle, shift the accumulator down
    // by one word and decrement the count.  This produces the "baseline"
    // state that the input-append logic builds on.
    logic [CNT_WIDTH-1:0]   count_after_out;
    logic [ACCUM_WIDTH-1:0] accum_after_out;
    logic                   flush_done;

    always_comb begin
        if (avst_valid && avst_ready) begin
            if (count_r >= CNT_WIDTH'(BYTE_WIDTH)) begin
                // Full-word emit: shift upper half down, subtract one word from count.
                count_after_out = count_r - CNT_WIDTH'(BYTE_WIDTH);
                accum_after_out = {{DATA_WIDTH{1'b0}}, accum_r[ACCUM_WIDTH-1:DATA_WIDTH]};
            end else begin
                // Partial flush beat: accumulator is fully drained.
                count_after_out = '0;
                accum_after_out = '0;
            end
        end else begin
            count_after_out = count_r;
            accum_after_out = accum_r;
        end
        flush_done = avst_valid && avst_ready && flushing_r && (count_after_out == '0);
    end

    // ---------- Input backpressure (packer-core internal) ----------
    // Accept a new beat from the skid only when:
    //   - Not in flush mode (packet boundary must complete first).
    //   - The post-output accumulator has room for the incoming valid bytes
    //     without exceeding the 2x buffer capacity.
    // Note: this signal does not leave the module.  The cross-module
    // ready-to-ready combinational path is broken by the skid stage.
    assign int_tready = !flushing_r &&
                        ((count_after_out + num_valid_bytes) <= CNT_WIDTH'(ACCUM_BYTES));

    // ---------- Phase 2: state after input append ----------
    //
    // Append new valid bytes at byte offset count_after_out within the
    // accumulator.  Rather than one-byte-at-a-time variable-position
    // writes (which synthesise to a 16-output, count_after_out-selected
    // crossbar), we form the merge as:
    //
    //   shifted_data = (zero-extend int_tdata) << (count_after_out * 8)
    //   shifted_strb = (zero-extend int_tstrb) <<  count_after_out
    //   for each accumulator byte k:
    //       next_accum[k] = shifted_strb[k] ? shifted_data[k] : accum_after_out[k]
    //
    // The shift is a single barrel shifter shared between data and strobe;
    // the per-byte mux is fixed-position and shallow.  Functionally
    // identical to the lane-by-lane formulation but easier on synthesis
    // and on a human reader.
    logic [ACCUM_WIDTH-1:0]            shifted_data;
    logic [ACCUM_BYTES-1:0]            shifted_strb;
    logic [ACCUM_WIDTH-1:0]            merged_accum;
    // Shift amount in bits is count_after_out * 8; build it by concatenating
    // 3 zero bits onto count_after_out so the expression is wide enough to
    // express the maximum shift (ACCUM_BYTES * 8 = ACCUM_WIDTH bits).
    logic [CNT_WIDTH+2:0]              shift_bits;

    always_comb begin
        shift_bits   = {count_after_out, 3'b000};
        shifted_data = ACCUM_WIDTH'(int_tdata) << shift_bits;
        shifted_strb = ACCUM_BYTES'(int_tstrb) << count_after_out;
        for (int k = 0; k < ACCUM_BYTES; k++) begin
            merged_accum[k*8 +: 8] = shifted_strb[k] ? shifted_data[k*8 +: 8]
                                                     : accum_after_out[k*8 +: 8];
        end
    end

    logic [ACCUM_WIDTH-1:0] next_accum;
    logic [CNT_WIDTH-1:0]   next_count;
    logic                   next_flushing;

    always_comb begin
        if (int_tvalid && int_tready) begin
            // int_tready implies !flushing_r (see int_tready definition above),
            // so flush_done cannot fire in this branch and flushing_r is 0.
            // Therefore next_flushing collapses to just int_tlast.
            next_accum    = merged_accum;
            next_count    = count_after_out + num_valid_bytes;
            next_flushing = int_tlast;
        end else begin
            next_accum    = accum_after_out;
            next_count    = count_after_out;
            next_flushing = flush_done ? 1'b0 : flushing_r;
        end
    end

    // ---------- Registered state ----------
    always_ff @(posedge clk or negedge resetn_sync) begin
        if (!resetn_sync) begin
            accum_r    <= '0;
            count_r    <= '0;
            flushing_r <= 1'b0;
        end else begin
            accum_r    <= next_accum;
            count_r    <= next_count;
            flushing_r <= next_flushing;
        end
    end

endmodule

`default_nettype wire
