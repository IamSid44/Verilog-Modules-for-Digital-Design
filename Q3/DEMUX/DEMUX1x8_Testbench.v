`timescale 1ns / 1ps

module Demux1x8_Testbench;

    reg in;
    reg [2:0]en;
    wire [7:0]y;

    Demux1x8 uut(.in(in), .en(en), .y(y));

    initial begin

        $dumpfile("DEMUX1x8.vcd");
        $dumpvars(1, uut);

        in = 1'b0;
        en = 1'b0;

        for(integer i = 0; i < 16; i++)
        begin
            {en, in} = i;
            #5;
        end

        $finish;
    end
    
endmodule