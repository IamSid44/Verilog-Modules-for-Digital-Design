// Positive Edge Triggered Active Low Asynchronous Reset FLip FLip
`timescale 1ns / 1ps

module TFF(input T, input Clk, input Reset, output reg Q);
    
    always @(posedge Clk or negedge Reset) 
    begin
        if(!Reset)
            Q <= 1'b0;
        else
        begin
            if(T)
                Q = ~Q;
        end
    end

endmodule