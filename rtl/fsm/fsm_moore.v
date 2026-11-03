// -----------------------------------------------------------------------------
// fsm_moore - 4-state Moore FSM
//
// The output depends only on the current state, so it changes only at clock
// edges. Positive-edge triggered, asynchronous active-low reset to state A.
//
//   state (code)   output y   next state on x=0   next state on x=1
//   A (00)         0          B                    C
//   B (01)         1          C                    D
//   C (10)         1          B                    D
//   D (11)         0          C                    A
//
// Compare with fsm_mealy, which has the same transitions but whose output also
// depends on x.
// -----------------------------------------------------------------------------
`ifndef FSM_MOORE_V
`define FSM_MOORE_V

`timescale 1ns / 1ps

module fsm_moore (
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

    // Output logic (state only)
    assign y = (state == B) || (state == C);

endmodule

`endif
