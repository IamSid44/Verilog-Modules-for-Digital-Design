// -----------------------------------------------------------------------------
// mux8to1 - 8-to-1 multiplexer, built from two mux4to1 and one mux2to1
//
//   y = in[sel]
// -----------------------------------------------------------------------------
`ifndef MUX8TO1_V
`define MUX8TO1_V

`include "rtl/combinational/mux2to1.v"
`include "rtl/combinational/mux4to1.v"

`timescale 1ns / 1ps

module mux8to1 (
    input  [7:0] in,
    input  [2:0] sel,
    output       y
);

    wire lo, hi;

    mux4to1 m_lo  (.in(in[3:0]), .sel(sel[1:0]), .y(lo));
    mux4to1 m_hi  (.in(in[7:4]), .sel(sel[1:0]), .y(hi));
    mux2to1 m_out (.in0(lo), .in1(hi), .sel(sel[2]), .y(y));

endmodule

`endif
