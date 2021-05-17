module XOR(
    a,
    b,
    out
);
    input a, b;
    output out;
    wire cbar;
    //a xor b = a xor b xor 0 = a xor b xor c where c = 0
    C2 XORC2(
        1'b0, 
        1'b0, 
        1'b1, 
        1'b0, 
        a, 
        a, 
        b, 
        b, 
        out
    );
endmodule

module XOR_TB();
    reg a, b;
    wire out;
    XOR MUT(a, b, out);
    initial begin
        {a, b} = {2'b00}; #10;
        {a, b} = {2'b01}; #10;
        {a, b} = {2'b10}; #10;
        {a, b} = {2'b11}; #10;
    end
endmodule