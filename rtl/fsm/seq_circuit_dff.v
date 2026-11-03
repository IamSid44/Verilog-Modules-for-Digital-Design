// -----------------------------------------------------------------------------
// seq_circuit_dff - sequential circuit with two D flip-flops, from equations
//
//   A(t+1) = x.y' + x.B
//   B(t+1) = x.A + x.B'
//   z      = A
//
// The state is {A, B}. Inputs are x and y; the output z depends only on the
// state (Moore). Positive-edge triggered, asynchronous active-low reset to
// state 00. The state bits are also brought out as `a` and `b`.
//
// State table (A B x y -> A+ B+):
//   00: xy=00->00  01->00  10->11  11->01
//   01: xy=00->00  01->00  10->10  11->10
//   10: xy=00->00  01->00  10->11  11->01
//   11: xy=00->00  01->00  10->11  11->11
// -----------------------------------------------------------------------------
`ifndef SEQ_CIRCUIT_DFF_V
`define SEQ_CIRCUIT_DFF_V

`include "rtl/sequential/dff.v"

`timescale 1ns / 1ps

module seq_circuit_dff (
    input  clk,
    input  rst_n,
    input  x,
    input  y,
    output z,
    output a,
    output b
);

    wire a_next = (x & ~y) | (x & b);
    wire b_next = (x & a)  | (x & ~b);

    dff ff_a (.clk(clk), .rst_n(rst_n), .d(a_next), .q(a), .q_n());
    dff ff_b (.clk(clk), .rst_n(rst_n), .d(b_next), .q(b), .q_n());

    assign z = a;

endmodule

`endif
