`timescale 1ns / 1ps

module PriEnc8x3_Testbench;

    reg [7:0]D;
    reg en;
    wire [2:0]xyz;

    PriEnc8x3 uut(.in(D), .out(xyz), .en(en));

    initial
    begin

        $dumpfile("PriEnc8x3.vcd");
        $dumpvars(1, uut);

        for(integer i = 1; i < 512; i++)
        begin
            {en, D} = i;
            #5;
        end

        $finish;

    end

endmodule