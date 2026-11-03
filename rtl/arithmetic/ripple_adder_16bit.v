// -----------------------------------------------------------------------------
// ripple_adder_16bit - 16-bit ripple-carry adder, built from four
// ripple_adder_4bit blocks
//
//   {cout, sum} = a + b + cin
// -----------------------------------------------------------------------------
`ifndef RIPPLE_ADDER_16BIT_V
`define RIPPLE_ADDER_16BIT_V

`include "rtl/arithmetic/ripple_adder_4bit.v"

`timescale 1ns / 1ps

module ripple_adder_16bit (
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    wire [4:0] carry;   // carry[i] is the carry into block i; carry[4] is cout

    assign carry[0] = cin;
    assign cout     = carry[4];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : block
            ripple_adder_4bit adder (
                .a(a[4*i +: 4]), .b(b[4*i +: 4]), .cin(carry[i]),
                .sum(sum[4*i +: 4]), .cout(carry[i + 1])
            );
        end
    endgenerate

endmodule

`endif
