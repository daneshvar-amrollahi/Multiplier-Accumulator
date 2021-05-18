module MAC_DP(
    clk, 
    rst, 
    x0, 
    x1, 
    x2, 
    x3, 
    y0, 
    y1, 
    y2, 
    y3, 
    ans,
    ld_x0, 
    ld_x1, 
    ld_x2, 
    ld_x3, 
    ld_y0, 
    ld_y1, 
    ld_y2, 
    ld_y3,
    sel_xi, 
    sel_yi, 
    ld_re, 
    ld_imag, 
    init_re, 
    init_imag,
    start3, 
    done3
); 
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


    Register #(.N(8)) reg_x0(
        .in(x0),
        .out(x0_out),
        .ld(ld_x0),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(8)) reg_x1(
        .in(x1),
        .out(x1_out),
        .ld(ld_x1),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(8)) reg_x2(
        .in(x2),
        .out(x2_out),
        .ld(ld_x2),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(8)) reg_x3(
        .in(x3),
        .out(x3_out),
        .ld(ld_x3),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(8)) reg_y0(
        .in(y0),
        .out(y0_out),
        .ld(ld_y0),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(8)) reg_y1(
        .in(y1),
        .out(y1_out),
        .ld(ld_y1),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(8)) reg_y2(
        .in(y2),
        .out(y2_out),
        .ld(ld_y2),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Register #(.N(8)) reg_y3(
        .in(y3),
        .out(y3_out),
        .ld(ld_y3),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    
    wire [7:0] x_mux_out, y_mux_out; 


    Mux4to1 #(.N(8)) x_mux(
        .a(x0_out), 
        .b(x1_out),
        .c(x2_out),
        .d(x3_out), 
        .s(sel_xi), 
        .out(x_mux_out)
    );

    Mux4to1 #(.N(8)) y_mux(
        .a(y0_out), 
        .b(y1_out),
        .c(y2_out),
        .d(y3_out), 
        .s(sel_yi), 
        .out(y_mux_out)
    );


    wire [15:0] cmpxMultOut;
    wire [7:0] cmpxMultReal, cmpxMultImag;

    Mult4x4Cmpx Mult4x4Cmpx(
        .clk(clk), 
        .rst(rst), 
        .start(start3), 
        .a(x_mux_out), 
        .b(y_mux_out), 
        .out(cmpxMultOut), 
        .done(done3), 
        .outReal(cmpxMultReal), 
        .outImag(cmpxMultImag)
    );

    wire [9:0] adder_real_in, adder_imag_in;
    assign adder_real_in = {cmpxMultReal[7], cmpxMultReal[7], cmpxMultReal}; //sign extend
    assign adder_imag_in = {2'b0, cmpxMultImag};

    wire [19:0] adder_in_1, adder_in_2;
    wire [19:0] adder_out;

    assign adder_in_1 = {adder_real_in, adder_imag_in};

    assign adder_out = adder_in_1 + adder_in_2;

    wire co;
    Adder #(.N(20)) Adder(
        .a(adder_in_1), 
        .b(adder_in_2), 
        .ci(1'b0), 
        .s(adder_out), 
        .co(co)
    );

    wire [9:0] ans_real_out, ans_imag_out;


    Register #(.N(10)) ans_real(
        .in(adder_out[19 : 10]),
        .out(ans_real_out),
        .ld(ld_re),
        .clk(clk),
        .init0(init_re),
        .rst(rst) 
    );

    Register #(.N(10)) ans_imag(
        .in(adder_out[9 : 0]),
        .out(ans_imag_out),
        .ld(ld_imag),
        .clk(clk),
        .init0(init_imag),
        .rst(rst) 
    );

    assign adder_in_2 = {ans_real_out, ans_imag_out};

    assign ans = {ans_real_out, ans_imag_out};


endmodule


module MAC_CU(
    clk, 
    rst, 
    start, 
    done3,
    ld_x0, 
    ld_x1, 
    ld_x2, 
    ld_x3, 
    ld_y0, 
    ld_y1, 
    ld_y2, 
    ld_y3,
    sel_xi, 
    sel_yi, 
    ld_re, 
    ld_imag, 
    init_re, 
    init_imag,
    start3, 
    done
);
    input clk, rst, done3, start;
    output ld_x0, ld_x1, ld_x2, ld_x3, ld_y0, ld_y1, ld_y2, ld_y3;
    output [1:0] sel_xi, sel_yi;
    output ld_re, ld_imag, init_re, init_imag, start3;
    output done;

    wire  [3:0] ps; //ns: D3, D2, D1, D0  ps: V3, V2, V1, V0
    wire [3:0] ns;

    Register #(4) regStates(
        .in(ns),
        .out(ps),
        .ld(1'b1),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    
    wire a_not, c_not;
    wire u1, u2, u3, v1;
    
    NOT anot(
        .a(ps[0]),
        .out(a_not)
        );
    NOT cnot(
        .a(ps[2]),
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
        .A0(ps[3]),
        .A1(ps[3]),
        .SA(1'b0),
        .B0(1'b1),
        .B1(1'b1),
        .SB(1'b0),
        .S0(ps[1]),
        .S1(ps[2]),
        .F(v1)
        );
		
    C1 ns0u(
        .A0(start),
        .A1(1'b0),
        .SA(ps[0]),
        .B0(done3),
        .B1(1'b0),
        .SB(ps[0]),
        .S0(v1),
        .S1(1'b0),
        .F(ns[0])
        );
    
    


    
    //ld_x0, ld_x1, ld_x2, ld_x3, ld_y0, ld_y1, ld_y2, ld_y3
    
    //ld_x0
    C1 ldx0u(
        .A0(ps[0]),
        .A1(1'b0),
        .SA(ps[1]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[3]),
        .S1(ps[2]),
        .F(ld_x0)
        );
        
    assign ld_x1 = ld_x0;
    assign ld_x2 = ld_x0;
    assign ld_x3 = ld_x0;
    assign ld_y0 = ld_x0;
    assign ld_y1 = ld_x0;
    assign ld_y2 = ld_x0;
    assign ld_y3 = ld_x0;
    

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
    
    
    C1 start3u(
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(ps[0]),
        .B1(1'b0),
        .SB(ps[3]),
        .S0(1'b1),
        .S1(1'b1),
        .F(start3)
        );

    assign init_re = ld_x0;
    assign init_imag = ld_x0;

    //selx0
    
    C1 selx0(
        .A0(ps[2]),
        .A1(c_not),
        .SA(ps[3]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(ps[0]),
        .S1(ps[1]),
        .F(sel_xi[0])
        );

    wire v2;
    C1 selx1_1(
        .B0(ps[2]),
        .B1(1'b0),
        .SB(ps[3]),
        .A0(ps[3]),
        .A1(1'b0),
        .SA(ps[2]),
        .S0(ps[1]),
        .S1(1'b0),
        .F(v2)
    );

    C1 selx1_2(
        .A0(v2),
        .A1(1'b0),
        .SA(ps[0]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(1'b0),
        .S1(1'b0),
        .F(sel_xi[1])
    );


    assign sel_yi[0] = sel_xi[0];
    assign sel_yi[1] = sel_xi[1];

    wire v3, v4; //v3: 3, 5   v4: 7, 9
    C1 v3u(
        .A0(ps[2]),
        .A1(c_not),
        .SA(ps[1]),
        .B0(1'b0),
        .B1(1'b0),
        .SB(1'b0),
        .S0(a_not),
        .S1(ps[3]),
        .F(v3)
        );

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
        .F(v4)
    );

    C1 OR(
        .A0(1'b0),
        .A1(1'b0),
        .SA(1'b0),
        .B0(1'b0),
        .B1(1'b1),
        .SB(1'b1),
        .S0(v3),
        .S1(v4),
        .F(ld_re)
    );

    assign ld_imag = ld_re;
    
endmodule



module MAC(
    clk, 
    rst, 
    x0, 
    x1, 
    x2, 
    x3, 
    y0, 
    y1, 
    y2, 
    y3, 
    out, 
    out_real, 
    out_imag, 
    done, 
    start
);
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

    MAC_CU CU(
        .clk(clk), 
        .rst(rst), 
        .start(start), 
        .done3(done3),
        .ld_x0(ld_x0), 
        .ld_x1(ld_x1), 
        .ld_x2(ld_x2), 
        .ld_x3(ld_x3), 
        .ld_y0(ld_y0), 
        .ld_y1(ld_y1), 
        .ld_y2(ld_y2), 
        .ld_y3(ld_y3),
        .sel_xi(sel_xi), 
        .sel_yi(sel_yi), 
        .ld_re(ld_re), 
        .ld_imag(ld_imag), 
        .init_re(init_re), 
        .init_imag(init_imag),
        .start3(start3), 
        .done(done)
    );

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
