`timescale 1ns / 1ps

module PriEnc8x3 (in, out, en);

    input [7:0]in; // in[0] = D0, ...
    input en; // Assume en = 0 implies x = y = z = 0
    output [2:0]out; // out[2] = x, ...
    wire Not_2, Not_4, Not_5, Not_6, or_2_3, p, q, r, s, final1, final2, final3;

    not N1(Not_2, in[2]);
    not N2(Not_4, in[4]);
    not N3(Not_5, in[5]);
    not N4(Not_6, in[6]);

    or O1(or_2_3, in[2], in[3]);

    and A1(p, Not_4, Not_5, or_2_3); // p = 4' && 5' && (2 || 3)
    and A2(q, Not_6, in[5]); // q = 6' && 5
    and A3(r, Not_6, Not_4, in[3]); // r = 6' && 4' && 3
    and A4(s, Not_6, Not_4, Not_2, in[1]); // s = 6' && 4' && 2' && 1

    or O2(final1, in[4], in[5], in[6], in[7]); // x
    or O3(final2, in[6], in[7], p); // y
    or O4(final3, in[7], q, r, s); // z

    and A5(out[2], final1, en);
    and A6(out[1], final2, en);
    and A7(out[0], final3, en);
    
endmodule