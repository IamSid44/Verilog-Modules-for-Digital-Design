// -----------------------------------------------------------------------------
// universal_shift_reg - N-bit universal shift register (default N = 4)
//
// Built from one mux4to1 and one dff per bit. Positive-edge triggered,
// asynchronous active-low reset.
//
//   mode  operation
//   00    hold
//   01    shift right: q <= {sr_in, q[N-1:1]}   (q[0] is dropped)
//   10    shift left:  q <= {q[N-2:0], sl_in}   (q[N-1] is dropped)
//   11    parallel load: q <= load
//
// q[N-1] is the MSB. N must be at least 2.
// -----------------------------------------------------------------------------
`ifndef UNIVERSAL_SHIFT_REG_V
`define UNIVERSAL_SHIFT_REG_V

`include "rtl/sequential/dff.v"
`include "rtl/combinational/mux4to1.v"

`timescale 1ns / 1ps

module universal_shift_reg #(
    parameter N = 4
) (
    input          clk,
    input          rst_n,
    input  [1:0]   mode,
    input  [N-1:0] load,
    input          sr_in,    // serial input for right shifts (enters at the MSB)
    input          sl_in,    // serial input for left shifts  (enters at the LSB)
    output [N-1:0] q
);

    wire [N-1:0] shift_right = {sr_in, q[N-1:1]};
    wire [N-1:0] shift_left  = {q[N-2:0], sl_in};
    wire [N-1:0] d;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : bit_slice
            // in[0]=hold, in[1]=right, in[2]=left, in[3]=load
            mux4to1 mux (
                .in({load[i], shift_left[i], shift_right[i], q[i]}),
                .sel(mode),
                .y(d[i])
            );
            dff ff (.clk(clk), .rst_n(rst_n), .d(d[i]), .q(q[i]), .q_n());
        end
    endgenerate

endmodule

`endif
