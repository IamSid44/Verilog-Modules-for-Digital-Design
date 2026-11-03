// -----------------------------------------------------------------------------
// ripple_adder_4bit - 4-bit ripple-carry adder, built from four full_adder
//
//   {cout, sum} = a + b + cin
//
// The carry ripples from bit 0 to bit 3, so the delay grows with the width.
// -----------------------------------------------------------------------------
`ifndef RIPPLE_ADDER_4BIT_V
`define RIPPLE_ADDER_4BIT_V

`include "rtl/arithmetic/full_adder.v"

`timescale 1ns / 1ps

module ripple_adder_4bit (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);

    wire [4:0] carry;   // carry[i] is the carry into bit i; carry[4] is cout

    assign carry[0] = cin;
    assign cout     = carry[4];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : bit_slice
            full_adder fa (
                .a(a[i]), .b(b[i]), .cin(carry[i]),
                .sum(sum[i]), .cout(carry[i + 1])
            );
        end
    endgenerate

endmodule

`endif
