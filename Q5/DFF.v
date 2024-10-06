// Positive Edge Triggered Active Low Asynchronous Reset FLip FLip
`timescale 1ns / 1ps

module DFF(input D, input Clk, input Reset, output reg Q, output reg Not_Q);
    
    always @(posedge Clk or negedge Reset) 
    begin
        if(!Reset)
        begin
            Q <= 1'b0;
            Not_Q <= 1'b1;
        end
        else
        begin
            Q <= D;
            Not_Q <= ~D;
        end
    end

endmodule