`timescale 1ns / 1ps

module RSFF_Testbench;

    reg R, S;
    wire Q, Q_Not;
    
    RSFF uut (.R(R), .S(S), .Q(Q), .Not_Q(Q_Not));

    initial
    begin
        
        $dumpfile("RSFF.vcd");
        $dumpvars(1, uut);
        
        R = 0;
        S = 0;
        
        #80 $finish;

    end

    always #40 R = ~R;
    always #20 S = ~S;
    
endmodule