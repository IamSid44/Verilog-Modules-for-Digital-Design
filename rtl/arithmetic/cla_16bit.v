// -----------------------------------------------------------------------------
// cla_16bit - 16-bit two-level carry-lookahead adder
//
//   {cout, sum} = a + b + cin
//
// Level 1: four cla_4bit blocks look ahead across their own four bits and
//          report a group propagate / generate (pg, gg).
// Level 2: one cla_lookahead_4 unit combines the four (pg, gg) pairs to produce
//          the carry into every block at once, so the carry never has to
//          ripple through the blocks.
// -----------------------------------------------------------------------------
`ifndef CLA_16BIT_V
`define CLA_16BIT_V

`include "rtl/arithmetic/cla_4bit.v"
`include "rtl/arithmetic/cla_lookahead_4.v"

`timescale 1ns / 1ps

module cla_16bit (
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    wire [3:0] block_pg, block_gg;      // group propagate / generate of each block
    wire [3:0] block_c;                 // block_c[i] = carry out of block i
    wire [3:0] block_cin = {block_c[2:0], cin};

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : block
            cla_4bit adder (
                .a(a[4*i +: 4]), .b(b[4*i +: 4]), .cin(block_cin[i]),
                .sum(sum[4*i +: 4]), .cout(),
                .pg(block_pg[i]), .gg(block_gg[i])
            );
        end
    endgenerate

    cla_lookahead_4 lookahead (
        .p(block_pg), .g(block_gg), .cin(cin),
        .c(block_c), .pg(), .gg()
    );

    assign cout = block_c[3];

endmodule

`endif
