// Self-checking testbench for fsm_moore and fsm_mealy.
//
// Part 1: a directed 8-step input sequence with hand-derived expected values
//         (state path A B D A B C D A -> C), including the Mealy case
//         "state A, x = 1" that gives y = 0.
// Part 2: the combinational difference between the two machines: within one
//         clock cycle the Mealy output follows x, the Moore output does not.
// Part 3: 300 random cycles (with asynchronous resets) against a table-driven
//         model; all 8 (state, x) pairs must be visited.
`include "rtl/fsm/fsm_mealy.v"
`include "rtl/fsm/fsm_moore.v"

`timescale 1ns / 1ps

module fsm_tb;

    reg  clk, rst_n, x;
    wire y_moore, y_mealy;
    integer i, errors, seed;

    fsm_moore moore (.clk(clk), .rst_n(rst_n), .x(x), .y(y_moore));
    fsm_mealy mealy (.clk(clk), .rst_n(rst_n), .x(x), .y(y_mealy));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---- Tables (state codes A=0, B=1, C=2, D=3), indexed by {state, x} -----
    //   next state, 2 bits per entry:  A0:B A1:C  B0:C B1:D  C0:B C1:D  D0:C D1:A
    localparam [15:0] NEXT  = {2'd0, 2'd2, 2'd3, 2'd1, 2'd3, 2'd2, 2'd2, 2'd1};
    //   Mealy output, bit i = entry {state, x} = i
    localparam [7:0]  MEALY = 8'b0110_1001;      // A0:1 A1:0 B0:0 B1:1 C0:0 C1:1 D0:1 D1:0
    //   Moore output, bit i = state i
    localparam [3:0]  MOORE = 4'b0110;           // A:0 B:1 C:1 D:0

    // Directed sequence. Bit 0 of each vector is step 1 (written MSB-first).
    localparam [7:0] SEQ_X     = 8'b1110_0110;   // x per step:        0 1 1 0 0 1 1 1
    localparam [7:0] SEQ_MEALY = 8'b0010_1011;   // y_mealy before edge: 1 1 0 1 0 1 0 0
    localparam [7:0] SEQ_MOORE = 8'b1001_1001;   // y_moore after edge:  1 0 0 1 1 0 0 1

    // Reference model for part 3
    reg [1:0] m_state;
    reg [7:0] seen;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) m_state <= 2'd0;
        else        m_state <= NEXT[2*{m_state, x} +: 2];
    end

    initial if ($test$plusargs("vcd")) begin
        $dumpfile("build/waves/fsm_tb.vcd");
        $dumpvars(0, fsm_tb);
    end

    initial begin
        errors = 0;
        seed   = 11;
        rst_n  = 1'b0;
        x      = 1'b0;
        #12;
        if (y_moore !== 1'b0) begin
            errors = errors + 1;
            $display("  FAIL moore after reset: y=%b", y_moore);
        end
        @(negedge clk);
        rst_n = 1'b1;

        // ---- Part 1: directed sequence --------------------------------------
        // Starts on the same falling edge that released reset, so the first
        // rising edge is step 1 (otherwise the machine would already have left A).
        for (i = 0; i < 8; i = i + 1) begin
            x = SEQ_X[i];
            #1;                                          // Mealy output is combinational
            if (y_mealy !== SEQ_MEALY[i]) begin
                errors = errors + 1;
                $display("  FAIL mealy step %0d: x=%b y=%b expected %b", i + 1, x, y_mealy, SEQ_MEALY[i]);
            end
            @(posedge clk); #1;
            if (y_moore !== SEQ_MOORE[i]) begin
                errors = errors + 1;
                $display("  FAIL moore step %0d: y=%b expected %b", i + 1, y_moore, SEQ_MOORE[i]);
            end
            @(negedge clk);
        end

        // ---- Part 2: input-dependence -------------------------------------
        // The machines are now in state C. Mealy: y = x. Moore: y = 1 always.
        x = 1'b0; #1;
        if (y_mealy !== 1'b0 || y_moore !== 1'b1) begin
            errors = errors + 1;
            $display("  FAIL state C, x=0: mealy=%b moore=%b (expected 0, 1)", y_mealy, y_moore);
        end
        x = 1'b1; #1;
        if (y_mealy !== 1'b1 || y_moore !== 1'b1) begin
            errors = errors + 1;
            $display("  FAIL state C, x=1: mealy=%b moore=%b (expected 1, 1)", y_mealy, y_moore);
        end

        // ---- Part 3: random inputs against the table model ------------------
        seen = 8'd0;
        for (i = 0; i < 300; i = i + 1) begin
            @(negedge clk);
            x = $random(seed);
            if (i % 97 == 50) begin                      // asynchronous reset
                #1 rst_n = 1'b0;
                #1 rst_n = 1'b1;
            end
            #1;
            seen[{m_state, x}] = 1'b1;
            if (y_mealy !== MEALY[{m_state, x}]) begin
                errors = errors + 1;
                $display("  FAIL random %0d mealy: state=%0d x=%b y=%b expected %b",
                         i, m_state, x, y_mealy, MEALY[{m_state, x}]);
            end
            if (y_moore !== MOORE[m_state]) begin
                errors = errors + 1;
                $display("  FAIL random %0d moore: state=%0d y=%b expected %b",
                         i, m_state, y_moore, MOORE[m_state]);
            end
            @(posedge clk); #1;
            if (y_moore !== MOORE[m_state]) begin
                errors = errors + 1;
                $display("  FAIL random %0d moore after edge: state=%0d y=%b expected %b",
                         i, m_state, y_moore, MOORE[m_state]);
            end
        end
        if (seen !== 8'hFF) begin
            errors = errors + 1;
            $display("  FAIL coverage: only visited (state,x) pairs %b", seen);
        end

        if (errors == 0) $display("PASS: fsm_tb");
        else             $display("FAIL: fsm_tb (%0d errors)", errors);
        $finish;
    end

endmodule
