module AND(
    a, 
    b, 
    out
);
    input a, b;
    output out;
    C1 C1(
        .A0(1'b0),
        .A1(a),
        .SA(b),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(1'b0),
        .S1(1'b0),
        .F(out)
    );

endmodule

module and_tb();
    reg a, b;
    wire out;
    AND AND(a, b, out);
    initial begin
        {a, b} = {1'b0, 1'b0}; #10;
        {a, b} = {1'b0, 1'b1}; #10;
        {a, b} = {1'b1, 1'b0}; #10;
        {a, b} = {1'b1, 1'b1}; #10;
    end
endmodule