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

    
);

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
    )

