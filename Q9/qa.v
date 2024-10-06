`timescale 1ns / 1ps

`include "DFF.v"

// For the sake of testing, we will also set the states of A and B
module Cir (input x, input y, input Clk, input Rst, output z, input TestA, input TestB, output Aout, output Bout);

    wire Not_Aout, Not_Bout;
    wire Ain, Bin;

    assign Ain = (x & (~y)) | (x & TestB); // Change Test to in
    assign Bin = (x & TestA) | (x & ~TestB); // Change Test to in
    assign z = TestA; // Change Test to in

    DFF A(.D(Ain), .Clk(Clk), .Reset(Rst), .Q(Aout), .Not_Q(Not_Aout));
    DFF B(.D(Bin), .Clk(Clk), .Reset(Rst), .Q(Bout), .Not_Q(Not_Bout));
    
endmodule