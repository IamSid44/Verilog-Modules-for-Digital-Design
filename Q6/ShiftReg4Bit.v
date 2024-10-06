`timescale 1ns / 1ps

`include "MUX4x1.v"
`include "DFF.v"

module UniShiftReg4Bit(input [1:0]S, input [3:0]Load, input SRin, input SLin, input Clr, input Clk, output wire [3:0]Out);

/*
    {S1, S0} = 00 = Hold
    {S1, S0} = 01 = Right Shift
    {S1, S0} = 10 = Left Shift
    {S1, S0} = 11 = Parallel Load
    Load = Parallel Load Bits, Load[0] = I0, ...
    Out = Parallel Out, Out[0] = A0, ...
    SRin = Right Shift Input, MSB
    SLin = LEft Shift Input, LSB
    Clr = Reset
*/

    wire [3:0]Not_Out;
    wire [3:0]MUX_To_DFF;

    genvar i;

    generate
        for(i = 3; i >= 0; i = i - 1)
        begin : MUX_Loop
            if(i == 3)
                Mux4x1 mux({Load[i], Out[i - 1], SRin, Out[i]}, S, MUX_To_DFF[i]);    
            else if(i == 0)
                Mux4x1 mux({Load[i], SLin, Out[i + 1], Out[i]}, S, MUX_To_DFF[i]);
            else
                Mux4x1 mux({Load[i], Out[i - 1], Out[i + 1], Out[i]}, S, MUX_To_DFF[i]);
        end
    endgenerate

    generate
        for(i = 3; i >= 0; i = i - 1)
        begin : DFF_Loop
            DFF dff(MUX_To_DFF[i], Clk, Clr, Out[i], Not_Out[i]);
        end
    endgenerate

endmodule