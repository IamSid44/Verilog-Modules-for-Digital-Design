// -----------------------------------------------------------------------------
// demux1to4 - 1-to-4 demultiplexer, built from three demux1to2
//
//   y[sel] = in, the other outputs are 0
//
// sel[1] steers `in` to the lower or upper pair; sel[0] picks within the pair.
// -----------------------------------------------------------------------------
`ifndef DEMUX1TO4_V
`define DEMUX1TO4_V

`include "rtl/combinational/demux1to2.v"

`timescale 1ns / 1ps

module demux1to4 (
    input        in,
    input  [1:0] sel,
    output [3:0] y
);

    wire [1:0] pair;

    demux1to2 d_top (.in(in),      .sel(sel[1]), .y(pair));
    demux1to2 d_lo  (.in(pair[0]), .sel(sel[0]), .y(y[1:0]));
    demux1to2 d_hi  (.in(pair[1]), .sel(sel[0]), .y(y[3:2]));

endmodule

`endif
