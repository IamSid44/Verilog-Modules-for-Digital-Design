// -----------------------------------------------------------------------------
// tff - T (toggle) flip-flop
//
// Positive-edge triggered, asynchronous active-low reset.
//
//   rst_n = 0          : q = RESET_VAL immediately
//   posedge clk, t = 1 : q <= ~q
//   posedge clk, t = 0 : q holds
//   q_n is always ~q
//
// RESET_VAL defaults to 0. It can be set to 1 to start a circuit in a state
// other than all-zeros (see seq_circuit_tff).
// -----------------------------------------------------------------------------
`ifndef TFF_V
`define TFF_V

`timescale 1ns / 1ps

module tff #(
    parameter RESET_VAL = 1'b0
) (
    input      clk,
    input      rst_n,
    input      t,
    output reg q,
    output     q_n
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= RESET_VAL;
        else if (t)
            q <= ~q;
    end

    assign q_n = ~q;

endmodule

`endif
