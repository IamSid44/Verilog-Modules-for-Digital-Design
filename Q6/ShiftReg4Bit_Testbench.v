`timescale 1ns / 1ps

module UniShiftReg4Bit_Testbench;

    reg [1:0]S;
    reg [3:0]Load;
    reg SRin, SLin, Clr, Clk;
    wire [3:0]Out;

    UniShiftReg4Bit uut(.S(S), .Load(Load), .SRin(SRin), .SLin(SLin), .Clr(Clr), .Clk(Clk), .Out(Out));

    initial
    begin
        Clk = 0;
        #1
        forever #5 Clk = ~Clk;
    end

    initial
    begin
        $dumpfile("ShiftReg4Bit.vcd");
        $dumpvars(1, uut);    

        // Initialize inputs
        S = 2'b00;
        Load = 4'b0000;
        SRin = 0;
        SLin = 0;
        Clr = 1; // Active Low
        Clk = 1;
        
        // Reset and Parallel Load
        Clr = 0;
        #10; 
        S = 3; 
        Load = 4'b1010; // Try to Load with the Reset
        #10; 
        Clr = 1;
        #10; // Should Load now
        
        // Hold
        S = 2'b00;
        #10; 
        Load = 4'b0101;
        #10; // Output shouldn't change
            
        // Right Shift
        S = 2'b01;
        SRin = 1;
        #40; // New value should be loaded and right shifted multiple times
        
        // Left Shift
        S = 2'b10;
        SLin = 0;
        #40; // Left Shift Multiple times
        
        $finish;
    end

endmodule