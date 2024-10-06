// Positive Edge Triggered Active Low Asynchronous Reset FLip FLip
`timescale 1ns / 1ps

module DFF_Testbench;

    reg clk;
    reg rst;
    reg D;
    wire Q, Q_Not;
    
    DFF uut (.Clk(clk), .Reset(rst), .D(D), .Q(Q), .Not_Q(Q_Not));

    initial begin
        $dumpfile("DFF.vcd");
        $dumpvars(1, uut);
        
        clk = 1;
        rst = 0;
        D = 0;
        
        #160 $finish;
    end

    initial
    begin
        #1;
        forever #5 clk = ~clk;
    end

    always #20 D = ~D;
    always #80 rst = ~rst;

endmodule
