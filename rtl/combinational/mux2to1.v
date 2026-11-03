// -----------------------------------------------------------------------------
// mux2to1 - 2-to-1 multiplexer (gate level)
//
//   y = sel ? in1 : in0  =  in0.sel' + in1.sel
// -----------------------------------------------------------------------------
`ifndef MUX2TO1_V
`define MUX2TO1_V

`timescale 1ns / 1ps

module mux2to1 (
    input  in0,
    input  in1,
    input  sel,
    output y
);

    wire sel_n, t0, t1;

    not (sel_n, sel);
    and (t0, in0, sel_n);
    and (t1, in1, sel);
    or  (y,  t0, t1);

endmodule

`endif
