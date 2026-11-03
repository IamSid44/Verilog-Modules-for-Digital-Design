// -----------------------------------------------------------------------------
// dff - D flip-flop
//
// Positive-edge triggered, asynchronous active-low reset.
//
//   rst_n = 0          : q = 0 immediately
//   posedge clk        : q <= d
//   q_n is always ~q
// -----------------------------------------------------------------------------
`ifndef DFF_V
`define DFF_V

`timescale 1ns / 1ps

module dff (
    input      clk,
    input      rst_n,
    input      d,
    output reg q,
    output     q_n
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else
            q <= d;
    end

    assign q_n = ~q;

endmodule

`endif
