// -----------------------------------------------------------------------------
// full_adder - 1-bit full adder (gate level, two half adders and an OR)
//
//   p    = a ^ b                 (propagate)
//   sum  = p ^ cin
//   cout = a.b + p.cin           (same as the majority of a, b, cin)
//
// Sharing p between sum and cout uses only 2-input gates.
// -----------------------------------------------------------------------------
`ifndef FULL_ADDER_V
`define FULL_ADDER_V

`timescale 1ns / 1ps

module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    wire p, g, pc;

    xor (p,   a, b);
    xor (sum, p, cin);

    and (g,  a, b);
    and (pc, p, cin);
    or  (cout, g, pc);

endmodule

`endif
