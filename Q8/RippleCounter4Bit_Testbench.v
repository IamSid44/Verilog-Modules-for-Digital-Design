`timescale 1ns / 1ps

module RippleCount4Bit_Testbench;

    reg Cnt, Clk, Rst;
    wire [3 : 0]Out;

    RippleCountNBit #(.N(4)) uut(.Cnt(Cnt), .Clk(Clk), .Count(Out), .Rst(Rst));

    initial
    begin
        Clk = 0;
        #1;
        forever #5 Clk = ~Clk;
    end

    initial
    begin
        $dumpfile("RippleCount4Bit.vcd");
        $dumpvars(1, uut);    

        Rst = 0;
        Cnt = 0;
        #10;
        Cnt = 1;
        #10;
        Rst = 1;
        Cnt = 0;
        #10;
        Cnt = 1;
        #160;

        $finish;
    end

endmodule