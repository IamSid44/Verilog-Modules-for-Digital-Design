`timescale 1ns / 1ps

`include "TFF.v"

// Considering A and B as the outputs
module Cir9b (input Clk, input Rst, output Aout, output Bout);

    wire Not_Aout, Not_Bout;
    wire Ain, Bin;

    assign Ain = Aout | Bout;
    assign Bin = Not_Aout | Bout;

    TFF A(.T(Ain), .Clk(Clk), .Reset(Rst), .Q(Aout), .Not_Q(Not_Aout));
    TFF B(.T(Bin), .Clk(Clk), .Reset(Rst), .Q(Bout), .Not_Q(Not_Bout));
    
endmodule