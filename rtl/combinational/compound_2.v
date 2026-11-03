// -----------------------------------------------------------------------------
// compound_2 - Y = (ABC + DE) . F, using NAND gates only
//
// Distribute F first so the function is a plain sum of products:
//   Y = ABCF + DEF = ((ABCF)' . (DEF)')'
// -----------------------------------------------------------------------------
`ifndef COMPOUND_2_V
`define COMPOUND_2_V

`timescale 1ns / 1ps

module compound_2 (
    input  a, b, c, d, e, f,
    output y
);

    wire p, q;

    nand (p, a, b, c, f);
    nand (q, d, e, f);
    nand (y, p, q);

endmodule

`endif
