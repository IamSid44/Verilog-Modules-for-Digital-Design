// Self-checking testbench for ripple_counter, sync_counter and updown_counter
// (all N = 4).
//
// Inputs change on the falling clock edge, and every cycle the counters are
// compared with a simple behavioural model after the rising edge:
//   1. count up with en = 1 past the wrap (15 -> 0)
//   2. count down with down = 1 past the wrap (0 -> 15)
//   3. 300 cycles of random en / up / down (including up = down = 1)
//   4. asynchronous reset in the middle of a clock cycle
`include "rtl/sequential/ripple_counter.v"
`include "rtl/sequential/sync_counter.v"
`include "rtl/sequential/updown_counter.v"

`timescale 1ns / 1ps

module counters_tb;

    reg        clk, rst_n, en, up, down;
    wire [3:0] c_ripple, c_sync, c_updown;
    reg  [3:0] m_up, m_ud;               // behavioural models
    integer    i, errors, seed;

    ripple_counter dut_ripple (.clk(clk), .rst_n(rst_n), .en(en),         .count(c_ripple));
    sync_counter   dut_sync   (.clk(clk), .rst_n(rst_n), .en(en),         .count(c_sync));
    updown_counter dut_updown (.clk(clk), .rst_n(rst_n), .up(up), .down(down), .count(c_updown));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_up <= 4'd0;
            m_ud <= 4'd0;
        end else begin
            if (en)        m_up <= m_up + 4'd1;
            if (up)        m_ud <= m_ud + 4'd1;     // up has priority over down
            else if (down) m_ud <= m_ud - 4'd1;
        end
    end

    // Apply inputs on the falling edge, then compare after the rising edge.
    task cycle;
        input e, u, d;
        begin
            @(negedge clk);
            en = e; up = u; down = d;
            @(posedge clk); #1;
            if (c_ripple !== m_up || c_sync !== m_up || c_updown !== m_ud) begin
                errors = errors + 1;
                $display("  FAIL at %0t ns (en=%b up=%b down=%b): ripple=%0d sync=%0d (expected %0d), updown=%0d (expected %0d)",
                         $time, e, u, d, c_ripple, c_sync, m_up, c_updown, m_ud);
            end
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/counters_tb.vcd");
        $dumpvars(0, counters_tb);
    end

    initial begin
        errors = 0;
        seed   = 5;
        rst_n  = 1'b0;
        en = 0; up = 0; down = 0;

        #12;
        if (c_ripple !== 4'd0 || c_sync !== 4'd0 || c_updown !== 4'd0) begin
            errors = errors + 1;
            $display("  FAIL reset: %0d %0d %0d", c_ripple, c_sync, c_updown);
        end
        @(negedge clk);
        rst_n = 1'b1;

        // Idle: nothing should move.
        for (i = 0; i < 3; i = i + 1) cycle(0, 0, 0);

        // 1. Count up through the wrap.
        for (i = 0; i < 20; i = i + 1) cycle(1, 1, 0);

        // Hold in the middle of a count.
        for (i = 0; i < 3; i = i + 1) cycle(0, 0, 0);

        // 2. Count down through the wrap.
        for (i = 0; i < 20; i = i + 1) cycle(1, 0, 1);

        // 3. Random stimulus.
        for (i = 0; i < 300; i = i + 1)
            cycle($random(seed), $random(seed), $random(seed));

        // 4. Asynchronous reset between clock edges.
        @(negedge clk);
        en = 1; up = 1; down = 0;
        #2 rst_n = 1'b0;
        #1 if (c_ripple !== 4'd0 || c_sync !== 4'd0 || c_updown !== 4'd0) begin
               errors = errors + 1;
               $display("  FAIL async reset: %0d %0d %0d", c_ripple, c_sync, c_updown);
           end
        #1 rst_n = 1'b1;
        @(posedge clk); #1;
        if (c_ripple !== 4'd1 || c_sync !== 4'd1 || c_updown !== 4'd1) begin
            errors = errors + 1;
            $display("  FAIL restart after reset: %0d %0d %0d", c_ripple, c_sync, c_updown);
        end

        if (errors == 0) $display("PASS: counters_tb");
        else             $display("FAIL: counters_tb (%0d errors)", errors);
        $finish;
    end

endmodule
