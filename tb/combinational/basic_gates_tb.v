// Exhaustive self-checking testbench for basic_gates.
`include "rtl/combinational/basic_gates.v"

`timescale 1ns / 1ps

module basic_gates_tb;

    reg  a, b;
    wire y_and, y_or, y_nand, y_nor, y_xor, y_xnor, y_not;
    integer i, errors;

    basic_gates dut (
        .a(a), .b(b),
        .y_and(y_and), .y_or(y_or), .y_nand(y_nand), .y_nor(y_nor),
        .y_xor(y_xor), .y_xnor(y_xnor), .y_not(y_not)
    );

    task check;
        input [8*5-1:0] name;
        input           got;
        input           expected;
        begin
            if (got !== expected) begin
                errors = errors + 1;
                $display("  FAIL %0s: a=%b b=%b got=%b expected=%b", name, a, b, got, expected);
            end
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/basic_gates_tb.vcd");
        $dumpvars(0, basic_gates_tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i;
            #5;
            check("and",  y_and,  a & b);
            check("or",   y_or,   a | b);
            check("nand", y_nand, ~(a & b));
            check("nor",  y_nor,  ~(a | b));
            check("xor",  y_xor,  a ^ b);
            check("xnor", y_xnor, ~(a ^ b));
            check("not",  y_not,  ~a);
        end

        if (errors == 0) $display("PASS: basic_gates_tb");
        else             $display("FAIL: basic_gates_tb (%0d errors)", errors);
        $finish;
    end

endmodule
