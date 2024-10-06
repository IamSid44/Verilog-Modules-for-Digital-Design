`timescale 1ns / 1ps

module Decoder1x2 (en, in, out);

    input en;
    input in;
    output [1:0]out;
    wire in_not;

    not N1(in_not, in);
    and A1(out[0], en, in_not);
    and A2(out[1], en, in);
    
endmodule