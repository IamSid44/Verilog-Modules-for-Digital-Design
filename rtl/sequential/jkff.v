// -----------------------------------------------------------------------------
// jkff - JK flip-flop
//
// Positive-edge triggered, asynchronous active-low reset.
//
//   rst_n = 0    : q = 0 immediately
//   posedge clk  :  J K | q
//                   0 0 | hold
//                   0 1 | 0 (reset)
//                   1 0 | 1 (set)
//                   1 1 | ~q (toggle)
//   q_n is always ~q
// -----------------------------------------------------------------------------
`ifndef JKFF_V
`define JKFF_V

`timescale 1ns / 1ps

module jkff (
    input      clk,
    input      rst_n,
    input      j,
    input      k,
    output reg q,
    output     q_n
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else begin
            case ({j, k})
                2'b00:   q <= q;
                2'b01:   q <= 1'b0;
                2'b10:   q <= 1'b1;
                2'b11:   q <= ~q;
            endcase
        end
    end

    assign q_n = ~q;

endmodule

`endif
