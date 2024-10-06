`timescale 1ns / 1ps

module Logic_5(a, b, c, d, y);

    input a, b, c, d;
    output y;
    wire p, q, r, s, t, u;

    nand NA1(p, c);
    nand NA2(q, a, b, p, d);
    nand NA3(r, d);
    nand NA4(s, c, r);
    nand NA5(t, b);
    nand NA6(u, t, r);
    nand NA7(y, q, s, u);

endmodule