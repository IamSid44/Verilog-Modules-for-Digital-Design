`timescale 1ns / 1ps

module Demux1x2_Testbench;

    reg in, en;
    wire [1:0]y;

    Demux1x2 uut(.in(in), .en(en), .y(y));

    initial begin

        $dumpfile("DEMUX1x2.vcd");
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