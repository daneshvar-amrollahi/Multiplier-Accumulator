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
                .out(xor_out[i])
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


module Mult4x4Cmpx_CU(
    clk, 
    rst, 
    start, 
    done4x4, 
    ldx, 
    ldy, 
    ldz, 
    ldw, 
    sel1, 
    sel2,
    sel3, 
    sub, 
    initI,
    initR, 
    ldR, 
    ldI, 
    done, 
    start4x4
);

    input  clk, rst, done4x4, start;
    output ldx, ldy, ldz, ldw, sel1, sel2, sel3, sub, 
            initI ,initR, ldR, ldI, done, start4x4;


    wire [3:0] ps; 
    wire [3:0] ns;
    
    Register #(4) regU(
        .in(ns),
        .out(ps),
        .ld(1'b1),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );
    
// NS
//a -> ps[0], c-> ps[2]

    wire a_not, c_not;
    wire u1, u2, u3, v1, v2;
    
    NOT anot(
        .a(ps[0]),
        .out(a_not)
        );
    NOT cnot(
        .a(ps[3]),
        .out(c_not)
        );
        
    //ns[3]
    
    C1 U1u(
        .A0(ps[1]),
        .A1(1'b0),
        .SA(ps[3]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(a_not),
        .S1(c_not),
        .F(u1)
        );
    C1 U2u(
        .A0(ps[3]),
        .A1(1'b0),
        .SA(ps[2]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[0]),
        .S1(ps[1]),
        .F(u2)
        );

    C1 ns3u(
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b0),
        .B1(1'b1),
        .SB(1'b1),
        .S0(u1),
        .S1(u2),
        .F(ns[3])
        );
        
    //ns2
    
    C2 ns2u(
        .D0(ps[2]),
        .D1(c_not),
        .D2(1'b0),
        .D3(1'b0),
        .A0(ps[0]),
        .A1(1'b0),
        .B0(ps[1]),
        .B1(ps[3]),
        .out(ns[2])
        );
        
    //ns1
    
    C2 ns1u(
        .D0(ps[0]),
        .D1(a_not),
        .D2(1'b0),
        .D3(1'b0),
        .A0(1'b1),
        .A1(ps[3]),
        .B0(ps[1]),
        .B1(1'b0),
        .out(ns[1])
        );
        
    //ns0
    
    C1 v1u(
        .A0(1'b0),
        .A1(done4x4),
        .SA(1'b1),
        .B0(1'b0),
        .B1(1'b1),
        .SB(1'b1),
        .S0(ps[3]),
        .S1(1'b0),
        .F(v1)
        );
        
        
    C1 v2u(
        .A0(1'b0),
        .A1(start),
        .SA(1'b1),
        .B0(1'b0),
        .B1(done4x4),
        .SB(1'b1),
        .S0(ps[3]),
        .S1(1'b0),
        .F(v2)
        );
        
    C2 ns0u(
        .D0(v1),
        .D1(v2),
        .D2(1'b0),
        .D3(1'b0),
        .A0(ps[0]),
        .A1(ps[1]),
        .B0(1'b1),
        .B1(ps[2]),
        .out(ns[0])
        );
        
    
    //output signals
    
    //ldx
    C1 ldxu(
        .A0(ps[0]),
        .A1(1'b0),
        .SA(ps[1]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[3]),
        .S1(ps[2]),
        .F(ldx)
        );
        
    assign ldy   = ldx;
    assign ldw   = ldx;
    assign ldz   = ldx;
    assign initI = ldx;
    assign initR = ldx;
    /////////////////////////////
    
    //sel1
    
    C1 sel1u(
        .A0(ps[2]),
        .A1(c_not),
        .SA(ps[3]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[0]),
        .S1(ps[1]),
        .F(sel1)
        );
        
    //sel2
    
    C1 sel2u(
        .A0(1'b0),
        .A1(1'b1),
        .SA(ps[2]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[0]),
        .S1(ps[3]),
        .F(sel2)
        );
        
    //SEL3
    
    C1 sel3u(
        .A0(ps[2]),
        .A1(c_not),
        .SA(ps[1]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(a_not),
        .S1(ps[3]),
        .F(sel3)
        );
    assign ldR = sel3;
    //done
    
    C1 doneu(
        .A0(c_not),
        .A1(1'b0),
        .SA(ps[3]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[0]),
        .S1(ps[1]),
        .F(done)
        );
        
    //ldI
    
    C1 u3u(
        .A0(1'b0),
        .A1(ps[3]),
        .SA(ps[0]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[2]),
        .S1(ps[1]),
        .F(u3)
        );
        
    C1 ldIu(
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b0),
        .B1(1'b1),
        .SB(1'b1),
        .S0(u3),
        .S1(u1),
        .F(ldI)
        );
        
        
    //start4x4	
    
    C1 start4x4u(
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b0),
        .B1(1'b1),
        .SB(1'b1),
        .S0(ldR),
        .S1(ldI),
        .F(start4x4)
        );
        
    
    //sub
    
    
    C1 subu(
        .A0(1'b0),
        .A1(ps[1]),
        .SA(ps[0]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[3]),
        .S1(ps[1]),
        .F(sub)
        );
endmodule

module Mult4x4Cmpx(
    clk, 
    rst, 
    start, 
    a, 
    b, 
    out, 
    done, 
    outReal, 
    outImag
);

	input clk, rst, start;
	input  [7:0] a, b;
	output [15:0] out;
	output done;
    output [7:0] outReal, outImag;
	
	wire ldx, ldz, ldy, ldw, sel1, sel2, done4x4, 
		 start4x4, sel3, sub, initR, initI, ldR, ldI;

	Mult4x4Cmpx_DP DP(
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

	Mult4x4Cmpx_CU CU(
        clk, 
        rst, 
        start, 
        done4x4, 
        ldx, 
        ldy, 
        ldz, 
        ldw, 
        sel1, 
        sel2,
		sel3, 
        sub, 
        initI,
        initR, 
        ldR, 
        ldI, 
        done, 
        start4x4
    );

    assign outReal = out[15:8];
    assign outImag = out[7:0];
endmodule


module Mult4x4Cmpx_tb();

	reg[7:0] a, b;
	reg clk = 1, rst, start;
	
	wire [15:0] out;
    wire [7:0] outReal, outImag;
	wire done;
	Mult4x4Cmpx MUT(clk, rst, start, a, b, out, done, outReal, outImag);
	
	always begin
        #8; clk = ~clk;
    end
    //(a, b) * (c, d) = (a + bj)(c + dj) += (ac - bd, ad + bc)
        //0 <= a, b, c, d <= 7

        //(2, 3) * (2, 1) = (1, 8)
        //(2, 2) * (1, 2) = (-2, 6)
        //(1, 0) * (1, 3) = (1, 3)
		
    initial begin
        a = {4'd2, 4'd3};
        b = {4'd2, 4'd1};
        rst = 1; #25; rst = 0; start = 1; #18 start = 0;
        #500
		
		a = {4'd2, 4'd2};
		b = {4'd1, 4'd2};
		rst = 1; #25; rst = 0; start = 1; #18 start = 0;
		#500
		
		a = {4'd1, 4'd0};
		b = {4'd1, 4'd3};
		rst = 1; #25; rst = 0; start = 1; #18 start = 0;
		#500
		
        #500;
        $stop;
	end
endmodule