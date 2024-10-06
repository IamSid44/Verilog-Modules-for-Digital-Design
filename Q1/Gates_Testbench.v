`timescale 1ns / 1ps

module Gates_Testbench;

    reg a;
    reg b;

    wire o;

    Combinational uut(.out(o), .in1(a), .in2(b));

    initial begin
        $dumpfile("Gates.vcd");
        $dumpvars(0, Gates_Testbench);

        a = 1'b0;
        b = 1'b0;
        #100 $finish;
    end

    always #5 a = ~a;
    always #10 b = ~b;

endmodule