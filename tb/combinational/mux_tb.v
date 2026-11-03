// Exhaustive self-checking testbench for mux2to1, mux4to1 and mux8to1.
// One 11-bit counter drives all three: the smaller muxes use its low bits, so
// every input/select combination of each mux is covered.
`include "rtl/combinational/mux2to1.v"
`include "rtl/combinational/mux4to1.v"
`include "rtl/combinational/mux8to1.v"

`timescale 1ns / 1ps

module mux_tb;

    reg  [10:0] stim;
    wire [7:0]  in8  = stim[7:0];
    wire [2:0]  sel8 = stim[10:8];
    wire [3:0]  in4  = stim[3:0];
    wire [1:0]  sel4 = stim[5:4];
    wire        in0  = stim[0];
    wire        in1  = stim[1];
    wire        sel2 = stim[2];
    wire        y2, y4, y8;
    integer i, errors;

    mux2to1 dut2 (.in0(in0), .in1(in1), .sel(sel2), .y(y2));
    mux4to1 dut4 (.in(in4), .sel(sel4), .y(y4));
    mux8to1 dut8 (.in(in8), .sel(sel8), .y(y8));

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/mux_tb.vcd");
        $dumpvars(0, mux_tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 2048; i = i + 1) begin
            stim = i;
            #5;
            if (y2 !== (sel2 ? in1 : in0)) begin
                errors = errors + 1;
                $display("  FAIL mux2to1: in=%b%b sel=%b y=%b", in1, in0, sel2, y2);
            end
            if (y4 !== in4[sel4]) begin
                errors = errors + 1;
                $display("  FAIL mux4to1: in=%b sel=%0d y=%b", in4, sel4, y4);
            end
            if (y8 !== in8[sel8]) begin
                errors = errors + 1;
                $display("  FAIL mux8to1: in=%b sel=%0d y=%b", in8, sel8, y8);
            end
        end

        if (errors == 0) $display("PASS: mux_tb");
        else             $display("FAIL: mux_tb (%0d errors)", errors);
        $finish;
    end

endmodule
