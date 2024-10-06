`timescale 1ns / 1ps

module FullAdder4Bit(In1, In2, Cin, Sum, Carry);

    input [3:0]In1;
    input [3:0]In2;
    input Cin;
    output [3:0]Sum;
    output Carry;
    // wire [3:0]Inter;
    wire [4:0]Inter;

    // FullAdder1Bit Bit0(In1[0], In2[0], 1'b0, Sum[0], Inter[0]); // Assumes no input carry, modifyu
    // FullAdder1Bit Bit1(In1[1], In2[1], Inter[0], Sum[1], Inter[1]);
    // FullAdder1Bit Bit2(In1[2], In2[2], Inter[1], Sum[2], Inter[2]);
    // FullAdder1Bit Bit3(In1[3], In2[3], Inter[2], Sum[3], Carry);

    assign Inter[0] = Cin;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) 
        begin : fa_loop
            FullAdder1Bit fa(In1[i], In2[i], Inter[i], Sum[i], Inter[i+1]);
        end
    endgenerate
    assign Carry = Inter[4];
    
endmodule