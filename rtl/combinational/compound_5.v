// -----------------------------------------------------------------------------
// compound_5 - F(A,B,C,D) = SIGMA m(0,6,8,13,14) + d(2,4,10), NAND gates only
//
// A is the MSB of the minterm index. Using the don't-cares 2 and 10 the K-map
// reduces to three prime implicants:
//   F = B'D' + CD' + ABC'D
// (minterm 4 is a don't care that is left at 0).
//
// Each product term is a NAND, and a final NAND ORs them together.
// A 1-input NAND is used below as an inverter.
// -----------------------------------------------------------------------------
`ifndef COMPOUND_5_V
`define COMPOUND_5_V

`timescale 1ns / 1ps

module compound_5 (
    input  a, b, c, d,
    output y
);

    wire b_n, c_n, d_n;
    wire p, q, r;

    nand (b_n, b);
    nand (c_n, c);
    nand (d_n, d);

    nand (p, b_n, d_n);      // (B'D')'
    nand (q, c,   d_n);      // (CD')'
    nand (r, a, b, c_n, d);  // (ABC'D)'
    nand (y, p, q, r);

endmodule

`endif
