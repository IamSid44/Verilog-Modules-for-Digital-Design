// -----------------------------------------------------------------------------
// cla_lookahead_4 - 4-position carry-lookahead unit
//
// Computes all four carries at once from propagate (p) and generate (g)
// signals, instead of letting a carry ripple from one position to the next.
// It does not care whether the positions are bits or whole blocks, so it is
// used both inside cla_4bit (for bits) and in cla_16bit (for 4-bit blocks).
//
//   c[0] = g0 + p0.cin
//   c[1] = g1 + p1.g0 + p1.p0.cin
//   c[2] = g2 + p2.g1 + p2.p1.g0 + p2.p1.p0.cin
//   c[3] = gg + pg.cin                     (gg, pg: group generate/propagate)
//
//   c[i] is the carry OUT of position i (the carry into position i+1).
//   pg = p3.p2.p1.p0                       (a carry-in would pass straight through)
//   gg = g3 + p3.g2 + p3.p2.g1 + p3.p2.p1.g0   (carry-out generated inside)
// -----------------------------------------------------------------------------
`ifndef CLA_LOOKAHEAD_4_V
`define CLA_LOOKAHEAD_4_V

`timescale 1ns / 1ps

module cla_lookahead_4 (
    input  [3:0] p,
    input  [3:0] g,
    input        cin,
    output [3:0] c,
    output       pg,
    output       gg
);

    assign pg = &p;
    assign gg = g[3]
              | (p[3] & g[2])
              | (p[3] & p[2] & g[1])
              | (p[3] & p[2] & p[1] & g[0]);

    assign c[0] = g[0] | (p[0] & cin);
    assign c[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
    assign c[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])
                       | (p[2] & p[1] & p[0] & cin);
    assign c[3] = gg | (pg & cin);

endmodule

`endif
