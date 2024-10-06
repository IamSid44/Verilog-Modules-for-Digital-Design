`timescale 1ns / 1ps

module Demux1x2 (in, y, en);

    input in, en;
    output [1:0]y;
    wire en_not;

    not N1(en_not, en);
    and A1(y[0], en_not, in);
    and A2(y[1], en, in);
    
endmodule