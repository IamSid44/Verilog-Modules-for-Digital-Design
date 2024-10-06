`timescale 1ns / 1ps

module Mux4x1_Test;

    reg [3:0]in;
    reg [1:0]en;
    wire y;

    Mux4x1 uut(.in(in), .s(en), .y(y));

    initial begin
    
        $dumpfile("MUX4x1.vcd");
        $dumpvars(1, uut);

        for(integer i = 0; i < 64; i++)
        begin
            {en[1], en[0], in[3], in[2], in[1], in[0]} = i; 
            #5;
        end

        $finish;

    end

    // always #5 in[0] = ~in[0];
    // always #10 in[1] = ~in[1];
    // always #20 in[2] = ~in[2];
    // always #40 in[3] = ~in[3];
    // always #80 en[0] = ~en[0];
    // always #160 en[1] = ~en[1];

endmodule