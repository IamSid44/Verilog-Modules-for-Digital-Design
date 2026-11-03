// -----------------------------------------------------------------------------
// decoder2to4 - 2-to-4 decoder with enable, built from three decoder1to2
//
//   en = 0 : out = 0000
//   en = 1 : out[in] = 1, all other outputs 0
//
// The top decoder splits on in[1] and enables one of two lower decoders, which
// each split on in[0].
// -----------------------------------------------------------------------------
`ifndef DECODER2TO4_V
`define DECODER2TO4_V

`include "rtl/combinational/decoder1to2.v"

`timescale 1ns / 1ps

module decoder2to4 (
    input        en,
    input  [1:0] in,
    output [3:0] out
);

    wire [1:0] half;

    decoder1to2 d_top (.en(en),      .in(in[1]), .out(half));
    decoder1to2 d_lo  (.en(half[0]), .in(in[0]), .out(out[1:0]));
    decoder1to2 d_hi  (.en(half[1]), .in(in[0]), .out(out[3:2]));

endmodule

`endif
