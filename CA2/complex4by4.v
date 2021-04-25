`timescale 1ns/1ns
module complexMult4x4_DP(clk, rst, a, b, ldx, ldz, ldy, ldw, sel1, sel2, 
			 start4x4, sel3, sub, initR, initI, ldR, ldI, out, done4x4);
			
	input [7:0]a, b;
	input clk, rst, ldx, ldz, ldy, ldw, sel1, sel2, 
		  start4x4, sel3, sub, initR, initI, ldR, ldI;
	output [15:0] out;
	output done4x4;
	
	
	wire [3:0] x_out, y_out, z_out, w_out;
	
	register #4 xreg(.inREG(a[7:4]), .outREG(x_out), .ld(ldx), .clk(clk), .rst(rst), .init0(0));
	register #4 yreg(.inREG(a[3:0]), .outREG(y_out), .ld(ldy), .clk(clk), .rst(rst), .init0(0));
	register #4 zreg(.inREG(b[7:4]), .outREG(z_out), .ld(ldz), .clk(clk), .rst(rst), .init0(0));
	register #4 wreg(.inREG(b[3:0]), .outREG(w_out), .ld(ldw), .clk(clk), .rst(rst), .init0(0));
	
	wire [3:0] in1Mult, in2Mult;
	
	Mux2to1 #4 in1MUX(.in1(x_out), .in2(y_out), .sel(sel1), .outMUX(in1Mult));
	Mux2to1 #4 in2MUX(.in1(z_out), .in2(w_out), .sel(sel2), .outMUX(in2Mult));
	
	wire [7:0] outMult;
	
	Mult4x4 mult4x4(.clk(clk), .rst(rst), .start(start4x4), .done(done4x4), .a(in1Mult), .b(in2Mult), .out(outMult));
	
	
	wire [7:0] im_out, re_out, addMux_out, add_out;
	
	Mux2to1 #8 addMUX(.in1(im_out), .in2(re_out), .sel(sel3), .outMUX(addMux_out));
	
	assign add_out = (sub) ? (addMux_out - outMult):(addMux_out + outMult);
	
	register #8 imreg(.inREG(add_out), .outREG(im_out), .ld(ldI), .clk(clk), .rst(rst), .init0(initI));
	register #8 rereg(.inREG(add_out), .outREG(re_out), .ld(ldR), .clk(clk), .rst(rst), .init0(initR));
	
	assign out = {re_out, im_out};
	
endmodule


module complexMult4x4_CU(clk, rst, start, done4x4, ldx, ldy, ldz, ldw, sel1, sel2,
				sel3, sub, initI ,initR, ldR, ldI, done, start4x4);
	
	input  clk, rst, done4x4, start;
	output ldx, ldy, ldz, ldw, sel1, sel2, sel3, sub, 
		   initI ,initR, ldR, ldI, done, start4x4;
 	
	
	reg  [3:0] ps; //ns: D3, D2, D1, D0  ps: V3, V2, V1, V0
    wire [3:0] ns;
    
	assign ns[3] = (~ps[3] & ps[2] & ps[1] & ps[0]) | (ps[3] & ~ps[2] & ~ps[1] & ~ps[0]);
    assign ns[2] = (~ps[3] & ps[2] & ~ps[1]) | (~ps[3] & ps[2] & ~ps[0]) | (~ps[3] & ~ps[2] & ps[1] & ps[0]);
    assign ns[1] = (~ps[3] & ~ps[1] & ps[0]) | (~ps[3] & ps[1] & ~ps[0]);
    assign ns[0] = (~ps[3] & ps[1] & ~ps[0] & done4x4) | (~ps[3] & ps[2] & ~ps[0] & done4x4) | 
				   (ps[3] & ~ps[2] & ~ps[1] & ~ps[0] & done4x4) | (start & ~ps[3] & ~ps[2] & ~ps[1] & ~ps[0]);


    always @(posedge clk, posedge rst)
    begin
        if (rst)
            ps <= 4'b0000;
        else
            ps <= ns;
    end
	
	assign ldx = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
	assign ldy = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
	assign ldz = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
	assign ldw = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
	
	assign sel1 = (~ps[3] & ps[2] & ~ps[1] & ~ps[0]) | (ps[3] & ~ps[2] & ~ps[1] & ~ps[0]);
	assign sel2 = (~ps[3] & ps[2] & ~ps[1] & ~ps[0]) | (~ps[3] & ps[2] & ps[1] & ~ps[0]);
	
	assign sel3 = (~ps[3] & ~ps[2] & ps[1] & ps[0]) | (~ps[3] & ps[2] & ~ps[1] & ps[0]);
	
	assign sub = (~ps[3] & ps[2] & ~ps[1] & ps[0]);
	
	assign ldR = (~ps[3] & ~ps[2] & ps[1] & ps[0]) | (~ps[3] & ps[2] & ~ps[1] & ps[0]); //3, 5
	assign ldI = (~ps[3] & ps[2] & ps[1] & ps[0]) | (ps[3] & ~ps[2] & ~ps[1] & ps[0]); //7, 9
	
	assign initI = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
	assign initR = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
	
	assign done = (~ps[3] & ~ps[2] & ~ps[1] & ~ps[0]);
	
	assign start4x4 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]) | (~ps[3] & ~ps[2] & ps[1] & ps[0]) | 
					  (~ps[3] & ps[2] & ~ps[1] & ps[0]) | (~ps[3] & ps[2] & ps[1] & ps[0]);
	
endmodule

module complexMult4x4(clk, rst, start, a, b, out, done, outReal, outImag);

	input clk, rst, start;
	input  [7:0] a, b;
	output [15:0] out;
	output done;
    output [7:0] outReal, outImag;
	
	wire ldx, ldz, ldy, ldw, sel1, sel2, done4x4, 
		 start4x4, sel3, sub, initR, initI, ldR, ldI;

	complexMult4x4_DP DP(clk, rst, a, b, ldx, ldz, ldy, ldw, sel1, sel2, 
			 start4x4, sel3, sub, initR, initI, ldR, ldI, out, done4x4);
	complexMult4x4_CU CU(clk, rst, start, done4x4, ldx, ldy, ldz, ldw, sel1, sel2,
				sel3, sub, initI ,initR, ldR, ldI, done, start4x4);

    assign outReal = out[15:8];
    assign outImag = out[7:0];
endmodule
	
module complexMult4x4_tb();

	reg[7:0] a, b;
	reg clk = 1, rst, start;
	
	wire [15:0] out;
    wire [7:0] outReal, outImag;
	wire done;
	complexMult4x4 MUT(clk, rst, start, a, b, out, done, outReal, outImag);
	
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

