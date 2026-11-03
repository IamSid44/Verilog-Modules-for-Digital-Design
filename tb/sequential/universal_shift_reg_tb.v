// Self-checking testbench for universal_shift_reg (N = 4 and N = 8).
//
// Part 1: a directed sequence with hand-written expected values
//         (load, hold, shift right, shift left, reset-over-load).
// Part 2: 400 cycles of random mode / data checked against a behavioural
//         reference model (`usr_ref`, defined at the bottom of this file).
`include "rtl/sequential/universal_shift_reg.v"

`timescale 1ns / 1ps

module universal_shift_reg_tb;

    reg         clk, rst_n;
    reg  [1:0]  mode;
    reg  [7:0]  load;
    reg         sr_in, sl_in;
    wire [3:0]  q4,  m4;
    wire [7:0]  q8,  m8;
    integer     i, errors, seed;

    universal_shift_reg #(.N(4)) dut4 (
        .clk(clk), .rst_n(rst_n), .mode(mode), .load(load[3:0]),
        .sr_in(sr_in), .sl_in(sl_in), .q(q4));
    universal_shift_reg #(.N(8)) dut8 (
        .clk(clk), .rst_n(rst_n), .mode(mode), .load(load),
        .sr_in(sr_in), .sl_in(sl_in), .q(q8));

    usr_ref #(.N(4)) ref4 (
        .clk(clk), .rst_n(rst_n), .mode(mode), .load(load[3:0]),
        .sr_in(sr_in), .sl_in(sl_in), .q(m4));
    usr_ref #(.N(8)) ref8 (
        .clk(clk), .rst_n(rst_n), .mode(mode), .load(load),
        .sr_in(sr_in), .sl_in(sl_in), .q(m8));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Apply one operation on the next clock and check the 4-bit register.
    task step4;
        input [1:0] m;
        input [3:0] ld;
        input       sr;
        input       sl;
        input [3:0] expected;
        begin
            @(negedge clk);
            mode = m; load = ld; sr_in = sr; sl_in = sl;
            @(posedge clk); #1;
            if (q4 !== expected) begin
                errors = errors + 1;
                $display("  FAIL directed: mode=%b load=%b sr=%b sl=%b q=%b expected=%b",
                         m, ld, sr, sl, q4, expected);
            end
        end
    endtask

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/universal_shift_reg_tb.vcd");
        $dumpvars(0, universal_shift_reg_tb);
    end

    initial begin
        errors = 0;
        seed   = 3;
        rst_n  = 1'b0;
        mode = 2'b11; load = 8'hFF; sr_in = 1'b1; sl_in = 1'b1;

        // Reset wins over a parallel load that is requested at the same time.
        #12;
        if (q4 !== 4'b0000 || q8 !== 8'h00) begin
            errors = errors + 1;
            $display("  FAIL reset: q4=%b q8=%b", q4, q8);
        end
        @(negedge clk);
        rst_n = 1'b1;

        //    mode   load     sr   sl   expected
        step4(2'b11, 4'b1010, 1'b0, 1'b0, 4'b1010);   // parallel load
        step4(2'b00, 4'b0101, 1'b1, 1'b1, 4'b1010);   // hold ignores everything
        step4(2'b01, 4'b0000, 1'b1, 1'b0, 4'b1101);   // right shift, 1 enters MSB
        step4(2'b01, 4'b0000, 1'b1, 1'b0, 4'b1110);
        step4(2'b01, 4'b0000, 1'b1, 1'b0, 4'b1111);
        step4(2'b10, 4'b0000, 1'b0, 1'b0, 4'b1110);   // left shift, 0 enters LSB
        step4(2'b10, 4'b0000, 1'b0, 1'b0, 4'b1100);
        step4(2'b10, 4'b0000, 1'b0, 1'b1, 4'b1001);   // sl_in = 1 enters LSB
        step4(2'b11, 4'b0110, 1'b0, 1'b0, 4'b0110);   // load again

        // Random operations; both widths must match the reference model.
        for (i = 0; i < 400; i = i + 1) begin
            @(negedge clk);
            mode  = $random(seed);
            load  = $random(seed);
            sr_in = $random(seed);
            sl_in = $random(seed);
            if (i == 200) begin                        // async reset mid-cycle
                #1 rst_n = 1'b0;
                #1 if (q4 !== 4'b0 || q8 !== 8'h00) begin
                       errors = errors + 1;
                       $display("  FAIL async reset: q4=%b q8=%b", q4, q8);
                   end
                #1 rst_n = 1'b1;
            end
            @(posedge clk); #1;
            if (q4 !== m4 || q8 !== m8) begin
                errors = errors + 1;
                $display("  FAIL random %0d: mode=%b q4=%b (exp %b) q8=%b (exp %b)",
                         i, mode, q4, m4, q8, m8);
            end
        end

        if (errors == 0) $display("PASS: universal_shift_reg_tb");
        else             $display("FAIL: universal_shift_reg_tb (%0d errors)", errors);
        $finish;
    end

endmodule

// Behavioural reference model of the universal shift register.
module usr_ref #(
    parameter N = 4
) (
    input              clk,
    input              rst_n,
    input      [1:0]   mode,
    input      [N-1:0] load,
    input              sr_in,
    input              sl_in,
    output reg [N-1:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= {N{1'b0}};
        else
            case (mode)
                2'b00:   q <= q;
                2'b01:   q <= {sr_in, q[N-1:1]};
                2'b10:   q <= {q[N-2:0], sl_in};
                default: q <= load;
            endcase
    end
endmodule
