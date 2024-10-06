`timescale 1ns / 1ps

module Logic_2(a, b, c, d, e, f, y);

    input a, b, c, d, e, f;
    output y;
    wire p, q, r;

    // and A1(p, a, b, c);
    // and A2(q, d, e);
    // or O1(r, p, q);
    // and A3(y, r, f);

    nand NA1(p, a, b, c, f);
    nand NA2(q, d, e, f);
    nand NA3(y, p, q);

    // assign r = ((a & b & c) | (d & e)) & f;

endmodule