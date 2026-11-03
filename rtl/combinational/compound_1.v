// -----------------------------------------------------------------------------
// compound_1 - Y = AB + CD, using NAND gates only
//
// Two-level NAND-NAND form of a sum of products:
//   Y = ((AB)' . (CD)')' = AB + CD
// -----------------------------------------------------------------------------
`ifndef COMPOUND_1_V
`define COMPOUND_1_V

`timescale 1ns / 1ps

module compound_1 (
    input  a, b, c, d,
    output y
);

    wire p, q;

    nand (p, a, b);
    nand (q, c, d);
    nand (y, p, q);

endmodule

`endif
