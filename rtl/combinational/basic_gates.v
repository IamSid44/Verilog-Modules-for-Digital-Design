// -----------------------------------------------------------------------------
// basic_gates - the seven basic logic gates, built from Verilog gate primitives
//
//   y_and  = a & b        y_nand = ~(a & b)
//   y_or   = a | b        y_nor  = ~(a | b)
//   y_xor  = a ^ b        y_xnor = ~(a ^ b)
//   y_not  = ~a           (input b is not used by the NOT gate)
// -----------------------------------------------------------------------------
`ifndef BASIC_GATES_V
`define BASIC_GATES_V

`timescale 1ns / 1ps

module basic_gates (
    input  a,
    input  b,
    output y_and,
    output y_or,
    output y_nand,
    output y_nor,
    output y_xor,
    output y_xnor,
    output y_not
);

    and  (y_and,  a, b);
    or   (y_or,   a, b);
    nand (y_nand, a, b);
    nor  (y_nor,  a, b);
    xor  (y_xor,  a, b);
    xnor (y_xnor, a, b);
    not  (y_not,  a);

endmodule

`endif
