`timescale 1ns / 1ps

module FullAdder1Bit (a, b, c, Sum, Carry);

    input a, b, c;
    output Sum, Carry;
    // wire not_a, not_b, not_c, part1, part2, part3, part4;
    wire andAB, andBC, andAC;

    // not N1(not_a, a);
    // not N2(not_b, b);
    // not N3(not_c, c);

    // and A1(part1, a, not_b, not_c);
    // and A2(part2, not_a, not_b, c);
    // and A3(part3, a, b, c);
    // and A4(part4, not_a, b, not_c);

    // or O1(Sum, part1, part2, part3, part4);

    xor X1(Sum, a, b, c);

    and A5(andAB, a, b);
    and A6(andBC, c, b);
    and A7(andAC, a, c);

    or O2(Carry, andAB, andAC, andBC);
    
endmodule