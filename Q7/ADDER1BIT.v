`timescale 1ns / 1ps

module FullAdder1Bit (a, b, c, Sum, Carry);

    input a, b, c;
    output Sum, Carry;
    wire andAB, andBC, andAC;

    xor X1(Sum, a, b, c);

    and A5(andAB, a, b);
    and A6(andBC, c, b);
    and A7(andAC, a, c);

    or O2(Carry, andAB, andAC, andBC);
    
endmodule