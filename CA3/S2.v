module S2(
    D0,
    D1,
    D2,
    D3,
    A1,
    B1,
    A0,
    B0,
    CLR,
    CLK,
    S2_out
);
    input D0, D1, D2, D3, A1, B1, A0, B0, CLR, CLK;
    output S2_out;

    wire S1;
    assign S1 = A1 | B1;
    wire S0;
    assign S0 = A0 & B0;

    wire [1 : 0] sel;
    assign sel = {S1, S0};
    wire mux_out;
    assign mux_out =    sel == 2'b00 ? D0:
                        sel == 2'b01 ? D1:
                        sel == 2'b10 ? D2:
                        D3;

    DFF DFF(
        .d(mux_out), 
        .clk(CLK), 
        .clr(CLR), 
        .out(S2_out)
    );
 
endmodule


module s2_tb();
    reg CLK = 1'b0, CLR, D0, D1, D2, D3, A1, B1, A0, B0;
    wire S2_out;

    S2 S2(
        D0,
        D1,
        D2,
        D3,
        A1,
        B1,
        A0,
        B0,
        CLR,
        CLK,
        S2_out
    );

    initial
        repeat (50)
            #5 CLK = ~CLK;

    initial begin
        CLR = 1'b1;
        D3 = 1'b1; A1 =1'b1; B1 = 1'b1; A0 = 1'b1; B0 = 1'b1;  
        #20;
        CLR = 1'b0;
        #60;
    end
endmodule