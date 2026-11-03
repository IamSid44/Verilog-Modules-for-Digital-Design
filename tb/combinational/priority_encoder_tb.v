// Exhaustive self-checking testbench for priority_encoder_8to3.
// Expected: out = index of the highest set bit; valid = en & (in != 0).
`include "rtl/combinational/priority_encoder_8to3.v"

`timescale 1ns / 1ps

module priority_encoder_tb;

    reg  [8:0] stim;                 // {en, in[7:0]}
    wire       en = stim[8];
    wire [7:0] in = stim[7:0];
    wire [2:0] out;
    wire       valid;
    reg  [2:0] expected;
    integer    i, k, errors;

    priority_encoder_8to3 dut (.en(en), .in(in), .out(out), .valid(valid));

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/priority_encoder_tb.vcd");
        $dumpvars(0, priority_encoder_tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 512; i = i + 1) begin
            stim = i;
            #5;
            expected = 3'd0;
            for (k = 0; k < 8; k = k + 1)
                if (in[k]) expected = k;
            if (!en) expected = 3'd0;

            if (out !== expected) begin
                errors = errors + 1;
                $display("  FAIL out: en=%b in=%b got=%0d expected=%0d", en, in, out, expected);
            end
            if (valid !== (en && in != 8'd0)) begin
                errors = errors + 1;
                $display("  FAIL valid: en=%b in=%b got=%b", en, in, valid);
            end
        end

        if (errors == 0) $display("PASS: priority_encoder_tb");
        else             $display("FAIL: priority_encoder_tb (%0d errors)", errors);
        $finish;
    end

endmodule
