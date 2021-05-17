module Mult4x4Cmpx_DP(
    clk, 
    rst, 
    a, 
    b, 
    ldx, 
    ldz, 
    ldy, 
    ldw, 
    sel1, 
    sel2, 
	start4x4, 
    sel3, 
    sub, 
    initR, 
    initI, 
    ldR, 
    ldI, 
    out, 
    done4x4
);
    input [7:0]a, b;
	input clk, rst, ldx, ldz, ldy, ldw, sel1, sel2, 
          start4x4, sel3, sub, initR, initI, ldR, ldI;
	output [15:0] out;
	output done4x4;


wire [3:0] x_out, y_out, z_out, w_out;
	

    Register #(.N(4)) xreg(
        .in(a[7 : 4]),
        .out(x_out),
        .ld(ldx),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(4)) yreg(
        .in(a[3 : 0]),
        .out(y_out),
        .ld(ldy),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(4)) zreg(
        .in(b[7 : 4]),
        .out(z_out),
        .ld(ldz),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(4)) wreg(
        .in(b[3 : 0]),
        .out(w_out),
        .ld(ldw),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

	
	wire [3:0] in1Mult, in2Mult;
	
    Mux2to1 #(.N(4)) in1MUX(
        .a(x_out),
        .b(y_out),
        .s(sel1),
        .out(in1Mult)
    );

    Mux2to1 #(.N(4)) in2MUX(
        .a(z_out),
        .b(w_out),
        .s(sel2),
        .out(in2Mult)
    );
	
	wire [7:0] outMult;
	
	Mult4x4_Real mult4x4r(
        .clk(clk), 
        .rst(rst), 
        .start(start4x4), 
        .A(in1Mult), 
        .B(in2Mult), 
        .out(outMult), 
        .done(done4x4)
    );

	wire [7:0] im_out, re_out, addMux_out, add_out;
	
    Mux2to1 #(.N(8)) addMux(
        .a(im_out), 
        .b(re_out), 
        .s(sel3), 
        .out(addMux_out)
    );


	wire addeer_cin;
    assign adder_cin = sub;
    wire [7 : 0] xor_out;
    genvar i;
    generate 
        for (i = 0 ; i < 8 ; i = i + 1)
        begin
            XOR XORi(
                .a(outMult[i]),
                .b(adder_cin),
                .c(adder_cin),
                .out(xor_out)
            );
        end
    endgenerate 

    wire co;
    Adder #(.N(8))Adder(
        .a(addMux_out), 
        .b(xor_out), 
        .ci(adder_cin), 
        .s(add_out), 
        .co(co)
    );
	//assign add_out = (sub) ? (addMux_out - outMult):(addMux_out + outMult);
	


    Register #(.N(8)) imreg(
        .in(add_out),
        .out(im_out),
        .ld(ldI),
        .clk(clk),
        .init0(initI),
        .rst(rst) 
    );

    Register #(.N(8)) rereg(
        .in(add_out),
        .out(re_out),
        .ld(ldR),
        .clk(clk),
        .init0(initR),
        .rst(rst) 
    );
	
	assign out = {re_out, im_out};

endmodule