`timescale 1ns / 1ps

module qb_Testbench;

    reg Clk, Clr;
    wire A, B;

    Cir9b uut(.Clk(Clk), .Rst(Clr), .Aout(A), .Bout(B));

    initial
    begin
        Clk = 0;
        Clr = 0;
        #1
        Clr = 1;
        forever #5 Clk = ~Clk;
    end

    initial
    
    begin
        forever #10 $monitor("A = %b, B = %b", A, B);
    end

    initial
    begin
        $dumpfile("qb.vcd");
        $dumpvars(0, qb_Testbench);
        
        #100 $finish;

    end

endmodule