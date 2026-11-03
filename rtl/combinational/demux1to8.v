// -----------------------------------------------------------------------------
// demux1to8 - 1-to-8 demultiplexer, built from one demux1to2 and two demux1to4
//
//   y[sel] = in, the other outputs are 0
// -----------------------------------------------------------------------------
`ifndef DEMUX1TO8_V
`define DEMUX1TO8_V

`include "rtl/combinational/demux1to2.v"
`include "rtl/combinational/demux1to4.v"

`timescale 1ns / 1ps

module demux1to8 (
    input        in,
    input  [2:0] sel,
    output [7:0] y
);

    wire [1:0] half;

    demux1to2 d_top (.in(in),      .sel(sel[2]),   .y(half));
    demux1to4 d_lo  (.in(half[0]), .sel(sel[1:0]), .y(y[3:0]));
    demux1to4 d_hi  (.in(half[1]), .sel(sel[1:0]), .y(y[7:4]));

endmodule

`endif
