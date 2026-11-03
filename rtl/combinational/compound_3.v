// -----------------------------------------------------------------------------
// compound_3 - Y = ((A + B') . (CD + E))', using NAND gates only
//
// Expand CD + E with the distributive law, (CD + E) = (C + E)(D + E), so every
// factor is a single OR term that a NAND with inverted inputs can produce:
//   t = (A + B')  = NAND(A', B)
//   u = (C + E)   = NAND(C', E')
//   v = (D + E)   = NAND(D', E')
//   Y = NAND(t, u, v)
//
// A 1-input NAND is used below as an inverter.
// -----------------------------------------------------------------------------
`ifndef COMPOUND_3_V
`define COMPOUND_3_V

`timescale 1ns / 1ps

module compound_3 (
    input  a, b, c, d, e,
    output y
);

    wire a_n, c_n, d_n, e_n;
    wire t, u, v;

    nand (a_n, a);
    nand (c_n, c);
    nand (d_n, d);
    nand (e_n, e);

    nand (t, a_n, b);
    nand (u, c_n, e_n);
    nand (v, d_n, e_n);
    nand (y, t, u, v);

endmodule

`endif
