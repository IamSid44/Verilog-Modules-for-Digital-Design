// Exhaustive self-checking testbench for demux1to2, demux1to4 and demux1to8.
// Expected: y = in << sel (the selected output carries `in`, the rest are 0).
`include "rtl/combinational/demux1to2.v"
`include "rtl/combinational/demux1to4.v"
`include "rtl/combinational/demux1to8.v"

`timescale 1ns / 1ps

module demux_tb;

    reg  [3:0] stim;                 // {sel[2:0], in}
    wire       in   = stim[0];
    wire [2:0] sel8 = stim[3:1];
    wire [1:0] sel4 = stim[2:1];
    wire       sel2 = stim[1];
    wire [1:0] y2;
    wire [3:0] y4;
    wire [7:0] y8;
    integer i, errors;

    demux1to2 dut2 (.in(in), .sel(sel2), .y(y2));
    demux1to4 dut4 (.in(in), .sel(sel4), .y(y4));
    demux1to8 dut8 (.in(in), .sel(sel8), .y(y8));

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/demux_tb.vcd");
        $dumpvars(0, demux_tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 16; i = i + 1) begin
            stim = i;
            #5;
            if (y2 !== ({1'b0, in} << sel2)) begin
                errors = errors + 1;
                $display("  FAIL demux1to2: in=%b sel=%0d y=%b", in, sel2, y2);
            end
            if (y4 !== ({3'b0, in} << sel4)) begin
                errors = errors + 1;
                $display("  FAIL demux1to4: in=%b sel=%0d y=%b", in, sel4, y4);
            end
            if (y8 !== ({7'b0, in} << sel8)) begin
                errors = errors + 1;
                $display("  FAIL demux1to8: in=%b sel=%0d y=%b", in, sel8, y8);
            end
        end

        if (errors == 0) $display("PASS: demux_tb");
        else             $display("FAIL: demux_tb (%0d errors)", errors);
        $finish;
    end

endmodule
