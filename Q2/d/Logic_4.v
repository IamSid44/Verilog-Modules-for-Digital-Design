`timescale 1ns / 1ps

module Logic_4(a, b, c, d, y);

    input a, b, c, d;
    output y;
    wire p, q, r, s; 

    // not N1(p, d);
    // not N2(q, b);
    // and A1(r, a, q);
    // or(y, r, p);

    nand NA1(p, a);
    nand NA2(q, p, b);
    nand NA3(y, q, d);

    // nor NO1(p, d);
    // nor NO2(q, b);
    // nor NO3(r, a, p);
    // nor NO4(s, p, q);
    // nor NO5(y, r, s);

endmodule