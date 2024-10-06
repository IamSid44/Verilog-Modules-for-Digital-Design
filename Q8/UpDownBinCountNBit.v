`timescale 1ns / 1ps

`include "TFF.v"

// CntUp takes precedance in case both CntUp and CntDown are 1
module UpDownBinCountNBit #(parameter N = 4)(input CntUp, input CntDown, input Clk, input Rst, output wire [N - 1 : 0]Count);

    wire [N - 1 : 0]Up;
    wire [N - 1 : 0]Down;
    wire [N - 1 : 0]In;

    assign Up[0] = CntUp;
    assign Down[0] = (CntDown & (~CntUp));

    genvar i;
    generate
        for(i = 0; i < N; i = i + 1)
        begin : Stage_Loop
        if(i > 0)
        begin
            assign Up[i] = Up[i - 1] & Count[i - 1];
            assign Down[i] = Down[i - 1] & (~Count[i - 1]);
        end
        assign In[i] = Up[i] | Down[i];
        TFF Tff(.T(In[i]), .Clk(Clk), .Q(Count[i]), .Reset(Rst));
        end
    endgenerate
    
endmodule