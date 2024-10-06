`timescale 1ns / 1ps

`include "ShiftRegNBit.v"
`include "ADDER1BIT.v"

module SerialAdder3Bit(input Clr, input Clk, input SRInB, input [1:0]S, output wire [2:0]OA);

    wire OutD, InD, SRInA, SLInA, SLInB, ClkD, Not_D;
    wire [2:0]OB;

    assign SLInA = 0;
    assign SLInB = 0;

    assign ClkD = Clk & (~S[1]) & S[0];

    FullAdder1Bit Adder(OA[0], OB[0], OutD, SRInA, InD);
    UniShiftRegNBit #(.N(3)) RegA (.S(S), .Load(OA), .SRin(SRInA), .SLin(SLInA), .Clk(Clk), .Clr(Clr), .Out(OA));
    UniShiftRegNBit #(.N(3)) RegB (.S(S), .Load(OB), .SRin(SRInB), .SLin(SLInB), .Clk(Clk), .Clr(Clr), .Out(OB));
    DFF Dff(InD, ClkD, Clr, OutD, Not_D);

endmodule