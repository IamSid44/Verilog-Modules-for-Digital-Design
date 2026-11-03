// -----------------------------------------------------------------------------
// decoder1to2 - 1-to-2 decoder with enable (gate level)
//
//   en = 0 : out = 00
//   en = 1 : out[in] = 1, the other output is 0
// -----------------------------------------------------------------------------
`ifndef DECODER1TO2_V
`define DECODER1TO2_V

`timescale 1ns / 1ps

module decoder1to2 (
    input        en,
    input        in,
    output [1:0] out
);

    wire in_n;

    not (in_n, in);
    and (out[0], en, in_n);
    and (out[1], en, in);

endmodule

`endif
