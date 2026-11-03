// Self-checking testbench for serial_adder.
//
//   N = 3 : exhaustive, all 64 operand pairs
//   N = 8 : 100 pseudo-random operand pairs
//
// Each addition is: one `load` clock, N `shift` clocks, then check
// {cout, sum} == a + b. The result must also stay put for two idle clocks.
`include "rtl/sequential/serial_adder.v"

`timescale 1ns / 1ps

module serial_adder_tb;

    wire        done3, done8;
    wire [31:0] errors3, errors8;

    serial_adder_check #(.N(3), .TESTS(64))  check3 (.done(done3), .errors(errors3));
    serial_adder_check #(.N(8), .TESTS(100)) check8 (.done(done8), .errors(errors8));

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/serial_adder_tb.vcd");
        $dumpvars(0, serial_adder_tb);
    end

    initial begin
        wait (done3 && done8);
        if (errors3 + errors8 == 0) $display("PASS: serial_adder_tb");
        else                        $display("FAIL: serial_adder_tb (%0d errors)", errors3 + errors8);
        $finish;
    end

endmodule

// Drives one serial_adder of width N through TESTS additions.
// If TESTS == 4**N the operand pairs are exhaustive, otherwise random.
module serial_adder_check #(
    parameter N     = 3,
    parameter TESTS = 64
) (
    output reg        done,
    output reg [31:0] errors
);

    reg           clk, rst_n, load, shift;
    reg  [N-1:0]  a, b;
    wire [N-1:0]  sum;
    wire          cout;
    reg  [N:0]    expected;
    integer       n, seed;

    serial_adder #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .load(load), .shift(shift),
        .a_in(a), .b_in(b), .sum(sum), .cout(cout)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_result;
        begin
            if ({cout, sum} !== expected) begin
                errors = errors + 1;
                $display("  FAIL serial_adder N=%0d: %0d + %0d = %0d (expected %0d)",
                         N, a, b, {cout, sum}, expected);
            end
        end
    endtask

    initial begin
        errors = 0;
        done   = 0;
        seed   = N;
        rst_n  = 1'b0;
        load   = 1'b0;
        shift  = 1'b0;
        a = 0; b = 0;
        #12 rst_n = 1'b1;

        for (n = 0; n < TESTS; n = n + 1) begin
            if (TESTS == (1 << (2 * N))) {a, b} = n;
            else begin
                a = $random(seed);
                b = $random(seed);
            end
            expected = {1'b0, a} + {1'b0, b};

            @(negedge clk);                 // load a and b, clear the carry
            load = 1'b1; shift = 1'b0;
            @(negedge clk);                 // N shift clocks follow
            load = 1'b0; shift = 1'b1;
            repeat (N) @(negedge clk);
            shift = 1'b0;                   // done: hold the result
            #1 check_result;

            repeat (2) @(negedge clk);      // result must not drift while idle
            check_result;
        end

        done = 1;
    end

endmodule
