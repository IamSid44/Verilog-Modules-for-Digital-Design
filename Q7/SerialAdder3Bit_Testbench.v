`timescale 1ns / 1ps

module SerialAdder_Testbench;

    reg [1:0]S;
    reg SRinB, Clr, Clk;
    wire [2:0]OutA;

    SerialAdder3Bit uut(.SRInB(SRinB), .Clr(Clr), .Clk(Clk), .OA(OutA), .S(S));

    initial
    begin
        Clk = 0;
        #1
        forever #5 Clk = ~Clk;
    end

    initial
    begin
        $dumpfile("SerialAdder3Bit.vcd");
        $dumpvars(1, uut);    

        // Initialize inputs
        S = 2'b01; // Only want Hold or Right shift, 0 or 1
        SRinB = 1;
        Clr = 0; // Active Low, Reset all the elements
        Clk = 1;
        
        // // Reset
        // #10;
        // S = 1; // Try to shift right
        // #20;
        // Clr = 1;
        // #20; // Should Shift now
        
        // // Hold
        // S = 2'b00;
        // #10; // Output shouldn't change
        
        // // Right Shift
        // S = 2'b01;
        // SRinB = 1;
        // #40; // Right Shift Multiple Times
        
        // // Right Shift
        // S = 2'b01;
        // SRinB = 1;
        // #40; // Right Shift Multiple Times
        
        // Test Case 010 + 011 = 101
        // #10 Clr = 1; SRinB = 0;
        // #10 SRinB = 1;
        // #10 SRinB = 0;
        // #10 SRinB = 1;
        // #20 SRinB = 0;
        // #40;

        // Test Case 110 + 011 = 1001
        #10 Clr = 1; SRinB = 0;
        #10 SRinB = 1;
        #40 SRinB = 0;
        #40;

        $finish;
    end

endmodule