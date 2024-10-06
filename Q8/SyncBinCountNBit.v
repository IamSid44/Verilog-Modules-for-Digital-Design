`timescale 1ns / 1ps

`include "TFF.v"

module SyncBinCountNBit #(parameter N = 4)(input Cnt, input Clk, input Rst, output wire [N - 1 : 0]Count);

    wire [N - 1 : 0]Inter;
    assign Inter[0] = Cnt;

    genvar i;
    generate
        for(i = 0; i < N; i = i + 1)
        begin : Stage_Loop
        if(i > 0)
            assign Inter[i] = Inter[i - 1] & Count[i - 1];
        TFF Tff(.T(Inter[i]), .Clk(Clk), .Q(Count[i]), .Reset(Rst));
        end
    endgenerate
    
endmodule