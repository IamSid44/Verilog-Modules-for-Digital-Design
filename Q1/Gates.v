`timescale 1ns / 1ps

module Combinational (in1, in2, out);
    
    input in1, in2;
    output out;

    // Change the gate type as required
    xnor O1(out, in1, in2);

endmodule