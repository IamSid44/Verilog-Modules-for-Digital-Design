// -----------------------------------------------------------------------------
// cla_4bit - 4-bit carry-lookahead adder
//
//   {cout, sum} = a + b + cin
//
// Instead of waiting for each carry to ripple, every carry is computed
// directly from the per-bit propagate (p) and generate (g) signals:
//
//   p[i] = a[i] ^ b[i]        g[i] = a[i] & b[i]
//   c[i+1] = g[i] + p[i].c[i]            (expanded below so each carry only
//                                         depends on p, g and cin)
//   sum[i] = p[i] ^ c[i]
// -----------------------------------------------------------------------------
`ifndef CLA_4BIT_V
`define CLA_4BIT_V

`timescale 1ns / 1ps

module cla_4bit (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);

    wire [3:0] p = a ^ b;
    wire [3:0] g = a & b;
    wire [4:0] c;       // c[i] is the carry into bit i; c[4] is cout

    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & cin);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])
                       | (p[2] & p[1] & p[0] & cin);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
                       | (p[3] & p[2] & p[1] & g[0])
                       | (p[3] & p[2] & p[1] & p[0] & cin);

    assign sum  = p ^ c[3:0];
    assign cout = c[4];

endmodule

`endif
