`timescale 1ns / 1ps

module SyncBinCount4Bit_Testbench;

    reg Cnt, Clk, Rst;
    wire [3 : 0]Out;

    SyncBinCountNBit #(.N(4)) uut(.Cnt(Cnt), .Clk(Clk), .Count(Out), .Rst(Rst));

    initial
    begin
        Clk = 0;
        #1
        forever #5 Clk = ~Clk;
    end

    initial
    begin
        $dumpfile("SyncBinCount4Bit.vcd");
        $dumpvars(1, uut);    

        Rst = 0;
        Cnt = 0;
        #5;
        Cnt = 1;
        #5;
        Rst = 1;
        Cnt = 0;
        #5;
        Cnt = 1;
        #160;

        $finish;
    end

endmodule