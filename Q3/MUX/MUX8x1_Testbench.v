`timescale 1ns / 1ps

module Mux8x1_Test;

    reg [7:0]in;
    reg [2:0]en;
    wire y;

    Mux8x1 uut(.in(in), .s(en), .y(y));

    initial begin
    
        $dumpfile("MUX8x1.vcd");
        $dumpvars(1, uut);

        // for(integer i = 0; i < 2048; i++)
        // begin
        //     {en[2], en[1], en[0], in[7], in[6], in[5], in[4], in[3], in[2], in[1], in[0]} = i; 
        //     #5;
        // end

        for(integer i = 0; i < 2048; i++)
        begin
            {en, in} = i; 
            #5;
        end

        $finish;

    end

endmodule