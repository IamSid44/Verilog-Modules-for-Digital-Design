// Positive Edge Triggered Active Low Asynchronous Reset FLip FLip
`timescale 1ns / 1ps

module TFF_Testbench;

    reg clk;
    reg rst;
    reg T;
    wire Q, Q_Not;
    
    TFF uut (.Clk(clk), .Reset(rst), .T(T), .Q(Q), .Not_Q(Q_Not));

    initial
    begin
        $dumpfile("TFF.vcd");
        $dumpvars(1, uut);
        
        clk = 1;
        rst = 0;
        T = 0;
        
        #160 $finish;
    end

    initial
    begin
        #1;
        forever #5 clk = ~clk;
    end

    always #20 T = ~T;
    always #80 rst = ~rst;

endmodule
