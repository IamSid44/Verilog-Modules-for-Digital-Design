`timescale 1ns / 1ps

module RSFF(input R, input S, output reg Q, output reg Not_Q);
    
    always @(R or S) 
    begin
        begin
            case ({S, R})
                2'b00 : Q = Q; // Retain Value
                2'b01 : Q = 1'b0; // Reset to 0
                2'b10 : Q = 1'b1; // Set to 1
                2'b11 : Q = 1'bZ; // High Impedance
            endcase
        end
        Not_Q = ~Q; 
    end

endmodule