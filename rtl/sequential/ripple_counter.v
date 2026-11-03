// -----------------------------------------------------------------------------
// ripple_counter - N-bit asynchronous (ripple) binary up counter (default N=4)
//
// A chain of T flip-flops. Stage 0 is clocked by `clk` and toggles when `en`
// is high; every later stage has t = 1 and is clocked by the falling edge of the
// stage before it (~count[i-1]), so the clock "ripples" through the chain.
//
//   rst_n = 0        : count = 0 immediately (asynchronous)
//   en = 1, clk edge : count increments, wrapping from 2^N-1 to 0
//   en = 0           : count holds (stage 0 stays put, so nothing ripples)
//
// The stages do not switch at the same instant, so `count` is only valid once
// the ripple has settled (visible with non-zero gate delays).
// -----------------------------------------------------------------------------
`ifndef RIPPLE_COUNTER_V
`define RIPPLE_COUNTER_V

`include "rtl/sequential/tff.v"

`timescale 1ns / 1ps

module ripple_counter #(
    parameter N = 4
) (
    input          clk,
    input          rst_n,
    input          en,
    output [N-1:0] count
);

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : stage
            if (i == 0) begin : first
                tff t_ff (.clk(clk), .rst_n(rst_n), .t(en), .q(count[i]), .q_n());
            end else begin : next
                tff t_ff (.clk(~count[i-1]), .rst_n(rst_n), .t(1'b1), .q(count[i]), .q_n());
            end
        end
    endgenerate

endmodule

`endif
