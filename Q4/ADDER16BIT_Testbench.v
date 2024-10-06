`timescale 1ns / 1ps

module FullAdderNBit_Testbench;

    parameter Num = 16;
    reg [Num - 1 : 0]a;
    reg [Num - 1 : 0]b;
    reg Cin;
    wire [Num - 1 : 0]s;
    wire c;

    FullAdderNBit #(.Num(Num)) uut(.In1(a), .In2(b), .Carry(c), .Sum(s), .Cin(Cin));

    initial
    begin

        $dumpfile("ADDER16BIT.vcd");
        $dumpvars(1, uut);
        
        a = 16'd20768;
        b = 16'd13344;
        Cin = 1'b0;
        #10;

        a = 16'd32767;
        b = 16'd59483;
        Cin = 1'b0;
        #10;

        $finish;

    end

endmodule