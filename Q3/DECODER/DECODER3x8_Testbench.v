`timescale 1ns / 1ps

module Decoder2x4_Testbench;

    reg [2:0]in;
    reg en;
    wire [7:0]out;

    Decoder3x8 uut(.en(en), .in(in), .out(out));

    initial
    begin
        
        $dumpfile("DECODER3x8.vcd");
        $dumpvars(1, uut);

        in = 1'b0;
        en = 1'b0;

        for(integer i = 0; i < 16; i++)
        begin
            {en, in} = i; // Order of change here is DBCA (0000->0001)
            #5;
        end

        $finish;

    end

endmodule