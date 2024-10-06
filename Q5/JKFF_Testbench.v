// Positive Edge Triggered Active Low Asynchronous Reset FLip FLip
`timescale 1ns / 1ps

module JKFF_Testbench;

    reg clk, J, K, rst;
    wire Q, Q_Not;
    
    JKFF uut (.Clk(clk), .Reset(rst), .J(J), .K(K), .Q(Q), .Not_Q(Q_Not));

    initial begin
        $dumpfile("JKFF.vcd");
        $dumpvars(1, uut);
        
        clk = 1;
        rst = 0;
        J = 0;
        K = 0;
        
        #160 $finish;
    end

    initial
    begin
        #1;
        forever #5 clk = ~clk;
    end

    always #80 rst = ~rst;
    always #40 K = ~K;
    always #20 J = ~J;

endmodule