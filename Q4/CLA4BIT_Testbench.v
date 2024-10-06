`timescale 1ns / 1ps

module CLA4Bit_Testbench;

    reg [3:0]a;
    reg [3:0]b;
    reg Cin;
    wire [3:0]s;
    wire c;

    CLA4Bit uut(.a(a), .b(b), .cin(Cin), .s(s), .cout(c));

    initial
    begin

        $dumpfile("CLA4BIT.vcd");
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