`timescale 1ns / 1ps

module FSMSequenceDetector (input X, input Clk, input Clr, output reg Y);

    reg [2 : 0] CurrFFs;
    reg [2 : 0] NextFFs;

    always @(posedge Clk or posedge Clr)
    begin
        if(Clr)
        begin
            CurrFFs = 0;
            Y = 0;
        end
        else
        begin
           CurrFFs = NextFFs;
            Y = ((CurrFFs == 3'b111) ? 1 : 0); 
        end
    end

    always @(*)
    begin

        case (CurrFFs)
            3'b000 : NextFFs = (X ? 3'b010 : 3'b001);
            3'b001 : NextFFs = (X ? 3'b011 : 3'b001);
            3'b010 : NextFFs = (X ? 3'b010 : 3'b100);
            3'b011 : NextFFs = (X ? 3'b011 : 3'b101);
            3'b100 : NextFFs = (X ? 3'b110 : 3'b100);
            3'b101 : NextFFs = (X ? 3'b111 : 3'b101);
            3'b110 : NextFFs = (X ? 3'b110 : 3'b111);
            3'b111 : NextFFs = (X ? 3'b111 : 3'b111);
            // default: NextFFs = (X ? 3'b010 : 3'b001);
        endcase

    end
    
endmodule