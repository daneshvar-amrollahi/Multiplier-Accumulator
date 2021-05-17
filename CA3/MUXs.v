
module MUX4to1_1b(
    a, 
    b, 
    c, 
    d, 
    sel, 
    out
);
  
    input a, b, c, d;
    input [1 : 0] sel;

    output out;

    C1 MUX(
        a, 
        b, 
        sel[0], 
        c, 
        d, 
        sel[0], 
        sel[1], 
        sel[1], 
        out
    );
  
endmodule

module MUX2to1_1b(
    a, 
    b, 
    s, 
    out
);
  
    input a, b, s;
    output out;

    MUX4to1_1b MUX(a, b, 1'b0, 1'b0, {1'b0, s}, out);
  
endmodule

module Mux2to1 #(parameter N)(
    a, 
    b, 
    s, 
    out
);
    input	[N - 1 : 0] a, b;
    input 	s; 
    output	[N - 1 : 0] out;

    genvar i;
    generate 
        for (i = 0 ; i < N ; i = i + 1)
        begin
            MUX2to1_1b Mi(
                .a(a[i]), 
                .b(b[i]), 
                .s(s), 
                .out(out[i])
            );
        end
    endgenerate

endmodule



module MUX3to1_1b(
    a, 
    b, 
    c, 
    s, 
    out
);
  
    input a, b, c;
    input [1:0] s;
    output out;

    MUX4to1_1b MUX(
        a, 
        b, 
        c, 
        1'b0, 
        s, 
        out
    );
  
endmodule

  
module MUX3to1_8b(
    a, 
    b, 
    c, 
    s, 
    out
);

    input [7 : 0] a, b, c;
    input [1 : 0] s;

    output [7 : 0] out;

    genvar i;
    generate 
        for(i = 0 ; i < 8 ; i = i + 1)
            MUX3to1_1b Ii(
                a[i], 
                b[i], 
                c[i], 
                s, 
                out[i]
            );
    
    endgenerate

endmodule