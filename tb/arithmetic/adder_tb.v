// Self-checking testbench for full_adder, ripple_adder_4bit/16bit, cla_4bit/16bit.
//   - full_adder and both 4-bit adders: exhaustive.
//   - both 16-bit adders: corner cases plus 5000 pseudo-random vectors.
// Expected values come from Verilog's own + operator.
`include "rtl/arithmetic/cla_16bit.v"
`include "rtl/arithmetic/cla_4bit.v"
`include "rtl/arithmetic/full_adder.v"
`include "rtl/arithmetic/ripple_adder_16bit.v"
`include "rtl/arithmetic/ripple_adder_4bit.v"

`timescale 1ns / 1ps

module adder_tb;

    // 1-bit and 4-bit stimulus
    reg  [3:0]  a4, b4;
    reg         cin4;
    wire        fa_sum, fa_cout;
    wire [3:0]  rca4_sum, cla4_sum;
    wire        rca4_cout, cla4_cout;

    // 16-bit stimulus
    reg  [15:0] a16, b16;
    reg         cin16;
    wire [15:0] rca16_sum, cla16_sum;
    wire        rca16_cout, cla16_cout;

    integer i, j, k, errors, seed;

    full_adder        fa     (.a(a4[0]), .b(b4[0]), .cin(cin4), .sum(fa_sum), .cout(fa_cout));
    ripple_adder_4bit rca4   (.a(a4), .b(b4), .cin(cin4), .sum(rca4_sum), .cout(rca4_cout));
    cla_4bit          cla4   (.a(a4), .b(b4), .cin(cin4), .sum(cla4_sum), .cout(cla4_cout));
    ripple_adder_16bit rca16 (.a(a16), .b(b16), .cin(cin16), .sum(rca16_sum), .cout(rca16_cout));
    cla_16bit         cla16  (.a(a16), .b(b16), .cin(cin16), .sum(cla16_sum), .cout(cla16_cout));

    task check4;
        reg [4:0] expected;
        begin
            expected = a4 + b4 + cin4;
            if ({rca4_cout, rca4_sum} !== expected) begin
                errors = errors + 1;
                $display("  FAIL ripple_adder_4bit: %0d + %0d + %b = %0d (expected %0d)",
                         a4, b4, cin4, {rca4_cout, rca4_sum}, expected);
            end
            if ({cla4_cout, cla4_sum} !== expected) begin
                errors = errors + 1;
                $display("  FAIL cla_4bit: %0d + %0d + %b = %0d (expected %0d)",
                         a4, b4, cin4, {cla4_cout, cla4_sum}, expected);
            end
            if ({fa_cout, fa_sum} !== a4[0] + b4[0] + cin4) begin
                errors = errors + 1;
                $display("  FAIL full_adder: %b + %b + %b = %b%b",
                         a4[0], b4[0], cin4, fa_cout, fa_sum);
            end
        end
    endtask

    task check16;
        input [15:0] a;
        input [15:0] b;
        input        cin;
        reg   [16:0] expected;
        begin
            a16 = a; b16 = b; cin16 = cin;
            #5;
            expected = a + b + cin;
            if ({rca16_cout, rca16_sum} !== expected) begin
                errors = errors + 1;
                $display("  FAIL ripple_adder_16bit: %0d + %0d + %b = %0d (expected %0d)",
                         a, b, cin, {rca16_cout, rca16_sum}, expected);
            end
            if ({cla16_cout, cla16_sum} !== expected) begin
                errors = errors + 1;
                $display("  FAIL cla_16bit: %0d + %0d + %b = %0d (expected %0d)",
                         a, b, cin, {cla16_cout, cla16_sum}, expected);
            end
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/adder_tb.vcd");
        $dumpvars(0, adder_tb);
    end

    initial begin
        errors = 0;
        seed   = 1;

        // Exhaustive: 2 x 16 x 16 = 512 combinations of cin, a, b.
        for (k = 0; k < 2; k = k + 1)
            for (i = 0; i < 16; i = i + 1)
                for (j = 0; j < 16; j = j + 1) begin
                    cin4 = k; a4 = i; b4 = j;
                    #5;
                    check4;
                end

        // 16-bit corner cases: zeros, all ones, full carry chain, carry-out.
        check16(16'd0,      16'd0,      1'b0);
        check16(16'd0,      16'd0,      1'b1);
        check16(16'hFFFF,   16'd0,      1'b1);   // carry ripples through all 16 bits
        check16(16'hFFFF,   16'hFFFF,   1'b1);
        check16(16'h7FFF,   16'h0001,   1'b0);
        check16(16'hAAAA,   16'h5555,   1'b1);
        check16(16'd20768,  16'd13344,  1'b0);
        check16(16'd32767,  16'd59483,  1'b0);

        // 16-bit pseudo-random vectors (fixed seed, so runs are reproducible).
        for (i = 0; i < 5000; i = i + 1)
            check16($random(seed), $random(seed), $random(seed));

        if (errors == 0) $display("PASS: adder_tb");
        else             $display("FAIL: adder_tb (%0d errors)", errors);
        $finish;
    end

endmodule
