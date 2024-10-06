`timescale 1ns / 1ps

module Logic_2_Test;

reg a, b, c, d, e, f;
wire y;

Logic_2 uut(.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .y(y));

initial begin
  $dumpfile("Logic_2.vcd");
  $dumpvars(1, uut);

  a = 1'b0;
  b = 1'b0;
  c = 1'b0;
  d = 1'b0;
  e = 1'b0;
  f = 1'b0;

  #320 $finish;
end

always #5 a = ~a;
always #10 b = ~b;
always #20 c = ~c;
always #40 d = ~d;
always #80 e = ~e;
always #160 f = ~f;

endmodule