module S1(
    D0,
    D1,
    D2,
    D3,
    A1,
    B1,
    A0,
    CLR,
    CLK,
    out
);
    input D0, D1, D2, D3, A1, B1, A0, CLR, CLK;
    output out;

    wire S1 = A1 | B1;
    wire S0 = A0 & CLR;

    wire sel = {S1, S0};
    wire mux_out =  sel == 2'b00 ? D0:
                    sel == 2'b01 ? D1:
                    sel == 2'b10 ? D2:
                    D3;

    DFF DFF(
        .d(mux_out), 
        .clk(clk), 
        .clr(CLR), 
        .out(out)
    );
 
endmodule