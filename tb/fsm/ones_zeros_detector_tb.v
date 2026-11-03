// Self-checking testbench for ones_zeros_detector.
//
// Directed scenarios (expected `out` listed per clock cycle):
//   1. a held `one` counts once; out rises only after two 1s and two 0s
//   2. a `one` held for many cycles is still a single 1
//   3. `one` and `zero` rising on the same edge are both counted
//   4. out stays high after more inputs; reset clears it
// Followed by 3000 random cycles against an integer-counter model.
`include "rtl/fsm/ones_zeros_detector.v"

`timescale 1ns / 1ps

module ones_zeros_detector_tb;

    reg  clk, reset, one, zero;
    wire out;
    integer i, errors, seed;

    // Reference model (counts rising edges directly)
    integer m_ones, m_zeros;
    reg     m_one_q, m_zero_q;

    ones_zeros_detector dut (.clk(clk), .reset(reset), .one(one), .zero(zero), .out(out));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            m_ones = 0; m_zeros = 0; m_one_q = 1'b0; m_zero_q = 1'b0;
        end else begin
            if (one  && !m_one_q  && m_ones  < 2) m_ones  = m_ones  + 1;
            if (zero && !m_zero_q && m_zeros < 2) m_zeros = m_zeros + 1;
            m_one_q = one; m_zero_q = zero;
        end
    end

    // Drive one/zero for one clock and check `out` just after the rising edge.
    task cyc;
        input o, z, expected;
        begin
            @(negedge clk);
            one = o; zero = z;
            @(posedge clk); #1;
            if (out !== expected) begin
                errors = errors + 1;
                $display("  FAIL at %0t ns: one=%b zero=%b out=%b expected %b", $time, o, z, out, expected);
            end
        end
    endtask

    task do_reset;
        begin
            @(negedge clk);
            one = 1'b0; zero = 1'b0;
            reset = 1'b1;
            #2 reset = 1'b0;
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/ones_zeros_detector_tb.vcd");
        $dumpvars(0, ones_zeros_detector_tb);
    end

    initial begin
        errors = 0;
        seed   = 13;
        reset  = 1'b1; one = 1'b0; zero = 1'b0;
        #12 reset = 1'b0;

        // ---- 1. held pulse counts once --------------------------------------
        //   one: 111 0 .. 1        zero: .... 1 0 .. 1
        cyc(1, 0, 0);   // 1st "1" (rising edge)
        cyc(1, 0, 0);   //   still the same "1"
        cyc(1, 0, 0);
        cyc(0, 0, 0);
        cyc(0, 1, 0);   // 1st "0"
        cyc(0, 0, 0);
        cyc(1, 0, 0);   // 2nd "1"  -> two 1s, one 0
        cyc(0, 0, 0);
        cyc(0, 1, 1);   // 2nd "0"  -> two 1s, two 0s
        cyc(0, 1, 1);   //   held: stays asserted
        cyc(0, 0, 1);

        // ---- 4. reset clears out --------------------------------------------
        do_reset;
        cyc(0, 0, 0);

        // ---- 2. one long "1" is a single input ------------------------------
        cyc(0, 1, 0);   // 1st "0"
        cyc(0, 0, 0);
        cyc(0, 1, 0);   // 2nd "0"
        cyc(0, 0, 0);
        cyc(1, 0, 0);   // 1st "1", held for 5 cycles
        cyc(1, 0, 0);
        cyc(1, 0, 0);
        cyc(1, 0, 0);
        cyc(1, 0, 0);
        cyc(0, 0, 0);   // still only one "1" -> out must be 0
        cyc(1, 0, 1);   // 2nd "1" -> out

        // ---- 4. saturation: more inputs do not drop out ---------------------
        cyc(0, 0, 1);
        cyc(0, 1, 1);
        cyc(1, 0, 1);

        // ---- 3. simultaneous one and zero ------------------------------------
        do_reset;
        cyc(1, 1, 0);   // one "1" and one "0" at once
        cyc(0, 0, 0);
        cyc(1, 1, 1);   // second of each at once -> out

        // ---- reset in the middle of operation -------------------------------
        do_reset;
        if (out !== 1'b0) begin
            errors = errors + 1;
            $display("  FAIL reset: out=%b", out);
        end

        // ---- random, against the model ----------------------------------------
        for (i = 0; i < 3000; i = i + 1) begin
            @(negedge clk);
            // Change each input only about a third of the time so that pulses
            // stay high for several cycles.
            if ($unsigned($random(seed)) % 3 == 0) one  = $random(seed);
            if ($unsigned($random(seed)) % 3 == 0) zero = $random(seed);
            // Occasional reset.
            if ($unsigned($random(seed)) % 200 == 0) begin
                reset = 1'b1;
                #2 reset = 1'b0;
            end
            @(posedge clk); #1;
            if (out !== (m_ones == 2 && m_zeros == 2)) begin
                errors = errors + 1;
                $display("  FAIL random %0d: one=%b zero=%b out=%b (model: %0d ones, %0d zeros)",
                         i, one, zero, out, m_ones, m_zeros);
            end
        end

        if (errors == 0) $display("PASS: ones_zeros_detector_tb");
        else             $display("FAIL: ones_zeros_detector_tb (%0d errors)", errors);
        $finish;
    end

endmodule
