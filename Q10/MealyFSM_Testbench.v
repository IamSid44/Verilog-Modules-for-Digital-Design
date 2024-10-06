`timescale 1ns / 1ps

module MealyFSM_Testbench;

    reg Clk, Clr, x;
    wire y;

    MealyFSM uut(.Clk(Clk), .Clr(Clr), .x(x), .y(y));

    initial
    begin
        Clk = 0;
        Clr = 0;
        #1
        Clr = 1;
        forever #5 Clk = ~Clk; // 6, 16, 26, ...
    end

    initial
    begin
        $monitor("Time=%0t, x=%b, y=%b", $time, x, y);
    end

    initial
    begin
        $dumpfile("MealyFSM.vcd");
        $dumpvars(1, uut);
        
        x = 0;
        #30 // 0 -> 1 -> 2 -> 1
        x = 1;
        #40; // 1 -> 3 -> 0 -> 2 -> 3
        x = 0;
        #10 // 3 -> 2

        $finish;

    end

endmodule