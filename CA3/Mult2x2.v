module Mult2x2(
    a,
    b,
    out
);

    input [1:0] a, b;
    output [3:0] out;

    AND AND(
        .a(a[0]), 
        .b(b[0]), 
        .out(out[0]) 
    );

    wire a1_not;
    NOT NOT_a1(a[1], a1_not);

    wire b0_not;
    NOT NOT_b0(b[0], b0_not);

    C2 C2_out1(
        .D0(1'b1),
        .D1(1'b0),
        .D2(1'b0),
        .D3(a[0]),
        .A1(a1_not),
        .B1(b0_not),
        .A0(b[1]),
        .B0(a[0]),
        .out(out[1])
    );

    wire a0_not;
    NOT NOT_a0(a[0], a0_not);
    C2 C2_out2(
        .D0(1'b0),
        .D1(1'b0),
        .D2(b[1]),
        .D3(a0_not),
        .A1(a[1]),
        .B1(1'b0), //S1 = a[1]
        .A0(1'b1),
        .B0(b[0]), //S0 = b[0]
        .out(out[2])
    );

    wire and_a1_b1;
    AND AND_a1_b1(a[1], b[1], and_a1_b1);
    
    AND AND_out0_a1b1(out[0], and_a1_b1, out[3]);
endmodule

module mult2x2_tb();
    reg [1:0] a, b;
    wire [3:0] out;

    Mult2x2 Mult2x2(a, b, out);
    initial begin
        {a, b} = {2'd0, 2'd0}; #10;
        {a, b} = {2'd0, 2'd1}; #10;
        {a, b} = {2'd0, 2'd2}; #10;
        {a, b} = {2'd0, 2'd3}; #10; 

        {a, b} = {2'd1, 2'd0}; #10;
        {a, b} = {2'd1, 2'd1}; #10;
        {a, b} = {2'd1, 2'd2}; #10;
        {a, b} = {2'd1, 2'd3}; #10; 

        {a, b} = {2'd2, 2'd0}; #10;
        {a, b} = {2'd2, 2'd1}; #10;
        {a, b} = {2'd2, 2'd2}; #10;
        {a, b} = {2'd2, 2'd3}; #10; 

        {a, b} = {2'd3, 2'd0}; #10;
        {a, b} = {2'd3, 2'd1}; #10;
        {a, b} = {2'd3, 2'd2}; #10;
        {a, b} = {2'd3, 2'd3}; #10; 
    end

endmodule
/*
C1 C1(
        .A0(),
        .A1(),
        .SA(),
        .B0(),
        .B1(),
        .SB(),
        .S0(),
        .S1(),
        .F()
    );

C2 C2(
    .D0(),
    .D1(),
    .D2(),
    .D3(),
    .A1(),
    .B1(),
    .A0(),
    .B0(),
    .out()
    );
*/