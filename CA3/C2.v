module C2(
    D0,
    D1,
    D2,
    D3,
    A1,
    B1,
    A0,
    B0,
    out
);

    input D0, D1, D2, D3, A1, B1, A0, B0;
    output out;

    wire S1 = A1 | B1;
    wire S0 = A0 & B0;

    wire [1:0] sel = {S1, S0};
    assign out =    sel == 2'b00 ? D0:
                    sel == 2'b01 ? D1:
                    sel == 2'b10 ? D2:
                    D3;
    
endmodule