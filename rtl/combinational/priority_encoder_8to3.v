// -----------------------------------------------------------------------------
// priority_encoder_8to3 - 8-to-3 priority encoder with enable (gate level)
//
//   in[7] has the highest priority. `out` is the index of the highest set bit
//   of `in`.
//
//   en = 0            : out = 000, valid = 0
//   en = 1, in = 0    : out = 000, valid = 0   (no input asserted)
//   en = 1, in != 0   : out = index of highest set bit, valid = 1
//
// `valid` distinguishes "in[0] is the highest set bit" from "nothing is set",
// since both give out = 000.
//
// Equations (x = out[2], y = out[1], z = out[0]):
//   x = in4 + in5 + in6 + in7
//   y = in6 + in7 + in5'.in4'.(in3 + in2)
//   z = in7 + in6'.in5 + in6'.in4'.in3 + in6'.in4'.in2'.in1
// -----------------------------------------------------------------------------
`ifndef PRIORITY_ENCODER_8TO3_V
`define PRIORITY_ENCODER_8TO3_V

`timescale 1ns / 1ps

module priority_encoder_8to3 (
    input        en,
    input  [7:0] in,
    output [2:0] out,
    output       valid
);

    wire n2, n4, n5, n6;
    wire in2_or_in3, any;
    wire y_term, z_term5, z_term3, z_term1;
    wire x_raw, y_raw, z_raw;

    not (n2, in[2]);
    not (n4, in[4]);
    not (n5, in[5]);
    not (n6, in[6]);

    or  (in2_or_in3, in[2], in[3]);

    and (y_term,  n5, n4, in2_or_in3);
    and (z_term5, n6, in[5]);
    and (z_term3, n6, n4, in[3]);
    and (z_term1, n6, n4, n2, in[1]);

    or  (x_raw, in[4], in[5], in[6], in[7]);
    or  (y_raw, in[6], in[7], y_term);
    or  (z_raw, in[7], z_term5, z_term3, z_term1);

    and (out[2], x_raw, en);
    and (out[1], y_raw, en);
    and (out[0], z_raw, en);

    or  (any, in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7]);
    and (valid, any, en);

endmodule

`endif
