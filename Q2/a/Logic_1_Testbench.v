`timescale 1ns / 1ps

module Logic_1_Test;

    reg a, b, c, d;
    wire y;

    Logic_1 uut(.a(a), .b(b), .c(c), .d(d), .y(y));

    initial begin
        $dumpfile("Logic_1.vcd");
        $dumpvars(1, uut);

        a = 1'b0;
        b = 1'b0;
        c = 1'b0;
        d = 1'b0;

        #100 $finish;
    end

    always #5 a = ~a;
    always #10 b = ~b;
    always #20 c = ~c;
    always #40 d = ~d;

endmodule