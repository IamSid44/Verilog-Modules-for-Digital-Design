// -----------------------------------------------------------------------------
// updown_counter - N-bit synchronous binary up/down counter (default N = 4)
//
//   rst_n = 0    : count = 0 immediately (asynchronous)
//   posedge clk  : up=1            -> count + 1 (wraps 2^N-1 -> 0)
//                  up=0, down=1    -> count - 1 (wraps 0 -> 2^N-1)
//                  up=0, down=0    -> hold
//   `up` has priority when both `up` and `down` are high.
//
// Stage i toggles when every lower bit is 1 (counting up) or every lower bit
// is 0 (counting down).
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

    wire [N-1:0] up_chain;      // all lower bits are 1 (and counting up)
    wire [N-1:0] down_chain;    // all lower bits are 0 (and counting down)
    wire [N-1:0] t;

    assign up_chain[0]   = up;
    assign down_chain[0] = down & ~up;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : stage
            if (i > 0) begin : chain
                assign up_chain[i]   = up_chain[i-1]   &  count[i-1];
                assign down_chain[i] = down_chain[i-1] & ~count[i-1];
            end
            assign t[i] = up_chain[i] | down_chain[i];
            tff t_ff (.clk(clk), .rst_n(rst_n), .t(t[i]), .q(count[i]), .q_n());
        end
    endgenerate

endmodule

`endif
