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


    Regster #(.N(8)) reg_x0(
        .in(x0),
        .out(x0_out),
        .ld(ld_x0),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Regster #(.N(8)) reg_x1(
        .in(x1),
        .out(x1_out),
        .ld(ld_x1),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Regster #(.N(8)) reg_x2(
        .in(x2),
        .out(x2_out),
        .ld(ld_x2),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Regster #(.N(8)) reg_x3(
        .in(x3),
        .out(x3_out),
        .ld(ld_x3),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Regster #(.N(8)) reg_y0(
        .in(y0),
        .out(y0_out),
        .ld(ld_y0),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Regster #(.N(8)) reg_y1(
        .in(y1),
        .out(y1_out),
        .ld(ld_y1),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Regster #(.N(8)) reg_y2(
        .in(y2),
        .out(y2_out),
        .ld(ld_y2),
        .clk(clk),
        .init0(1'b0),
        .rst(rst) 
    );

    Regster #(.N(8)) reg_y3(
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

    MULT4x4Cmpx MULT4x4Cmpx(
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


    Regster #(.N(10)) ans_real(
        .in(adder_out[19 : 10]),
        .out(ans_real_out),
        .ld(ld_re),
        .clk(clk),
        .init0(init_re),
        .rst(rst) 
    );

    Regster #(.N(10)) ans_imag(
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