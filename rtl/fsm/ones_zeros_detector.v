// -----------------------------------------------------------------------------
// ones_zeros_detector - asserts `out` once at least two "1"s and two "0"s have
// been entered
//
// Inputs are entered as pulses on `one` and `zero` (think push buttons):
//   - A pulse may stay high for many clock cycles. Each high period counts as
//     ONE input, so two "1"s in a row need `one` to go low in between.
//   - `one` and `zero` are assumed to be synchronous to `clk`.
//   - If both rise on the same clock edge, both are counted.
//
// The state is the number of 1s seen and the number of 0s seen, each
// saturating at 2 (9 states in total). `out` is high in the state (2, 2) and
// stays high until reset, however many more inputs arrive. It depends only on
// the state, so it is a Moore output.
//
//   reset = 1 : return to the initial state immediately (asynchronous,
//               active high)
// -----------------------------------------------------------------------------
`ifndef ONES_ZEROS_DETECTOR_V
`define ONES_ZEROS_DETECTOR_V

`timescale 1ns / 1ps

module ones_zeros_detector (
    input  clk,
    input  reset,
    input  one,
    input  zero,
    output out
);

    reg       one_q, zero_q;     // inputs one clock ago, for rising-edge detection
    reg [1:0] ones, zeros;       // counts of 1s and 0s, saturating at 2

    wire one_pulse  = one  & ~one_q;
    wire zero_pulse = zero & ~zero_q;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            one_q  <= 1'b0;
            zero_q <= 1'b0;
            ones   <= 2'd0;
            zeros  <= 2'd0;
        end else begin
            one_q  <= one;
            zero_q <= zero;
            if (one_pulse  && ones  != 2'd2) ones  <= ones  + 2'd1;
            if (zero_pulse && zeros != 2'd2) zeros <= zeros + 2'd1;
        end
    end

    assign out = (ones == 2'd2) && (zeros == 2'd2);

endmodule

`endif
