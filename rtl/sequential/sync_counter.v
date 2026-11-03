// -----------------------------------------------------------------------------
// sync_counter - N-bit synchronous binary up counter (default N = 4)
//
// Every stage is a T flip-flop on the same clock. Stage i toggles when `en` is
// high and all lower bits are 1:   t[i] = en & count[i-1] & ... & count[0]
// (a single wide AND per stage, so the delay does not grow along a chain).
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

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : stage
            if (i == 0) begin : first
                assign t[i] = en;
            end else begin : upper
                assign t[i] = en & (&count[i-1:0]);
            end
            tff t_ff (.clk(clk), .rst_n(rst_n), .t(t[i]), .q(count[i]), .q_n());
        end
    endgenerate

endmodule

`endif
