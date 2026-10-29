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

// Black-box testbench for axi_st_to_avalon_st_bridge.
//
// Treats the DUT as a pure input/output contract: AXI-Stream bytes in
// (gated by TSTRB) must appear packed and in-order on Avalon-ST, with
// zero-padded flush beats on TLAST boundaries.
//
// Every test pushes expected bytes into a golden queue, drives stimulus,
// and lets a cycle-accurate monitor compare each output beat.  Protocol
// assertions check Avalon-ST valid/data stability independently.

`resetall
`undefineall
`timescale 1ns/1ps
`default_nettype none

module tb_axi_st_to_avalon_st_bridge;

    localparam DATA_WIDTH  = 128;
    localparam BYTE_WIDTH  = DATA_WIDTH / 8;   // 16
    localparam CLK_PERIOD  = 10;

    // ================================================================
    //  Clock & reset
    // ================================================================
    logic clk = 1'b0;
    logic resetn;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ================================================================
    //  DUT signals
    // ================================================================
    logic [DATA_WIDTH-1:0]  axi_tdata;
    logic [BYTE_WIDTH-1:0]  axi_tstrb;
    logic                   axi_tvalid;
    wire                    axi_tready;
    logic                   axi_tlast;

    wire  [DATA_WIDTH-1:0]  avst_data;
    wire                    avst_valid;
    logic                   avst_ready;

    // ================================================================
    //  DUT
    // ================================================================
    axi_st_to_avalon_st_bridge #(
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .clk        (clk),
        .resetn     (resetn),
        .axi_tdata  (axi_tdata),
        .axi_tstrb  (axi_tstrb),
        .axi_tvalid (axi_tvalid),
        .axi_tready (axi_tready),
        .axi_tlast  (axi_tlast),
        .avst_data  (avst_data),
        .avst_valid (avst_valid),
        .avst_ready (avst_ready)
    );

    // ================================================================
    //  Test infrastructure
    // ================================================================
    int  error_count    = 0;
    int  test_count     = 0;
    int  pass_count     = 0;
    int  received_beats = 0;
    int  byte_seq       = 0;    // running counter for unique byte values
    int  test_err_snap;
    string test_name_s;

    byte expected_queue[$];
    int  pkt_byte_count;
    bit  monitor_enabled = 1;

    // ================================================================
    //  Protocol assertions (port-level only — true black-box checks)
    // ================================================================

    // Avalon-ST source must not drop valid without a handshake
    property p_avst_valid_hold;
        @(posedge clk) disable iff (!resetn)
        (avst_valid && !avst_ready) |=> avst_valid;
    endproperty
    assert property (p_avst_valid_hold) else begin
        $error("PROTOCOL: avst_valid dropped without handshake at t=%0t", $time);
        error_count++;
    end

    // Avalon-ST source must hold data stable while valid && !ready
    property p_avst_data_hold;
        @(posedge clk) disable iff (!resetn)
        (avst_valid && !avst_ready) |=> (avst_data === $past(avst_data));
    endproperty
    assert property (p_avst_data_hold) else begin
        $error("PROTOCOL: avst_data changed while valid && !ready at t=%0t", $time);
        error_count++;
    end

    // ================================================================
    //  Output monitor — byte-level comparison against golden queue
    // ================================================================
    always @(posedge clk) begin
        if (resetn && monitor_enabled && avst_valid && avst_ready) begin
            automatic logic [7:0] act_byte, exp_byte;
            received_beats++;
            if (expected_queue.size() == 0) begin
                $error("MONITOR: unexpected beat #%0d (queue empty) at t=%0t",
                       received_beats, $time);
                error_count++;
            end else begin
                for (int i = 0; i < BYTE_WIDTH; i++) begin
                    act_byte = avst_data[i*8 +: 8];
                    if (expected_queue.size() > 0) begin
                        exp_byte = 8'(expected_queue.pop_front());
                        if (act_byte !== exp_byte) begin
                            $error("MONITOR: beat #%0d byte %0d: got 0x%02h expected 0x%02h",
                                   received_beats, i, act_byte, exp_byte);
                            error_count++;
                        end
                    end else begin
                        $error("MONITOR: beat #%0d byte %0d: expected queue underflow",
                               received_beats, i);
                        error_count++;
                    end
                end
            end
        end
    end

    // ================================================================
    //  Helper functions / tasks
    // ================================================================

    // Sequential byte pattern from a base value (wraps at 8 bits)
    function automatic [DATA_WIDTH-1:0] make_data(int base);
        logic [DATA_WIDTH-1:0] d;
        for (int i = 0; i < BYTE_WIDTH; i++)
            d[i*8 +: 8] = 8'(base + i);
        return d;
    endfunction

    // Contiguous strobe: 'width' ones from bit 0
    function automatic [BYTE_WIDTH-1:0] make_strobe(int width);
        logic [BYTE_WIDTH-1:0] s = '0;
        for (int i = 0; i < width && i < BYTE_WIDTH; i++)
            s[i] = 1'b1;
        return s;
    endfunction

    // --- Packet-level expected-value tracking ---

    task automatic begin_packet();
        pkt_byte_count = 0;
    endtask

    task automatic push_expected(input [DATA_WIDTH-1:0] data,
                                  input [BYTE_WIDTH-1:0] strb);
        for (int i = 0; i < BYTE_WIDTH; i++)
            if (strb[i]) begin
                expected_queue.push_back(data[i*8 +: 8]);
                pkt_byte_count++;
            end
    endtask

    // Zero-pad queue to the next BYTE_WIDTH boundary (flush-beat padding)
    task automatic end_packet();
        int remainder;
        remainder = pkt_byte_count % BYTE_WIDTH;
        if (remainder != 0)
            repeat (BYTE_WIDTH - remainder) expected_queue.push_back(8'h00);
    endtask

    // --- Stimulus helpers ---

    task automatic send_beat(input [DATA_WIDTH-1:0] data,
                              input [BYTE_WIDTH-1:0] strb,
                              input logic            last);
        int timeout = 2000;
        #1;
        axi_tdata  = data;
        axi_tstrb  = strb;
        axi_tlast  = last;
        axi_tvalid = 1'b1;
        @(posedge clk);
        while (!axi_tready) begin
            if (--timeout == 0) begin
                $error("send_beat: TIMEOUT waiting for axi_tready at t=%0t", $time);
                error_count++;
                axi_tvalid = 1'b0;
                return;
            end
            @(posedge clk);
        end
    endtask

    // Push golden bytes AND send in one call — keeps model + stimulus in sync
    task automatic push_and_send(input [DATA_WIDTH-1:0] data,
                                  input [BYTE_WIDTH-1:0] strb,
                                  input logic            last);
        push_expected(data, strb);
        send_beat(data, strb, last);
    endtask

    task automatic idle_input();
        #1;
        axi_tvalid = 1'b0;
        axi_tlast  = 1'b0;
        axi_tstrb  = '0;
    endtask

    task automatic wait_drain();
        int timeout = 3000;
        while (expected_queue.size() > 0 && timeout > 0) begin
            @(posedge clk);
            timeout--;
        end
        if (expected_queue.size() > 0) begin
            $error("DRAIN TIMEOUT: %0d expected bytes remaining at t=%0t",
                   expected_queue.size(), $time);
            error_count += expected_queue.size();
            expected_queue.delete();
        end
        repeat (5) @(posedge clk);
    endtask

    task automatic reset_dut();
        axi_tvalid = 1'b0;
        axi_tlast  = 1'b0;
        axi_tstrb  = '0;
        axi_tdata  = '0;
        avst_ready = 1'b1;
        resetn     = 1'b0;
        expected_queue.delete();
        monitor_enabled = 1;
        repeat (5) @(posedge clk);
        resetn = 1'b1;
        repeat (2) @(posedge clk);
    endtask

    // --- Test bookkeeping ---

    task automatic begin_test(string name);
        test_count++;
        test_err_snap = error_count;
        test_name_s   = name;
        $display("[TEST %0d] %s: starting ...", test_count, name);
    endtask

    task automatic end_test();
        if (error_count > test_err_snap)
            $display("[TEST %0d] %s: FAIL (%0d errors)\n",
                     test_count, test_name_s, error_count - test_err_snap);
        else begin
            pass_count++;
            $display("[TEST %0d] %s: PASS\n", test_count, test_name_s);
        end
    endtask

    // ================================================================
    //  GROUP A — Basic strobe widths
    // ================================================================

    task automatic test_full_strobe_passthrough();
        localparam N = 10;
        begin_test("Full-strobe passthrough (10 beats)");
        begin_packet();
        for (int b = 0; b < N; b++) begin
            push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, (b == N-1));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_half_strobe();
        localparam N = 8;
        begin_test("Half-strobe packing (8 beats, 8B each)");
        begin_packet();
        for (int b = 0; b < N; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(BYTE_WIDTH/2), (b == N-1));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_quarter_strobe();
        localparam N = 16;
        begin_test("Quarter-strobe packing (16 beats, 4B each)");
        begin_packet();
        for (int b = 0; b < N; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(BYTE_WIDTH/4), (b == N-1));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_single_byte_beats();
        begin_test("Single-byte strobe (16 x 1B -> 1 full output)");
        begin_packet();
        for (int b = 0; b < BYTE_WIDTH; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(1), (b == BYTE_WIDTH-1));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_varying_strobes();
        begin_test("Varying strobe widths (1B,2B,...,16B in one packet)");
        begin_packet();
        for (int b = 0; b < BYTE_WIDTH; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(b + 1),
                          (b == BYTE_WIDTH - 1));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  GROUP B — TLAST / flush edge cases
    // ================================================================

    task automatic test_single_beat_full();
        begin_test("Single-beat packet, full strobe");
        begin_packet();
        push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_single_beat_partial();
        begin_test("Single-beat packet, half strobe (flush)");
        begin_packet();
        push_and_send(make_data(byte_seq), make_strobe(BYTE_WIDTH/2), 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_single_byte_packet();
        begin_test("Single-byte packet (1B valid + 15B zero pad)");
        begin_packet();
        push_and_send(make_data(byte_seq), make_strobe(1), 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // Partial strobes sum to exactly BYTE_WIDTH — should emit a full beat
    // with NO extra flush beat.
    task automatic test_exact_fill_no_residual();
        begin_test("Exact fill, no residual (4 x 4B = 16B)");
        begin_packet();
        for (int b = 0; b < 4; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(4), (b == 3));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // Exact multiple of two full words — verifies accumulator shift path
    task automatic test_exact_fill_multi_word();
        begin_test("Exact multi-word fill (8 x 4B = 32B = 2 beats)");
        begin_packet();
        for (int b = 0; b < 8; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(4), (b == 7));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // Maximum-size residual: BYTE_WIDTH-1 valid bytes → only 1 byte of padding
    task automatic test_near_full_residual();
        begin_test("Near-full residual (15B + 1 zero pad)");
        begin_packet();
        push_and_send(make_data(byte_seq), make_strobe(BYTE_WIDTH - 1), 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // Two full beats then 1 valid byte → flush with maximum padding
    task automatic test_one_byte_residual();
        begin_test("1-byte residual after 2 full beats");
        begin_packet();
        push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b0);
        byte_seq += BYTE_WIDTH;
        push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b0);
        byte_seq += BYTE_WIDTH;
        push_and_send(make_data(byte_seq), make_strobe(1), 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  GROUP C — Multi-packet sequences
    // ================================================================

    // Packet A (partial strobe, flush) immediately followed by packet B (full).
    // The DUT must complete the flush before accepting the next packet.
    task automatic test_back_to_back_packets();
        begin_test("Back-to-back packets (partial then full, no idle)");

        // Packet A: 3 x 4B = 12B → 1 flush beat (12B + 4 zeros)
        begin_packet();
        for (int b = 0; b < 3; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(4), (b == 2));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();

        // Packet B: 2 x 16B = 32B → 2 full beats
        begin_packet();
        for (int b = 0; b < 2; b++) begin
            push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, (b == 1));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();

        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_three_diverse_packets();
        begin_test("Three diverse back-to-back packets");

        // Packet 1: single full beat
        begin_packet();
        push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();

        // Packet 2: 5 x 4B = 20B → 1 full + 1 flush (4B + 12 zeros)
        begin_packet();
        for (int b = 0; b < 5; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(4), (b == 4));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();

        // Packet 3: 3 x 8B = 24B → 1 full + 1 flush (8B + 8 zeros)
        begin_packet();
        for (int b = 0; b < 3; b++) begin
            push_and_send(make_data(byte_seq), make_strobe(8), (b == 2));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();

        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_many_tiny_packets();
        begin_test("20 single-beat partial packets in rapid succession");
        for (int p = 0; p < 20; p++) begin
            begin_packet();
            push_and_send(make_data(byte_seq), make_strobe(4), 1'b1);
            byte_seq += BYTE_WIDTH;
            end_packet();
        end
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_many_single_byte_packets();
        begin_test("10 single-byte packets (maximum flush padding each)");
        for (int p = 0; p < 10; p++) begin
            begin_packet();
            push_and_send(make_data(byte_seq), make_strobe(1), 1'b1);
            byte_seq += BYTE_WIDTH;
            end_packet();
        end
        idle_input();
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  GROUP D — Backpressure
    // ================================================================

    task automatic test_bp_toggle();
        localparam N = 8;
        begin_test("Backpressure toggle (1on/1off) + full strobe");
        begin_packet();
        for (int b = 0; b < N; b++)
            push_expected(make_data(byte_seq + b * BYTE_WIDTH), {BYTE_WIDTH{1'b1}});
        end_packet();

        fork
            begin : bp
                forever begin
                    avst_ready = 1'b1; @(posedge clk);
                    avst_ready = 1'b0; @(posedge clk);
                end
            end
            begin : stim
                for (int b = 0; b < N; b++)
                    send_beat(make_data(byte_seq + b * BYTE_WIDTH),
                              {BYTE_WIDTH{1'b1}}, (b == N-1));
                byte_seq += N * BYTE_WIDTH;
                idle_input();
            end
        join_any
        disable bp;
        avst_ready = 1'b1;
        wait_drain();
        end_test();
    endtask

    task automatic test_bp_extended_stall();
        localparam N = 4;
        begin_test("Backpressure extended stall (50 cycles off, then on)");
        begin_packet();
        for (int b = 0; b < N; b++)
            push_expected(make_data(byte_seq + b * BYTE_WIDTH), {BYTE_WIDTH{1'b1}});
        end_packet();

        fork
            begin : bp
                avst_ready = 1'b0;
                repeat (50) @(posedge clk);
                avst_ready = 1'b1;
                forever @(posedge clk);
            end
            begin : stim
                for (int b = 0; b < N; b++)
                    send_beat(make_data(byte_seq + b * BYTE_WIDTH),
                              {BYTE_WIDTH{1'b1}}, (b == N-1));
                byte_seq += N * BYTE_WIDTH;
                idle_input();
            end
        join_any
        disable bp;
        avst_ready = 1'b1;
        wait_drain();
        end_test();
    endtask

    task automatic test_bp_during_flush();
        localparam N = 3;
        begin_test("Backpressure deasserted during flush");
        begin_packet();
        for (int b = 0; b < N; b++)
            push_expected(make_data(byte_seq + b * BYTE_WIDTH), make_strobe(4));
        end_packet();

        fork
            begin : bp
                avst_ready = 1'b1;
                repeat (8) @(posedge clk);   // let input in
                avst_ready = 1'b0;
                repeat (30) @(posedge clk);  // stall during flush
                avst_ready = 1'b1;
                forever @(posedge clk);
            end
            begin : stim
                for (int b = 0; b < N; b++)
                    send_beat(make_data(byte_seq + b * BYTE_WIDTH),
                              make_strobe(4), (b == N-1));
                byte_seq += N * BYTE_WIDTH;
                idle_input();
            end
        join_any
        disable bp;
        avst_ready = 1'b1;
        wait_drain();
        end_test();
    endtask

    task automatic test_bp_bursty_partial();
        localparam N = 12;
        begin_test("Bursty backpressure (3on/5off) + partial strobe");
        begin_packet();
        for (int b = 0; b < N; b++)
            push_expected(make_data(byte_seq + b * BYTE_WIDTH), make_strobe(8));
        end_packet();

        fork
            begin : bp
                forever begin
                    repeat (3) begin avst_ready = 1'b1; @(posedge clk); end
                    repeat (5) begin avst_ready = 1'b0; @(posedge clk); end
                end
            end
            begin : stim
                for (int b = 0; b < N; b++)
                    send_beat(make_data(byte_seq + b * BYTE_WIDTH),
                              make_strobe(8), (b == N-1));
                byte_seq += N * BYTE_WIDTH;
                idle_input();
            end
        join_any
        disable bp;
        avst_ready = 1'b1;
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  GROUP E — Input timing
    // ================================================================

    task automatic test_input_gaps();
        localparam N = 6;
        begin_test("Input gaps (3 idle cycles between each beat)");
        begin_packet();
        for (int b = 0; b < N; b++) begin
            push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, (b == N-1));
            byte_seq += BYTE_WIDTH;
            if (b < N-1) begin
                idle_input();
                repeat (3) @(posedge clk);
            end
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_bursty_io_and_bp();
        localparam N = 10;
        begin_test("Bursty input + backpressure combined");
        begin_packet();
        for (int b = 0; b < N; b++)
            push_expected(make_data(byte_seq + b * BYTE_WIDTH), make_strobe(8));
        end_packet();

        fork
            begin : bp
                forever begin
                    repeat (2) begin avst_ready = 1'b1; @(posedge clk); end
                    repeat (2) begin avst_ready = 1'b0; @(posedge clk); end
                end
            end
            begin : stim
                for (int b = 0; b < N; b++) begin
                    send_beat(make_data(byte_seq + b * BYTE_WIDTH),
                              make_strobe(8), (b == N-1));
                    if (b % 3 == 2) begin
                        idle_input();
                        repeat (4) @(posedge clk);
                    end
                end
                byte_seq += N * BYTE_WIDTH;
                idle_input();
            end
        join_any
        disable bp;
        avst_ready = 1'b1;
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  GROUP F — Corner cases
    // ================================================================

    // Verify the DUT produces nothing when idle
    task automatic test_quiescence();
        int beats_before;
        begin_test("Quiescence: no input -> no output (100 cycles)");
        idle_input();
        beats_before = received_beats;
        repeat (100) @(posedge clk);
        if (received_beats != beats_before) begin
            $error("Spurious output: %0d beats with no input",
                   received_beats - beats_before);
            error_count++;
        end
        end_test();
    endtask

    // tstrb=0 mid-packet should be a transparent no-op
    task automatic test_zero_strobe_noop();
        begin_test("Zero-strobe beat mid-packet (no-op)");
        begin_packet();
        push_and_send(make_data(byte_seq), make_strobe(4), 1'b0);
        byte_seq += BYTE_WIDTH;
        // Zero-strobe beat: accepted but contributes 0 bytes
        push_and_send(make_data(byte_seq), make_strobe(0), 1'b0);
        byte_seq += BYTE_WIDTH;
        push_and_send(make_data(byte_seq), make_strobe(4), 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // TLAST driven while TVALID is low should be ignored by the DUT
    task automatic test_tlast_without_tvalid();
        begin_test("TLAST asserted without TVALID (should be ignored)");
        #1;
        axi_tlast  = 1'b1;
        axi_tvalid = 1'b0;
        axi_tstrb  = {BYTE_WIDTH{1'b1}};
        axi_tdata  = '1;
        repeat (10) @(posedge clk);
        idle_input();

        // Verify DUT is still functional
        begin_packet();
        push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // Verify accumulator fills completely (32 bytes) under backpressure
    // and then drains correctly when ready returns
    task automatic test_accumulator_full();
        begin_test("Accumulator full (2 full beats stalled, then drain)");
        begin_packet();
        push_expected(make_data(byte_seq),              {BYTE_WIDTH{1'b1}});
        push_expected(make_data(byte_seq + BYTE_WIDTH), {BYTE_WIDTH{1'b1}});
        end_packet();

        avst_ready = 1'b0;
        send_beat(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b0);
        byte_seq += BYTE_WIDTH;
        send_beat(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b1);
        byte_seq += BYTE_WIDTH;
        idle_input();

        // Now release: both beats should drain
        repeat (5) @(posedge clk);
        avst_ready = 1'b1;
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  GROUP G — Reset recovery
    // ================================================================

    task automatic test_reset_mid_transfer();
        begin_test("Reset mid-transfer (data in accumulator lost)");
        monitor_enabled = 0;
        for (int b = 0; b < 3; b++) begin
            send_beat(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b0);
            byte_seq += BYTE_WIDTH;
        end
        idle_input();

        reset_dut();
        monitor_enabled = 1;

        // Clean recovery — a normal packet must work
        begin_packet();
        for (int b = 0; b < 2; b++) begin
            push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, (b == 1));
            byte_seq += BYTE_WIDTH;
        end
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    task automatic test_reset_during_flush();
        begin_test("Reset during flush");
        monitor_enabled = 0;
        for (int b = 0; b < 3; b++) begin
            send_beat(make_data(byte_seq), make_strobe(4), (b == 2));
            byte_seq += BYTE_WIDTH;
        end
        idle_input();
        repeat (2) @(posedge clk);

        reset_dut();
        monitor_enabled = 1;

        begin_packet();
        push_and_send(make_data(byte_seq), {BYTE_WIDTH{1'b1}}, 1'b1);
        byte_seq += BYTE_WIDTH;
        end_packet();
        idle_input();
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  GROUP H — Constrained random stress
    // ================================================================

    task automatic test_constrained_random();
        int num_packets, num_beats, strobe_width;
        logic [BYTE_WIDTH-1:0] strb;
        logic [DATA_WIDTH-1:0] data;
        begin_test("Constrained random (30 packets, random strobes/BP)");
        void'($urandom(42));  // reproducible seed
        num_packets = 30;

        fork
            begin : bp
                forever begin
                    avst_ready = ($urandom % 10) > 2;  // ~70% ready
                    @(posedge clk);
                end
            end
            begin : stim
                for (int pkt = 0; pkt < num_packets; pkt++) begin
                    num_beats = 1 + ($urandom % 20);
                    begin_packet();
                    for (int b = 0; b < num_beats; b++) begin
                        strobe_width = 1 + ($urandom % BYTE_WIDTH);
                        strb = make_strobe(strobe_width);
                        data = make_data(byte_seq);
                        byte_seq += BYTE_WIDTH;

                        repeat ($urandom % 4) begin
                            idle_input();
                            @(posedge clk);
                        end
                        push_and_send(data, strb, (b == num_beats - 1));
                    end
                    end_packet();
                    idle_input();
                    repeat (1 + $urandom % 5) @(posedge clk);
                end
            end
        join_any
        disable bp;
        avst_ready = 1'b1;
        wait_drain();
        end_test();
    endtask

    // ================================================================
    //  Main
    // ================================================================
    initial begin
        $display("============================================================");
        $display("  tb_axi_st_to_avalon_st_bridge — rigorous black-box suite");
        $display("  DATA_WIDTH = %0d   BYTE_WIDTH = %0d", DATA_WIDTH, BYTE_WIDTH);
        $display("============================================================\n");

        // Global timeout guard
        fork begin
            #(1_000_000);
            $error("GLOBAL TIMEOUT — simulation exceeded 1 ms");
            $finish;
        end join_none

        reset_dut();

        // A: Basic strobe widths
        test_full_strobe_passthrough();
        test_half_strobe();
        test_quarter_strobe();
        test_single_byte_beats();
        test_varying_strobes();

        // B: TLAST / flush
        test_single_beat_full();
        test_single_beat_partial();
        test_single_byte_packet();
        test_exact_fill_no_residual();
        test_exact_fill_multi_word();
        test_near_full_residual();
        test_one_byte_residual();

        // C: Multi-packet
        test_back_to_back_packets();
        test_three_diverse_packets();
        test_many_tiny_packets();
        test_many_single_byte_packets();

        // D: Backpressure
        test_bp_toggle();
        test_bp_extended_stall();
        test_bp_during_flush();
        test_bp_bursty_partial();

        // E: Input timing
        test_input_gaps();
        test_bursty_io_and_bp();

        // F: Corner cases
        test_quiescence();
        test_zero_strobe_noop();
        test_tlast_without_tvalid();
        test_accumulator_full();
        reset_dut();

        // G: Reset recovery
        test_reset_mid_transfer();
        test_reset_during_flush();

        // H: Stress
        test_constrained_random();

        // Final report
        $display("============================================================");
        $display("  RESULTS: %0d / %0d tests passed", pass_count, test_count);
        if (error_count == 0)
            $display("  === ALL TESTS PASSED ===");
        else
            $display("  === TESTS FAILED: %0d total errors ===", error_count);
        $display("============================================================");
        $finish;
    end

endmodule

`default_nettype wire
