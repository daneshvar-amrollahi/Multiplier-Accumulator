module Mult2x2(A, B, C);
    input [1:0] A, B;
    output [3:0] C;

    assign C[0] = (A[0] & B[0]);
    assign C[1] = (~A[1] & A[0] & B[1]) | (A[1] & ~A[0] & B[0]) | (A[0] & B[1] & ~B[0]) | (A[1] & B[0] & ~B[1]);
    assign C[2] = (A[1] & ~A[0] & B[1]) | (A[1] & B[1] & ~B[0]);
    assign C[3] = (A[1] & A[0] & B[1] & B[0]);
endmodule

module Mult2x2_TB();
    reg [1:0] a, b;

    wire [3:0] c;

    Mult2x2 i(a, b, c);

    initial begin
      a = 2'd1; b = 2'd3; #100;
      a = 2'd3; b = 2'd2; #100;
    end
endmodule