// Exhaustive self-checking testbench for decoder1to2, decoder2to4, decoder3to8.
// Expected: out = en ? (1 << in) : 0.
`include "rtl/combinational/decoder1to2.v"
`include "rtl/combinational/decoder2to4.v"
`include "rtl/combinational/decoder3to8.v"

`timescale 1ns / 1ps

module decoder_tb;

    reg  [3:0] stim;                 // {en, in[2:0]}
    wire       en   = stim[3];
    wire [2:0] in3  = stim[2:0];
    wire [1:0] in2  = stim[1:0];
    wire       in1  = stim[0];
    wire [1:0] y2;
    wire [3:0] y4;
    wire [7:0] y8;
    integer i, errors;

    decoder1to2 dut2 (.en(en), .in(in1), .out(y2));
    decoder2to4 dut4 (.en(en), .in(in2), .out(y4));
    decoder3to8 dut8 (.en(en), .in(in3), .out(y8));

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/decoder_tb.vcd");
        $dumpvars(0, decoder_tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 16; i = i + 1) begin
            stim = i;
            #5;
            if (y2 !== (en ? (2'b01 << in1) : 2'b00)) begin
                errors = errors + 1;
                $display("  FAIL decoder1to2: en=%b in=%0d out=%b", en, in1, y2);
            end
            if (y4 !== (en ? (4'b0001 << in2) : 4'b0000)) begin
                errors = errors + 1;
                $display("  FAIL decoder2to4: en=%b in=%0d out=%b", en, in2, y4);
            end
            if (y8 !== (en ? (8'b00000001 << in3) : 8'b0)) begin
                errors = errors + 1;
                $display("  FAIL decoder3to8: en=%b in=%0d out=%b", en, in3, y8);
            end
        end

        if (errors == 0) $display("PASS: decoder_tb");
        else             $display("FAIL: decoder_tb (%0d errors)", errors);
        $finish;
    end

endmodule
