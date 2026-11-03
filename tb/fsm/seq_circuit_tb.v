// Self-checking testbench for seq_circuit_dff and seq_circuit_tff.
//
// seq_circuit_dff: every (state, x, y) combination is tested against the
//   hand-derived state table (see exp_next below). To test state S, the circuit
//   is reset and driven into S first (which also proves S is reachable).
//
// seq_circuit_tff: after reset the state must follow
//   RESET_STATE = 00 : 00 01 10 00 01 10 ...
//   RESET_STATE = 11 : 11 00 01 10 00 01 ...
`include "rtl/fsm/seq_circuit_dff.v"
`include "rtl/fsm/seq_circuit_tff.v"

`timescale 1ns / 1ps

module seq_circuit_tb;

    reg  clk, rst_n, x, y;
    wire z, a, b;
    wire a0, b0;                          // T-FF circuit, reset state 00
    wire a3, b3;                          // T-FF circuit, reset state 11
    integer s, xy, i, errors;
    reg  [1:0] expected;

    seq_circuit_dff dut_dff (.clk(clk), .rst_n(rst_n), .x(x), .y(y), .z(z), .a(a), .b(b));
    seq_circuit_tff #(.RESET_STATE(2'b00)) dut_t00 (.clk(clk), .rst_n(rst_n), .a(a0), .b(b0));
    seq_circuit_tff #(.RESET_STATE(2'b11)) dut_t11 (.clk(clk), .rst_n(rst_n), .a(a3), .b(b3));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Next state {A+, B+} for {A, B, x, y}, taken from the state table.
    function [1:0] exp_next;
        input [3:0] sxy;
        begin
            case (sxy)
                4'b0000: exp_next = 2'b00;  4'b0001: exp_next = 2'b00;
                4'b0010: exp_next = 2'b11;  4'b0011: exp_next = 2'b01;
                4'b0100: exp_next = 2'b00;  4'b0101: exp_next = 2'b00;
                4'b0110: exp_next = 2'b10;  4'b0111: exp_next = 2'b10;
                4'b1000: exp_next = 2'b00;  4'b1001: exp_next = 2'b00;
                4'b1010: exp_next = 2'b11;  4'b1011: exp_next = 2'b01;
                4'b1100: exp_next = 2'b00;  4'b1101: exp_next = 2'b00;
                4'b1110: exp_next = 2'b11;  4'b1111: exp_next = 2'b11;
            endcase
        end
    endfunction

    // Apply x, y on the falling edge and wait until just after the next rising edge.
    task clock_in;
        input xv, yv;
        begin
            @(negedge clk);
            x = xv; y = yv;
            @(posedge clk); #1;
        end
    endtask

    // Reset the D-FF circuit, then drive it into the requested state.
    task enter_state;
        input [1:0] target;
        begin
            @(negedge clk);
            rst_n = 1'b0; x = 1'b0; y = 1'b0;
            #2 rst_n = 1'b1;
            case (target)
                2'b00: ;                                  // reset state
                2'b01: clock_in(1, 1);                    // 00 -> 01
                2'b10: begin clock_in(1, 1); clock_in(1, 1); end   // 00 -> 01 -> 10
                2'b11: clock_in(1, 0);                    // 00 -> 11
            endcase
            if ({a, b} !== target || z !== target[1]) begin
                errors = errors + 1;
                $display("  FAIL could not enter state %b: AB=%b%b z=%b", target, a, b, z);
            end
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/seq_circuit_tb.vcd");
        $dumpvars(0, seq_circuit_tb);
    end

    initial begin
        errors = 0;
        rst_n = 1'b0; x = 1'b0; y = 1'b0;
        #12;

        // ---- T flip-flop circuit: sequence after reset -----------------------
        if ({a0, b0} !== 2'b00 || {a3, b3} !== 2'b11) begin
            errors = errors + 1;
            $display("  FAIL tff reset states: %b%b and %b%b", a0, b0, a3, b3);
        end
        @(negedge clk);
        rst_n = 1'b1;
        for (i = 1; i <= 9; i = i + 1) begin
            @(posedge clk); #1;
            // 00 cycle: 01 10 00 01 10 00 ...   11 start: 00 01 10 00 01 10 ...
            case (i % 3)
                1: expected = 2'b01;
                2: expected = 2'b10;
                0: expected = 2'b00;
            endcase
            if ({a0, b0} !== expected) begin
                errors = errors + 1;
                $display("  FAIL tff(00) clock %0d: AB=%b%b expected %b", i, a0, b0, expected);
            end
            case (i % 3)
                1: expected = 2'b00;
                2: expected = 2'b01;
                0: expected = 2'b10;
            endcase
            if ({a3, b3} !== expected) begin
                errors = errors + 1;
                $display("  FAIL tff(11) clock %0d: AB=%b%b expected %b", i, a3, b3, expected);
            end
        end

        // ---- D flip-flop circuit: full state table ---------------------------
        for (s = 0; s < 4; s = s + 1) begin
            for (xy = 0; xy < 4; xy = xy + 1) begin
                enter_state(s);
                clock_in(xy[1], xy[0]);
                if ({a, b} !== exp_next({s[1:0], xy[1:0]}) || z !== a) begin
                    errors = errors + 1;
                    $display("  FAIL state %b x=%b y=%b: next AB=%b%b expected %b",
                             s[1:0], xy[1], xy[0], a, b, exp_next({s[1:0], xy[1:0]}));
                end
            end
        end

        if (errors == 0) $display("PASS: seq_circuit_tb");
        else             $display("FAIL: seq_circuit_tb (%0d errors)", errors);
        $finish;
    end

endmodule
