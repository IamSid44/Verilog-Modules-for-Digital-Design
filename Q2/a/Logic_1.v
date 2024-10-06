`timescale 1ns / 1ps

module Logic_1(a, b, c, d, y);

    input a, b, c, d;
    output y;
    wire p, q;

    // and A1(p, a, b);
    // and A2(q, c, d);
    // or O1(y, p, q);

    nand NA1(p, a, b);
    nand NA2(q, c, d);
    nand NA3(y, p, q);

    // assign y2 = (a & b) | (c & d);

endmodule