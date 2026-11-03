// -----------------------------------------------------------------------------
// cla_4bit - 4-bit carry-lookahead adder
//
//   {cout, sum} = a + b + cin
//
// Per-bit propagate and generate:   p[i] = a[i] ^ b[i]     g[i] = a[i] & b[i]
// A cla_lookahead_4 unit turns them into every carry at the same time, and
//   sum[i] = p[i] ^ (carry into bit i)
//
// `pg` and `gg` are the block's group propagate / generate. They are not needed
// to add four bits, but let several blocks be combined by a second lookahead
// unit (see cla_16bit):
//   gg = 1 : the block produces a carry-out by itself (cout = 1 even if cin = 0)
//   pg = 1 : the block passes a carry-in straight through (cout = cin)
//   cout = gg + pg.cin
// -----------------------------------------------------------------------------
`ifndef CLA_4BIT_V
`define CLA_4BIT_V

`include "rtl/arithmetic/cla_lookahead_4.v"

`timescale 1ns / 1ps

module cla_4bit (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout,
    output       pg,
    output       gg
);

    wire [3:0] p = a ^ b;
    wire [3:0] g = a & b;
    wire [3:0] c;                       // c[i] = carry out of bit i

    cla_lookahead_4 lookahead (.p(p), .g(g), .cin(cin), .c(c), .pg(pg), .gg(gg));

    assign sum  = p ^ {c[2:0], cin};
    assign cout = c[3];

endmodule

`endif
