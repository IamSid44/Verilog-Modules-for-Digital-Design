`timescale 1ns / 1ps

module Demux1x4_Testbench;

    reg in;
    reg [1:0]en;
    wire [3:0]y;

    Demux1x4 uut(.in(in), .en(en), .y(y));

    initial begin

        $dumpfile("DEMUX1x4.vcd");
        $dumpvars(1, uut);

        in = 1'b0;
        en = 1'b0;

        for(integer i = 0; i < 8; i++)
        begin
            {en, in} = i;
            #5;
        end

        $finish;
    end
    
endmodule