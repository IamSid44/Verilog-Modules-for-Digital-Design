`timescale 1ns / 1ps

module q11_Testbench;

    reg Clk, Clr, x;
    wire y;

    FSMSequenceDetector uut(.Clk(Clk), .Clr(Clr), .X(x), .Y(y));

    initial
    begin
        Clk = 0;
        Clr = 1;
        #1
        Clr = 0;
        forever #5 Clk = ~Clk; // 6, 16, 26, ...
    end

    initial
    begin
        $dumpfile("q11.vcd");
        $dumpvars(1, uut);
        
        x = 0;

        for(integer i = 0; i < 4; i++)
        begin
            x = ~x;
            #20;
        end

        Clr = 1;
        #10;
        Clr = 0;
        x = 1;

        for(integer i = 0; i < 4; i++)
        begin
            x = ~x;
            #20;
        end

        $finish;

    end

endmodule