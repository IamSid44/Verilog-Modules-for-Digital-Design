`timescale 1ns / 1ps

module UpDownBinCount4Bit_Testbench;

    reg CntUp, CntDown, Clk, Rst;
    wire [3 : 0]Out;

    UpDownBinCountNBit #(.N(4)) uut(.CntUp(CntUp), .CntDown(CntDown), .Clk(Clk), .Count(Out), .Rst(Rst));

    initial
    begin
        Clk = 0;
        #1
        forever #5 Clk = ~Clk;
    end

    initial
    begin
        $dumpfile("UpDownBinCount4Bit.vcd");
        $dumpvars(1, uut);    

        Rst = 0;
        CntUp = 0;
        CntDown = 0;
        #5;
        CntUp = 1;
        CntDown = 0;
        #5;
        CntUp = 0;
        CntDown = 1;
        #5
        CntUp = 1;
        CntDown = 1;
        #5
        Rst = 1;
        CntUp = 0;
        CntDown = 0;
        #5;
        CntUp = 1;
        CntDown = 0;
        #200;
        CntDown = 1;
        #50;
        CntUp = 0;
        CntDown = 1;
        #200;

        $finish;
    end

endmodule