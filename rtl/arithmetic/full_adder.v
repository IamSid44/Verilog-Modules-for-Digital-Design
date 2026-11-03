// -----------------------------------------------------------------------------
// full_adder - 1-bit full adder (gate level)
//
//   sum  = a ^ b ^ cin
//   cout = ab + bc + ac     (majority of a, b, cin)
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

    wire ab, bc, ac;

    xor (sum, a, b, cin);

    and (ab, a, b);
    and (bc, b, cin);
    and (ac, a, cin);
    or  (cout, ab, bc, ac);

endmodule

`endif
