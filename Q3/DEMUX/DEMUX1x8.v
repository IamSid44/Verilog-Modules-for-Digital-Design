`timescale 1ns / 1ps

module Demux1x8 (in, y, en);

    input in;
    input [2:0]en;
    output [7:0]y;
    // wire [1:0]Demux;
    wire [3:0]Demux;

    // Demux1x2 Demux1(.in(in), .en(en[2]), .y(Demux));
    Demux1x4 Demux1 (.in(in), .en({en[2], en[2]}), .y(Demux));
    Demux1x4 Demux2(.in(Demux[0]), .en(en[1:0]), .y(y[3:0]));
    // Demux1x4 Demux3(.in(Demux[1]), .en(en[1:0]), .y(y[7:4]));
    Demux1x4 Demux3(.in(Demux[3]), .en(en[1:0]), .y(y[7:4]));
    
endmodule