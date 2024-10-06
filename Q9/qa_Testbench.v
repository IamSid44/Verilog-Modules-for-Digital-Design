`timescale 1ns / 1ps

module qa_Testbench();

    reg x, y, A, B, Clk, Clr;
    wire z;

    Cir uut(.x(x), .y(y), .Clk(Clk), .Rst(Clr), .z(z), .TestA(A), .TestB(B));

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
        $dumpfile("qa.vcd");
        $dumpvars(0, qa_Testbench);

        A = 0;
        B = 0;
        x = 0;
        y = 0;
        
        for(integer i = 0; i < 16; i++)
        begin
            {A, B, x, y} = i;
            #10;
        end
        
        $finish;

    end

endmodule