`define X 1'b0 //dont care


module Reg1b(
    clk,
    rst,
    in,
    init0,
    ld,
    out
);
    input clk, rst, in, init0, ld;
    output out;

    S2 S2(
        .D0(out),
        .D1(in),
        .D2(`X), 
        .D3(`X),
        .A1(init0),
        .B1(init0),
        .A0(ld),
        .B0(ld),
        .CLR(rst),
        .CLK(clk),
        .S2_out(out)
    );


endmodule

module reg1b_tb();
    reg clk = 1'b0, ld = 1'b0, in, init0 = 1'b0, rst;
    wire out;

    Reg1b Reg1b(
        .clk(clk),
        .rst(rst), 
        .ld(ld), 
        .in(in), 
        .out(out), 
        .init0(init0)
    );

    initial
        repeat(100) begin
            clk = ~clk; #5;
        end

    initial begin
        #5;
        rst = 1'b1; #30;
        rst = 1'b0; #30;
        in = 1'b1; #30;
        ld = 1'b1; #30;
        ld = 1'b0; in = 1'b0; #30;
        ld = 1'b1; #30;

        init0 = 1'b1; #30;
        init0 = 1'b0; #30;
        in = 1'b1; #30;
        ld = 1'b1; #30;
        ld = 1'b0; in = 1'b0; #30;
        ld = 1'b1; #30;
        
    end

endmodule
