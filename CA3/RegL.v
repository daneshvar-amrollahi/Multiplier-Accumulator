`define X 1'b0

module RegL(
    clk,
    ld,
    d,
    q,
    init0
);
    input clk, ld, d, init0;
    output q;

    //ld = 1 --> sel = 3 --> D3 = d
    //ld = 0 --> sel = 0 --> D1 = out
    S2 S2(
        .D0(q),
        .D1(`X),
        .D2(`X), 
        .D3(d),
        .A1(ld),
        .B1(ld),
        .A0(ld),
        .B0(1'b1),
        .CLR(init0),
        .CLK(clk),
        .S2_out(q)
    );

//a xor b = ab' + a'b
//not(ab' + a'b) = not(ab').not(a'b) = (not(a) + not(b')).(not(a') + not(b))
//a xnor b = ab + a'b'

endmodule

module regL_tb();
    reg clk = 1'b0, ld, d, init0;
    wire out;

    RegL RegL(clk, ld, d, out, init0);

    initial
        repeat(100) begin
            clk = ~clk; #5;
        end

    initial begin
        #5;
        init0 = 1'b1; #30;
        init0 = 1'b0; #30;
        d = 1'b1; #30;
        ld = 1'b1; #30;
        ld = 1'b0; d = 1'b0; #30;
        ld = 1'b1; #30;
    end

endmodule
