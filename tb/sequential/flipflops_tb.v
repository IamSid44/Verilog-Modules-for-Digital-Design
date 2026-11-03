// Self-checking testbench for dff, tff, jkff, srff and sr_latch.
//
// The clocked flip-flops are driven with 300 cycles of pseudo-random inputs and
// compared, every cycle, against their characteristic equations:
//   D : Q+ = D            T : Q+ = T ^ Q
//   JK: Q+ = J.Q' + K'.Q  SR: Q+ = S + R'.Q   (S = R = 1 is never applied here)
// Also checked: q_n = ~q, asynchronous reset in the middle of a clock cycle,
// the forbidden S = R = 1 input (output x), and the level-sensitive sr_latch.
`include "rtl/sequential/dff.v"
`include "rtl/sequential/jkff.v"
`include "rtl/sequential/sr_latch.v"
`include "rtl/sequential/srff.v"
`include "rtl/sequential/tff.v"

`timescale 1ns / 1ps

module flipflops_tb;

    reg  clk, rst_n;
    reg  d, t, j, k, s, r;
    reg  s_l, r_l;                       // sr_latch inputs
    wire q_d, qn_d, q_t, qn_t, q_jk, qn_jk, q_sr, qn_sr, q_l, qn_l;

    // Reference model: characteristic equations.
    reg  m_d, m_t, m_jk, m_sr;

    integer cycle, errors, seed, pick;

    dff      u_dff   (.clk(clk), .rst_n(rst_n), .d(d),         .q(q_d),  .q_n(qn_d));
    tff      u_tff   (.clk(clk), .rst_n(rst_n), .t(t),         .q(q_t),  .q_n(qn_t));
    jkff     u_jkff  (.clk(clk), .rst_n(rst_n), .j(j), .k(k),  .q(q_jk), .q_n(qn_jk));
    srff     u_srff  (.clk(clk), .rst_n(rst_n), .s(s), .r(r),  .q(q_sr), .q_n(qn_sr));
    sr_latch u_latch (.s(s_l), .r(r_l),                        .q(q_l),  .q_n(qn_l));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_d <= 1'b0; m_t <= 1'b0; m_jk <= 1'b0; m_sr <= 1'b0;
        end else begin
            m_d  <= d;
            m_t  <= t ^ m_t;
            m_jk <= (j & ~m_jk) | (~k & m_jk);
            m_sr <= s | (~r & m_sr);
        end
    end

    task fail;
        input [8*8-1:0] what;
        begin
            errors = errors + 1;
            $display("  FAIL %0s at %0t ns (cycle %0d)", what, $time, cycle);
        end
    endtask

    task check_flops;
        begin
            if (q_d  !== m_d  || qn_d  !== ~m_d)  fail("dff");
            if (q_t  !== m_t  || qn_t  !== ~m_t)  fail("tff");
            if (q_jk !== m_jk || qn_jk !== ~m_jk) fail("jkff");
            if (q_sr !== m_sr || qn_sr !== ~m_sr) fail("srff");
        end
    endtask

    task expect_latch;
        input exp_q;
        begin
            #1;
            if (q_l !== exp_q || qn_l !== ~exp_q) begin
                errors = errors + 1;
                $display("  FAIL sr_latch: s=%b r=%b q=%b (expected %b)", s_l, r_l, q_l, exp_q);
            end
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/flipflops_tb.vcd");
        $dumpvars(0, flipflops_tb);
    end

    initial begin
        errors = 0;
        seed   = 7;
        cycle  = 0;
        rst_n  = 1'b0;
        d = 0; t = 0; j = 0; k = 0; s = 0; r = 0; s_l = 0; r_l = 0;

        // Reset is asserted from time 0, through the first clock edge.
        #12;
        if (q_d !== 1'b0 || q_t !== 1'b0 || q_jk !== 1'b0 || q_sr !== 1'b0 ||
            qn_d !== 1'b1 || qn_t !== 1'b1 || qn_jk !== 1'b1 || qn_sr !== 1'b1)
            fail("reset");

        @(negedge clk);
        rst_n = 1'b1;

        for (cycle = 1; cycle <= 300; cycle = cycle + 1) begin
            @(negedge clk);
            d = $random(seed);
            t = $random(seed);
            j = $random(seed);
            k = $random(seed);
            pick = $unsigned($random(seed)) % 3;     // 0: hold, 1: reset, 2: set
            s = (pick == 2);
            r = (pick == 1);

            // Asynchronous reset in the middle of the clock cycle.
            if (cycle == 100) begin
                #1 rst_n = 1'b0;
                #1 if (q_d !== 1'b0 || q_t !== 1'b0 || q_jk !== 1'b0 || q_sr !== 1'b0)
                       fail("async rst");
                #1 rst_n = 1'b1;
            end

            @(posedge clk);
            #1;
            check_flops;
        end

        // Forbidden input: S = R = 1 makes the S-R flip-flop output unknown.
        @(negedge clk);
        s = 1'b1; r = 1'b1;
        @(posedge clk); #1;
        if (q_sr !== 1'bx) fail("srff 11");
        @(negedge clk);
        s = 1'b0; r = 1'b1;                          // reset recovers it
        @(posedge clk); #1;
        if (q_sr !== 1'b0) fail("srff rcv");

        // sr_latch: level sensitive, no clock.
        s_l = 1; r_l = 0; expect_latch(1'b1);        // set
        s_l = 0; r_l = 0; expect_latch(1'b1);        // hold 1
        s_l = 0; r_l = 1; expect_latch(1'b0);        // reset
        s_l = 0; r_l = 0; expect_latch(1'b0);        // hold 0
        s_l = 1; r_l = 0; expect_latch(1'b1);        // set again
        s_l = 1; r_l = 1; #1;
        if (q_l !== 1'bx) fail("latch 11");

        if (errors == 0) $display("PASS: flipflops_tb");
        else             $display("FAIL: flipflops_tb (%0d errors)", errors);
        $finish;
    end

endmodule
