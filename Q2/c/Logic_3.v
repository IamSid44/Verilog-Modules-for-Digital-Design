`timescale 1ns / 1ps

module Logic_3(a, b, c, d, e, y);

    input a, b, c, d, e;
    output y;
    wire p, q, r, s, t, u, v, y2; 

    // not N1(p, b);
    // or O1(q, a, p);

    // and A1(r, c, d);
    // or O2(s, e, r);

    // and(t, q, s);
    // not(y, t);

    nand NA1(p, a);
    nand NA2(q, c);
    nand NA3(r, d);
    nand NA4(s, e);
    nand NA5(t, p, b);
    nand NA6(u, q, s);
    nand NA7(v, r, s);
    nand NA8(y, t, u, v);

    // assign y2 = ~((a | ~b) & ((c & d) | e));

endmodule