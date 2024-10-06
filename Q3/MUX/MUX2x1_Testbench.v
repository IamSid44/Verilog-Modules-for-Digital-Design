`timescale 1ns / 1ps

module Mux2x1_Test;

    reg a, b, en;
    wire y;

    Mux2x1 uut(.in1(a), .in2(b), .s0(en), .y(y));

    initial begin
    
        $dumpfile("MUX2x1.vcd");
        $dumpvars(1, uut);

        a = 1'b0;
        b = 1'b0;
        en = 1'b0;

        #40 $finish;

    end

    always #5 a = ~a;
    always #10 b = ~b;
    always #20 en = ~en;

endmodule