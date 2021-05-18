module MAC_DP(clk, rst, x0, x1, x2, x3, y0, y1, y2, y3, ans,
              ld_x0, ld_x1, ld_x2, ld_x3, ld_y0, ld_y1, ld_y2, ld_y3,
              sel_xi, sel_yi, ld_re, ld_imag, init_re, init_imag,
              start3, done3); 
    input clk, rst;
    input [7:0] x0, x1, x2, x3, y0, y1, y2, y3;
    output [19:0] ans;
    input ld_x0, ld_x1, ld_x2, ld_x3;
    input ld_y0, ld_y1, ld_y2, ld_y3; 
    input [1:0] sel_xi, sel_yi;
    input ld_re, ld_imag;
    input init_re, init_imag;
    input start3;
    output done3;


    wire [7:0] x0_out, x1_out, x2_out, x3_out;
    wire [7:0] y0_out, y1_out, y2_out, y3_out;

    register #8 reg_x0 (.inREG(x0), .outREG(x0_out), .ld(ld_x0), .clk(clk), .rst(rst), .init0(0));
    register #8 reg_x1 (.inREG(x1), .outREG(x1_out), .ld(ld_x1), .clk(clk), .rst(rst), .init0(0));
    register #8 reg_x2 (.inREG(x2), .outREG(x2_out), .ld(ld_x2), .clk(clk), .rst(rst), .init0(0));
    register #8 reg_x3 (.inREG(x3), .outREG(x3_out), .ld(ld_x3), .clk(clk), .rst(rst), .init0(0));

    register #8 reg_y0 (.inREG(y0), .outREG(y0_out), .ld(ld_y0), .clk(clk), .rst(rst), .init0(0));
    register #8 reg_y1 (.inREG(y1), .outREG(y1_out), .ld(ld_y1), .clk(clk), .rst(rst), .init0(0));
    register #8 reg_y2 (.inREG(y2), .outREG(y2_out), .ld(ld_y2), .clk(clk), .rst(rst), .init0(0));
    register #8 reg_y3 (.inREG(y3), .outREG(y3_out), .ld(ld_y3), .clk(clk), .rst(rst), .init0(0));

    wire [7:0] x_mux_out, y_mux_out;    

    Mux4to1 #8 x_mux(.in1(x0_out), .in2(x1_out), .in3(x2_out), .in4(x3_out), .sel(sel_xi), .outMUX(x_mux_out));
    Mux4to1 #8 y_mux(.in1(y0_out), .in2(y1_out), .in3(y2_out), .in4(y3_out), .sel(sel_yi), .outMUX(y_mux_out));

    wire [15:0] cmpxMultOut;
    wire [7:0] cmpxMultReal, cmpxMultImag;
    complexMult4x4 compMult4x4(.clk(clk), .rst(rst), .start(start3), .a(x_mux_out), .b(y_mux_out), 
                               .out(cmpxMultOut), .done(done3), .outReal(cmpxMultReal), .outImag(cmpxMultImag));
    

    wire [9:0] adder_real_in, adder_imag_in;
    assign adder_real_in = {cmpxMultReal[7], cmpxMultReal[7], cmpxMultReal};
    assign adder_imag_in = {2'b0, cmpxMultImag};

    wire [19:0] adder_in_1, adder_in_2;
    wire [19:0] adder_out;
    
    assign adder_in_1 = {adder_real_in, adder_imag_in};

    assign adder_out = adder_in_1 + adder_in_2;
    
    wire [9:0] ans_real_out, ans_imag_out;

    register #10 ans_real (.inREG(adder_out[19 : 10]), .outREG(ans_real_out), .ld(ld_re), .clk(clk), .rst(rst), .init0(init_re));
    register #10 ans_imag (.inREG(adder_out[9 : 0]), .outREG(ans_imag_out), .ld(ld_imag), .clk(clk), .rst(rst), .init0(init_imag));

    assign adder_in_2 = {ans_real_out, ans_imag_out};

    assign ans = {ans_real_out, ans_imag_out};
endmodule


module MAC_CU(clk, rst, start, done3,
             ld_x0, ld_x1, ld_x2, ld_x3, ld_y0, ld_y1, ld_y2, ld_y3,
             sel_xi, sel_yi, ld_re, ld_imag, init_re, init_imag,
             start3, done
);
    input clk, rst, done3, start;
    output ld_x0, ld_x1, ld_x2, ld_x3, ld_y0, ld_y1, ld_y2, ld_y3;
    output [1:0] sel_xi, sel_yi;
    output ld_re, ld_imag, init_re, init_imag, start3;
    output done;

    reg  [3:0] ps; //ns: D3, D2, D1, D0  ps: V3, V2, V1, V0
    wire [3:0] ns;
    
	assign ns[3] = (~ps[3] & ps[2] & ps[1] & ps[0]) | (ps[3] & ~ps[2] & ~ps[1] & ~ps[0]);
    assign ns[2] = (~ps[3] & ps[2] & ~ps[1]) | (~ps[3] & ps[2] & ~ps[0]) | (~ps[3] & ~ps[2] & ps[1] & ps[0]);
    assign ns[1] = (~ps[3] & ~ps[1] & ps[0]) | (~ps[3] & ps[1] & ~ps[0]);
    assign ns[0] = (~ps[3] & ps[1] & ~ps[0] & done3) | (~ps[3] & ps[2] & ~ps[0] & done3) | 
				   (ps[3] & ~ps[2] & ~ps[1] & ~ps[0] & done3) | (start & ~ps[3] & ~ps[2] & ~ps[1] & ~ps[0]);


    always @(posedge clk, posedge rst)
    begin
        if (rst)
            ps <= 4'b0000;
        else
            ps <= ns;
    end


    assign done = (~ps[3] & ~ps[2] & ~ps[1] & ~ps[0]);

    assign start3 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]) | (~ps[3] & ~ps[2] & ps[1] & ps[0]) | 
					  (~ps[3] & ps[2] & ~ps[1] & ps[0]) | (~ps[3] & ps[2] & ps[1] & ps[0]);

    assign ld_x0 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
    assign ld_x1 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
    assign ld_x2 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
    assign ld_x3 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);

    assign ld_y0 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
    assign ld_y1 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
    assign ld_y2 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
    assign ld_y3 = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);

    assign init_re = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);
    assign init_imag = (~ps[3] & ~ps[2] & ~ps[1] & ps[0]);

    assign sel_xi[0] = (ps[3] & ~ps[2] & ~ps[1] & ~ps[0]) | (~ps[3] & ps[2] & ~ps[1] & ~ps[0]); //8, 4 
    assign sel_xi[1] = (ps[3] & ~ps[2] & ~ps[1] & ~ps[0]) | (~ps[3] & ps[2] & ps[1] & ~ps[0]); //8, 6

    assign sel_yi[0] = (ps[3] & ~ps[2] & ~ps[1] & ~ps[0]) | (~ps[3] & ps[2] & ~ps[1] & ~ps[0]); //8, 4
    assign sel_yi[1] = (ps[3] & ~ps[2] & ~ps[1] & ~ps[0]) | (~ps[3] & ps[2] & ps[1] & ~ps[0]); //8, 6

    assign ld_re = (~ps[3] & ~ps[2] & ps[1] & ps[0]) | (~ps[3] & ps[2] & ~ps[1] & ps[0]) | 
                   (~ps[3] & ps[2] & ps[1] & ps[0]) | (ps[3] & ~ps[2] & ~ps[1] & ps[0]); 

    assign ld_imag = (~ps[3] & ~ps[2] & ps[1] & ps[0]) | (~ps[3] & ps[2] & ~ps[1] & ps[0]) | 
                   (~ps[3] & ps[2] & ps[1] & ps[0]) | (ps[3] & ~ps[2] & ~ps[1] & ps[0]); 

endmodule

module MAC(clk, rst, x0, x1, x2, x3, y0, y1, y2, y3, out, out_real, out_imag, done, start);
    input clk, rst, start;
    input [7:0] x0, x1, x2, x3, y0, y1, y2, y3;
    output [19:0] out;
    output [9:0] out_real, out_imag;
    output done;

    wire start3;
    wire done3;

    wire ld_x0, ld_x1, ld_x2, ld_x3, ld_y0, ld_y1, ld_y2, ld_y3,
         ld_re, ld_imag, init_re, init_imag;

    wire [1:0] sel_xi, sel_yi;

    MAC_CU CU(.clk(clk), .rst(rst), .start(start), .done3(done3),
             .ld_x0(ld_x0), .ld_x1(ld_x1), .ld_x2(ld_x2), .ld_x3(ld_x3), .ld_y0(ld_y0), .ld_y1(ld_y1), .ld_y2(ld_y2), .ld_y3(ld_y3),
             .sel_xi(sel_xi), .sel_yi(sel_yi), .ld_re(ld_re), .ld_imag(ld_imag), .init_re(init_re), .init_imag(init_imag),
             .start3(start3), .done(done));

    MAC_DP DP(clk, rst, x0, x1, x2, x3, y0, y1, y2, y3, out,
              ld_x0, ld_x1, ld_x2, ld_x3, ld_y0, ld_y1, ld_y2, ld_y3,
              sel_xi, sel_yi, ld_re, ld_imag, init_re, init_imag,
              start3, done3); 

    assign out_real = out[19:10];
    assign out_imag = out[9:0];

endmodule

module MAC_TB();
    reg clk = 1'b1, rst, start;
    reg [7:0] x0, x1, x2, x3, y0, y1, y2, y3;
    wire done;
    wire [19:0] out;
    wire [9:0] out_real, out_imag;
    
    MAC mut(clk, rst, x0, x1, x2, x3, y0, y1, y2, y3, out, out_real, out_imag, done, start);

    always begin
        #8; clk = ~clk;
    end
        //(a, b) * (c, d) = (a + bj)(c + dj) += (ac - bd, ad + bc)

        //(2, 3) * (2, 1) = (1, 8)
        //(2, 2) * (1, 2) = (-2, 6)
        //(1, 0) * (1, 3) = (1, 3)
        //(6, 2) * (4, 5) = (14, 38)
        //---------------------------+
        //                  (14, 55)
		
    initial begin
        x0 = {4'd2, 4'd3}; y0 = {4'd2, 4'd1};
        x1 = {4'd2, 4'd2}; y1 = {4'd1, 4'd2};
        x2 = {4'd1, 4'd0}; y2 = {4'd1, 4'd3};
        x3 = {4'd6, 4'd2}; y3 = {4'd4, 4'd5};
        rst = 1; #25; rst = 0; start = 1; #18 start = 0;
        #2500
		
        $stop;
	end
endmodule

