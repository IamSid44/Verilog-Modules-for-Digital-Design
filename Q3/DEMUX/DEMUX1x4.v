`timescale 1ns / 1ps

module Demux1x4 (in, y, en);

    input in;
    input [1:0]en;
    output [3:0]y;
    wire [1:0]Demux;

    Demux1x2 Demux1(.in(in), .en(en[1]), .y(Demux));
    Demux1x2 Demux2(.in(Demux[0]), .en(en[0]), .y(y[1:0]));
    Demux1x2 Demux3(.in(Demux[1]), .en(en[0]), .y(y[3:2]));
    
endmodule