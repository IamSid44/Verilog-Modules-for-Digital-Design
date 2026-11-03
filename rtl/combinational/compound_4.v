// -----------------------------------------------------------------------------
// compound_4 - F(A,B,C,D) = PI M(1,3,5,7,13,15), using NAND gates only
//
// A is the MSB of the minterm index. The zeros of F are 1,3,5,7,13,15, i.e.
// D = 1 in every (A,B) block except A=1,B=0, so
//   F = D' + AB'  =  (D . (AB')')'
// C does not appear in the function; the port is kept so the module has the
// full F(A,B,C,D) interface.
//
// A NAND with its inputs tied together is used as an inverter.
// -----------------------------------------------------------------------------
`ifndef COMPOUND_4_V
`define COMPOUND_4_V

`timescale 1ns / 1ps

module compound_4 (
    input  a, b, c, d,
    output y
);

    wire b_n, p;

    nand (b_n, b, b);
    nand (p,   a, b_n);   // (AB')'
    nand (y,   p, d);

endmodule

`endif
