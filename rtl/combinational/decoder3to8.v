// -----------------------------------------------------------------------------
// decoder3to8 - 3-to-8 decoder with enable, built from one decoder1to2 and two
// decoder2to4
//
//   en = 0 : out = 00000000
//   en = 1 : out[in] = 1, all other outputs 0
// -----------------------------------------------------------------------------
`ifndef DECODER3TO8_V
`define DECODER3TO8_V

`include "rtl/combinational/decoder1to2.v"
`include "rtl/combinational/decoder2to4.v"

`timescale 1ns / 1ps

module decoder3to8 (
    input        en,
    input  [2:0] in,
    output [7:0] out
);

    wire [1:0] half;

    decoder1to2 d_top (.en(en),      .in(in[2]),   .out(half));
    decoder2to4 d_lo  (.en(half[0]), .in(in[1:0]), .out(out[3:0]));
    decoder2to4 d_hi  (.en(half[1]), .in(in[1:0]), .out(out[7:4]));

endmodule

`endif
