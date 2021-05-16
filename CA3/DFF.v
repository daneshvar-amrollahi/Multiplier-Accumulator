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