// Outpu doesn't depend on input
`timescale 1ns / 1ps

module MooreFSM (input x, input Clk, input Clr, output reg y);

    reg [1:0]CurrState;
    reg [1:0]NextState;

    always @(posedge Clk or negedge Clr)
    begin
        if(!Clr)
        begin
            CurrState = 2'b00;
            NextState = ((x > 0) ? 2'b10 : 2'b01);
            y = 1'b0;
        end
        else
        begin
            CurrState = NextState;
            y = CurrState[0] ^ CurrState[1];
        end
    end

    always @(*)
    begin
        case(CurrState)
            2'b00 : NextState <= ((x > 0) ? 2'b10 : 2'b01);
            2'b01 : NextState <= ((x > 0) ? 2'b11 : 2'b10);
            2'b10 : NextState <= ((x > 0) ? 2'b11 : 2'b01);
            2'b11 : NextState <= ((x > 0) ? 2'b00 : 2'b10);
            default : NextState <= 2'b00;
        endcase
    end

endmodule