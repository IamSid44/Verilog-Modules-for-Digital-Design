// -----------------------------------------------------------------------------
// seq_circuit_tff - sequential circuit with two T flip-flops (no inputs)
//
//   T_A = A + B
//   T_B = A' + B
//
// The state is {A, B}. Positive-edge triggered, asynchronous active-low reset
// to RESET_STATE (default 00). The state sequence is:
//
//   00 -> 01 -> 10 -> 00 -> ...      (a 3-state cycle)
//   11 -> 00                         (11 is not on the cycle; it is only
//                                     reachable through reset)
//
// Set RESET_STATE = 2'b11 to start the circuit in the transient state and
// observe 11 -> 00.
// -----------------------------------------------------------------------------
`ifndef SEQ_CIRCUIT_TFF_V
`define SEQ_CIRCUIT_TFF_V

`include "rtl/sequential/tff.v"

`timescale 1ns / 1ps

module seq_circuit_tff #(
    parameter [1:0] RESET_STATE = 2'b00
) (
    input  clk,
    input  rst_n,
    output a,
    output b
);

    wire t_a = a | b;
    wire t_b = ~a | b;

    tff #(.RESET_VAL(RESET_STATE[1])) ff_a (.clk(clk), .rst_n(rst_n), .t(t_a), .q(a), .q_n());
    tff #(.RESET_VAL(RESET_STATE[0])) ff_b (.clk(clk), .rst_n(rst_n), .t(t_b), .q(b), .q_n());

endmodule

`endif
