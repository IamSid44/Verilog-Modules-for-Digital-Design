`timescale 1ns / 1ps

module Mux4x1(in, s, y);

    input [3:0]in;
    input [1:0]s;
    output y;
    wire mux1, mux2;

    Mux2x1 Mux1(in[0], in[1], s[0], mux1);
    Mux2x1 Mux2(in[2], in[3], s[0], mux2);
    Mux2x1 Mux3(mux1, mux2, s[1], y);

endmodule