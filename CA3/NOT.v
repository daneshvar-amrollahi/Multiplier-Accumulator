module NOT(
    a,
    out
);
    input a;
    output out;
    C1 C1(
        .A0(1'b1),
        .A1(1'b0),
        .SA(a),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(1'b0),
        .S1(1'b0),
        .F(out)
    );
endmodule

module not_tb();
    reg a;
    wire out;

    NOT NOT(a, out);

    initial begin
        a = 1'b0;
        #10;
        a = 1'b1;
        #10;
    end
    
endmodule