`timescale 1ns / 1ps

module FullAdder1Bit_Testbench;

    reg [3:0]a;
    reg [3:0]b;
    reg Cin;
    wire [3:0]s;
    wire c;

    FullAdder4Bit uut(.In1(a), .In2(b), .Carry(c), .Sum(s), .Cin(Cin));

    initial
    begin

        $dumpfile("ADDER4BIT.vcd");
        $dumpvars(1, uut);

        for(integer k = 0; k < 2; k++)
        begin
            Cin = k;
            for(integer i = 0; i < 16; i++)
            begin
                a = i;
                for(integer j = 0; j < 16; j++)
                begin
                    b = j;
                    #5;
                end
            end
        end

        $finish;

    end

endmodule