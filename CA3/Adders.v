module FA(
    a, 
    b, 
    ci, 
    s, 
    co
);
    input a, b, ci;
    output s, co;

    wire ci_not;
    NOT NOT(ci, ci_not);
    
    C2 SUM(
        ci, 
        ci, 
        ci_not, 
        ci, 
        a, 
        a, 
        b, 
        b, 
        s
    );

    C1 CARRY_OUT(
        1'b0, 
        b, 
        a, 
        a, 
        1'b1, 
        b, 
        ci, 
        1'b0, 
        co
    );
   
 endmodule


 module Adder #(parameter N)(
    a, 
    b, 
    ci, 
    s, 
    co
);

    input [N - 1 : 0] a, b;
    input ci;
    output [N - 1 : 0] s;
    output co;

    wire[N : 0] c;

    genvar i;
    generate 
        for(i = 0 ; i < N ; i = i + 1)
            FA FAi(
                a[i], 
                b[i], 
                c[i], 
                s[i], 
                c[i + 1]
            );
    endgenerate

    assign c[0] = ci;
    assign co = c[N];
  
endmodule