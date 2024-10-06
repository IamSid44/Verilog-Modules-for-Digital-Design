`timescale 1ns / 1ps

`include "TFF.v"

module RippleCountNBit #(parameter N = 4)(input Cnt, input Clk, input Rst, output wire [N - 1 : 0]Count);

    genvar i;
    generate
        for(i = 0; i < N; i = i + 1)
        begin : Stage_Loop
        if(i == 0)
            TFF Tff(.T(1'b1), .Clk(Clk & Cnt), .Q(Count[i]), .Reset(Rst));    
        else
            TFF Tff(.T(1'b1), .Clk(~Count[i - 1]), .Q(Count[i]), .Reset(Rst));
        end
    endgenerate
    
endmodule