// -----------------------------------------------------------------------------
// sync_counter - N-bit synchronous binary up counter (default N = 4)
//
// Every stage is a T flip-flop on the same clock. Stage i toggles when `en` is
// high and all lower bits are 1:  t[i] = en & count[i-1] & ... & count[0]
//
//   rst_n = 0          : count = 0 immediately (asynchronous)
//   posedge clk, en=1  : count increments, wrapping from 2^N-1 to 0
//   en = 0             : count holds
// -----------------------------------------------------------------------------
`ifndef SYNC_COUNTER_V
`define SYNC_COUNTER_V

`include "rtl/sequential/tff.v"

`timescale 1ns / 1ps

module sync_counter #(
    parameter N = 4
) (
    input          clk,
    input          rst_n,
    input          en,
    output [N-1:0] count
);

    wire [N-1:0] t;     // toggle enable of each stage

    assign t[0] = en;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : stage
            if (i > 0) begin : chain
                assign t[i] = t[i-1] & count[i-1];
            end
            tff t_ff (.clk(clk), .rst_n(rst_n), .t(t[i]), .q(count[i]), .q_n());
        end
    endgenerate

endmodule

`endif
