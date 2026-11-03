// -----------------------------------------------------------------------------
// updown_counter - N-bit synchronous binary up/down counter (default N = 4)
//
//   rst_n = 0    : count = 0 immediately (asynchronous)
//   posedge clk  : up=1            -> count + 1 (wraps 2^N-1 -> 0)
//                  up=0, down=1    -> count - 1 (wraps 0 -> 2^N-1)
//                  up=0, down=0    -> hold
//   `up` has priority when both `up` and `down` are high.
//
// Stage i toggles when counting up and every lower bit is 1, or when counting
// down and every lower bit is 0:
//   t[i] = go_up & (&count[i-1:0])  |  go_down & ~(|count[i-1:0])
// -----------------------------------------------------------------------------
`ifndef UPDOWN_COUNTER_V
`define UPDOWN_COUNTER_V

`include "rtl/sequential/tff.v"

`timescale 1ns / 1ps

module updown_counter #(
    parameter N = 4
) (
    input          clk,
    input          rst_n,
    input          up,
    input          down,
    output [N-1:0] count
);

    wire         go_up   = up;
    wire         go_down = down & ~up;
    wire [N-1:0] t;                     // toggle enable of each stage

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : stage
            if (i == 0) begin : first
                assign t[i] = go_up | go_down;
            end else begin : upper
                assign t[i] = (go_up   &  (&count[i-1:0]))
                            | (go_down & ~(|count[i-1:0]));
            end
            tff t_ff (.clk(clk), .rst_n(rst_n), .t(t[i]), .q(count[i]), .q_n());
        end
    endgenerate

endmodule

`endif
