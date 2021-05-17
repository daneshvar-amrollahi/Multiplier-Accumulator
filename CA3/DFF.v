module DFF(
    d,
    clk,
    clr,
    out
);

    input d, clk, clr;
    output reg out;

    always @(posedge clk)
    begin
        if (clr)
            out <= 1'b0;
        else
            out <= d;
    end

endmodule

module dff_tb();
    reg clk = 1'b0, clr, d;
    wire out;

    initial
        repeat (20)
            #5 clk = ~clk;

    DFF DFF(d, clk, clr, out);
    initial begin
        #15 clr = 1'b1; 
        #15 clr = 1'b0; d = 1'b1;
        #15 d = 1'b0; 
        #15 d = 1'b1;
        #15 d = 1'b0;
    end
        
endmodule