// -----------------------------------------------------------------------------
// cla_16bit - 16-bit adder built from four cla_4bit blocks
//
//   {cout, sum} = a + b + cin
//
// Carries are looked ahead inside each 4-bit block; the carry between blocks
// ripples. (A fully two-level CLA would add a second lookahead unit across the
// blocks.)
// -----------------------------------------------------------------------------
`ifndef CLA_16BIT_V
`define CLA_16BIT_V

`include "rtl/arithmetic/cla_4bit.v"

`timescale 1ns / 1ps

module cla_16bit (
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
            cla_4bit adder (
                .a(a[4*i +: 4]), .b(b[4*i +: 4]), .cin(carry[i]),
                .sum(sum[4*i +: 4]), .cout(carry[i + 1])
            );
        end
    endgenerate

endmodule

`endif
