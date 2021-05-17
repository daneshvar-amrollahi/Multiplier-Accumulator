module Register #(parameter N)(
    in,
    out,
    ld,
    clk,
    init0,
    rst 
);
    input [N - 1 : 0] in;
    input ld, clk, init0, rst;

    output [N - 1 : 0] out;
    
    genvar i;
    generate 
        for (i = 0 ; i < N ; i = i + 1)
        begin
            Reg1b Reg_inst(
                .clk(clk),
                .rst(rst),
                .ld(ld),
                .in(in[i]),
                .out(out[i]),
                .init0(init0)   
            );
        end
    endgenerate
    

endmodule

module register_tb();
    reg [3 : 0] in;
    wire [3 : 0] out;
    reg ld = 1'b0, clk = 1'b0, init0 = 1'b0, rst;

    initial
        repeat(150)
            #5 clk = ~clk;

    Register #(.N(4)) Register (
        .in(in), 
        .out(out), 
        .ld(ld), 
        .clk(clk), 
        .init0(init0),
        .rst(rst)
    );

    initial
    begin
        #5;
        rst = 1'b1; #30;
        rst = 1'b0; #30;
        in = 4'b1010; #30;
        ld = 1'b1; #60;
        ld = 1'b0; in = 4'b1111; #30;
        ld = 1'b1; #30;

        init0 = 1'b1; #30;
        init0 = 1'b0; #30;
        in = 4'b1100; #30;
        ld = 1'b1; #60;
        ld = 1'b0; in = 4'b0101; #30;
        ld = 1'b1; #30;
        
    end
endmodule