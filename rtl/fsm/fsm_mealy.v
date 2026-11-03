// -----------------------------------------------------------------------------
// fsm_mealy - 4-state Mealy FSM
//
// The output depends on the current state AND the current input, so it can
// change between clock edges when x changes. Positive-edge triggered,
// asynchronous active-low reset to state A.
//
//   state (code)   next state on x=0 / y   next state on x=1 / y
//   A (00)         B / 1                   C / 0
//   B (01)         C / 0                   D / 1
//   C (10)         B / 0                   D / 1
//   D (11)         C / 1                   A / 0
//
// The transitions are identical to fsm_moore. The output is
//   y = ~x in states A and D, y = x in states B and C.
// -----------------------------------------------------------------------------
`ifndef FSM_MEALY_V
`define FSM_MEALY_V

`timescale 1ns / 1ps

module fsm_mealy (
    input  clk,
    input  rst_n,
    input  x,
    output y
);

    localparam [1:0] A = 2'b00,
                     B = 2'b01,
                     C = 2'b10,
                     D = 2'b11;

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= A;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        case (state)
            A:       next_state = x ? C : B;
            B:       next_state = x ? D : C;
            C:       next_state = x ? D : B;
            D:       next_state = x ? A : C;
            default: next_state = A;
        endcase
    end

    // Output logic (state and input)
    assign y = (state == A || state == D) ? ~x : x;

endmodule

`endif
