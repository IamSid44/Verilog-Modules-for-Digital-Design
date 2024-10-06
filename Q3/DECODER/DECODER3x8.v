`timescale 1ns / 1ps

module Decoder3x8 (en, in, out);

    input en;
    input [2:0]in; // in[0] = A, ...
    output [7:0]out; // out[0] = A'B'C', ... 
    // wire [1:0]DecodedInA; // DecodedInA[0] = A', ...
    wire [3:0]DecodedInA;

    // Decoder1x2 Decoder1(.in(in[0]), .en(en), .out(DecodedInA));
    Decoder2x4 Decoder1(.in({in[0], in[0]}), .en(en), .out(DecodedInA));
    Decoder2x4 Decoder2(.in(in[2:1]), .en(DecodedInA[0]), .out(out[3:0]));
    // Decoder2x4 Decoder3(.in(in[2:1]), .en(DecodedInA[1]), .out(out[7:4]));
    Decoder2x4 Decoder3(.in(in[2:1]), .en(DecodedInA[3]), .out(out[7:4]));

endmodule