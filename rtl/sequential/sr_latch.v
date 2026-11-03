// -----------------------------------------------------------------------------
// sr_latch - level-sensitive S-R latch (no clock)
//
//    S R | q
//    0 0 | hold
//    0 1 | 0 (reset)
//    1 0 | 1 (set)
//    1 1 | x (forbidden input, output undefined)
//
// q is unknown (x) until the first set or reset. q_n is always ~q.
// For the clocked version see srff.
// -----------------------------------------------------------------------------
`ifndef SR_LATCH_V
`define SR_LATCH_V

`timescale 1ns / 1ps

module sr_latch (
    input      s,
    input      r,
    output reg q,
    output     q_n
);

    always @(*) begin
        if (s && r)
            q = 1'bx;
        else if (s)
            q = 1'b1;
        else if (r)
            q = 1'b0;
        // s = r = 0: no assignment, so q holds its value (latch)
    end

    assign q_n = ~q;

endmodule

`endif
