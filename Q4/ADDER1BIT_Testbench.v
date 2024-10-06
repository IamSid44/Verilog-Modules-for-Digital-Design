`timescale 1ns / 1ps

module FullAdder1Bit_Testbench;

    reg a, b, cin;
    wire c, s;

    FullAdder1Bit uut(.a(a), .b(b), .c(cin), .Carry(c), .Sum(s));

    initial
    begin

        $dumpfile("ADDER1BIT.vcd");
        $dumpvars(1, uut);

        for(integer i = 0; i < 8; i++)
        begin
            {a, b, cin} = i;
            #5;
        end

        $finish;

    end

endmodule