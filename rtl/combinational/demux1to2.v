// -----------------------------------------------------------------------------
// demux1to2 - 1-to-2 demultiplexer (gate level)
//
//   y[sel] = in, the other output is 0
// -----------------------------------------------------------------------------
`ifndef DEMUX1TO2_V
`define DEMUX1TO2_V

`timescale 1ns / 1ps

module demux1to2 (
    input        in,
    input        sel,
    output [1:0] y
);

    wire sel_n;

    not (sel_n, sel);
    and (y[0], in, sel_n);
    and (y[1], in, sel);

endmodule

`endif
