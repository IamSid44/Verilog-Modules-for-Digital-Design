// Positive Edge Triggered Active Low Asynchronous Reset FLip FLip
`timescale 1ns / 1ps

module JKFF(input J, input K, input Clk, input Reset, output reg Q, output reg Not_Q);
    
    always @(posedge Clk or negedge Reset) 
    begin
        if(!Reset)
        begin
            Q <= 1'b0;
            Not_Q <= 1'b1;
        end
        else
        begin
            begin
                case ({J, K})
                    2'b00 : Q = Q; // Retain Value
                    2'b01 : Q = 1'b0; // Reset to 0
                    2'b10 : Q = 1'b1; // Set to 1
                    2'b11 : Q = ~Q; // Toggle
                endcase
            end
            Not_Q = ~Q;
        end
    end

endmodule