// -----------------------------------------------------------------------------
// serial_adder - N-bit serial adder (default N = 3)
//
// Adds two N-bit numbers one bit per clock using a single full adder.
//
//   reg A  (universal_shift_reg) : holds a, ends up holding the sum
//   reg B  (universal_shift_reg) : holds b, shifted out LSB first
//   carry  (dff)                 : carry between bit positions
//
// Usage:
//   1. Pulse `load` for one clock with a_in / b_in applied.
//      A and B are loaded and the carry is cleared.
//   2. Hold `shift` high for N clocks. Each clock adds one bit pair: the sum
//      bit enters A at the MSB while A and B shift right.
//   3. After N clocks {cout, sum} = a_in + b_in. Drop `shift` to hold the result.
//
// `load` has priority over `shift`. With both low the registers hold.
// -----------------------------------------------------------------------------
`ifndef SERIAL_ADDER_V
`define SERIAL_ADDER_V

`include "rtl/sequential/dff.v"
`include "rtl/arithmetic/full_adder.v"
`include "rtl/sequential/universal_shift_reg.v"

`timescale 1ns / 1ps

module serial_adder #(
    parameter N = 3
) (
    input          clk,
    input          rst_n,
    input          load,
    input          shift,
    input  [N-1:0] a_in,
    input  [N-1:0] b_in,
    output [N-1:0] sum,
    output         cout
);

    wire [N-1:0] b_reg;
    wire         sum_bit, carry_next, carry_q;
    wire         carry_d;
    wire [1:0]   mode = load ? 2'b11 : (shift ? 2'b01 : 2'b00);

    // Carry flip-flop: cleared on load, updated while shifting, otherwise held.
    assign carry_d = load ? 1'b0 : (shift ? carry_next : carry_q);
    assign cout    = carry_q;

    full_adder fa (
        .a(sum[0]), .b(b_reg[0]), .cin(carry_q),
        .sum(sum_bit), .cout(carry_next)
    );

    universal_shift_reg #(.N(N)) reg_a (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .load(a_in), .sr_in(sum_bit), .sl_in(1'b0), .q(sum)
    );

    universal_shift_reg #(.N(N)) reg_b (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .load(b_in), .sr_in(1'b0), .sl_in(1'b0), .q(b_reg)
    );

    dff carry_ff (.clk(clk), .rst_n(rst_n), .d(carry_d), .q(carry_q), .q_n());

endmodule

`endif
