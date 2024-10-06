`timescale 1ns / 1ps

module Decoder1x2_Testbench;

    reg in;
    reg en;
    wire [1:0]out;

    Decoder1x2 uut(.en(en), .in(in), .out(out));

    initial
    begin
        
        $dumpfile("DECODER1x2.vcd");
        $dumpvars(1, uut);

        in = 1'b0;
        en = 1'b0;

        for(integer i = 0; i < 4; i++)
        begin
            {en, in} = i;
            #5;
        end

        $finish;

    end

endmodule