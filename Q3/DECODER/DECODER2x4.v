`timescale 1ns / 1ps

module Decoder2x4 (en, in, out);

    input en;
    input [1:0]in; // in[0] = A, ...
    output [3:0]out; // out[0] = A'B', ... 
    wire [1:0]DecodedInA; // DecodedInA[0] = A', ...

    Decoder1x2 Decoder1(.in(in[0]), .en(en), .out(DecodedInA));
    Decoder1x2 Decoder2(.in(in[1]), .en(DecodedInA[0]), .out(out[1:0]));
    Decoder1x2 Decoder3(.in(in[1]), .en(DecodedInA[1]), .out(out[3:2]));

endmodule