`timescale 1ns / 1ps

module Mux8x1(in, s, y);

    input [7:0]in;
    input [2:0]s;
    output y, y2;
    wire mux1, mux2;

    Mux4x1 Mux1(in[3:0], s[1:0], mux1);
    Mux4x1 Mux2(in[7:4], s[1:0], mux2);
    // Mux2x1 Mux3(mux1, mux2, s[2], y);
    Mux4x1 Mux3({mux2, 1'b0, 1'b0, mux1}, {s[2], s[2]}, y2);

endmodule