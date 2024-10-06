// Positive Edge Triggered Active Low Asynchronous Reset FLip FLip
`timescale 1ns / 1ps

module TFF(input T, input Clk, input Reset, output reg Q, output reg Not_Q);
    
    always @(posedge Clk or negedge Reset) 
    begin
        if(!Reset)
        begin
            Q <= 1'b0;
            Not_Q <= 1'b1;
        end
        else
        begin
            if(T)
                Q = ~Q;
            Not_Q = ~Q;
        end
    end

endmodule