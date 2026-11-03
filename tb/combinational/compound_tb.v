// Exhaustive self-checking testbench for compound_1 .. compound_5.
// Expected values come from the original specifications, not from the gate
// networks. For compound_5 the don't-care minterms (2, 4, 10) are not checked.
`include "rtl/combinational/compound_1.v"
`include "rtl/combinational/compound_2.v"
`include "rtl/combinational/compound_3.v"
`include "rtl/combinational/compound_4.v"
`include "rtl/combinational/compound_5.v"

`timescale 1ns / 1ps

module compound_tb;

    reg a, b, c, d, e, f;
    wire y1, y2, y3, y4, y5;
    integer i, errors;

    compound_1 dut1 (.a(a), .b(b), .c(c), .d(d),                 .y(y1));
    compound_2 dut2 (.a(a), .b(b), .c(c), .d(d), .e(e), .f(f),   .y(y2));
    compound_3 dut3 (.a(a), .b(b), .c(c), .d(d), .e(e),          .y(y3));
    compound_4 dut4 (.a(a), .b(b), .c(c), .d(d),                 .y(y4));
    compound_5 dut5 (.a(a), .b(b), .c(c), .d(d),                 .y(y5));

    // F = PI M(1,3,5,7,13,15): 0 at the listed minterms, 1 elsewhere.
    function exp4;
        input [3:0] m;
        begin
            case (m)
                4'd1, 4'd3, 4'd5, 4'd7, 4'd13, 4'd15: exp4 = 1'b0;
                default:                              exp4 = 1'b1;
            endcase
        end
    endfunction

    // F = SIGMA m(0,6,8,13,14) + d(2,4,10): returns 1, 0, or x for don't care.
    function exp5;
        input [3:0] m;
        begin
            case (m)
                4'd0, 4'd6, 4'd8, 4'd13, 4'd14: exp5 = 1'b1;
                4'd2, 4'd4, 4'd10:              exp5 = 1'bx;
                default:                        exp5 = 1'b0;
            endcase
        end
    endfunction

    task check;
        input [8*10-1:0] name;
        input            got;
        input            expected;   // x means don't care
        begin
            if (expected !== 1'bx && got !== expected) begin
                errors = errors + 1;
                $display("  FAIL %0s: abcdef=%b%b%b%b%b%b got=%b expected=%b",
                         name, a, b, c, d, e, f, got, expected);
            end
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/compound_tb.vcd");
        $dumpvars(0, compound_tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 64; i = i + 1) begin
            {a, b, c, d, e, f} = i;
            #5;
            check("compound_1", y1, (a & b) | (c & d));
            check("compound_2", y2, ((a & b & c) | (d & e)) & f);
            check("compound_3", y3, ~((a | ~b) & ((c & d) | e)));
            check("compound_4", y4, exp4({a, b, c, d}));
            check("compound_5", y5, exp5({a, b, c, d}));
        end

        if (errors == 0) $display("PASS: compound_tb");
        else             $display("FAIL: compound_tb (%0d errors)", errors);
        $finish;
    end

endmodule
