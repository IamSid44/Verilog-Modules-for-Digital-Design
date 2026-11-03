// -----------------------------------------------------------------------------
// mux4to1 - 4-to-1 multiplexer, built from three mux2to1
//
//   y = in[sel]
//
// sel[0] picks within each pair (in[1:0] and in[3:2]); sel[1] picks the pair.
// -----------------------------------------------------------------------------
`ifndef MUX4TO1_V
`define MUX4TO1_V

`include "rtl/combinational/mux2to1.v"

`timescale 1ns / 1ps

module mux4to1 (
    input  [3:0] in,
    input  [1:0] sel,
    output       y
);

    wire lo, hi;

    mux2to1 m_lo  (.in0(in[0]), .in1(in[1]), .sel(sel[0]), .y(lo));
    mux2to1 m_hi  (.in0(in[2]), .in1(in[3]), .sel(sel[0]), .y(hi));
    mux2to1 m_out (.in0(lo),    .in1(hi),    .sel(sel[1]), .y(y));

endmodule

`endif
