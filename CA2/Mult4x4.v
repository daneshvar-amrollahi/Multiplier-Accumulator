module DP4x4(clk, rst, a, b, ld_a, ld_b, sel_a, sel_b, sel_p, ld_r, init0, done, out);
    input clk, rst;
    input [3:0] a, b;
    input ld_a, ld_b, sel_a, sel_b;
    input [1:0] sel_p;
    input ld_r, init0;
    output done;
    output [7:0] out;

    wire [3:0] a_out, b_out;
    register #(.N(4)) reg_a(.clk(clk), .rst(rst), .ld(ld_a), .inREG(a), .outREG(a_out), .init0(0));
    register #(.N(4)) reg_b(.clk(clk), .rst(rst), .ld(ld_b), .inREG(b), .outREG(b_out), .init0(0));  
    
    wire [1:0] mux_a_out, mux_b_out;
    Mux2to1 #(2) mux_a(.in1(a[1:0]), .in2(a[3:2]), .sel(sel_a), .outMUX(mux_a_out));
    Mux2to1 #(2) mux_b(.in1(b[1:0]), .in2(b[3:2]), .sel(sel_b), .outMUX(mux_b_out));

    wire [3:0] mult2x2_out;
    Mult2x2 mul2x2(.A(mux_a_out), .B(mux_b_out), .C(mult2x2_out));

    wire [7:0] in1_mux3, in2_mux3, in3_mux3;
    assign in1_mux3 = {4'b0000, mult2x2_out};   
    assign in2_mux3 = {2'b00, mult2x2_out ,2'b00};
    assign in3_mux3 = {mult2x2_out, 4'b00}; 

    wire [7:0] mux_shift_out;
    Mux3to1 #(8) mux_shift(.in1(in1_mux3), .in2(in2_mux3), .in3(in3_mux3), .sel(sel_p), .outMUX(mux_shift_out));

    wire [7:0] adder_out, adder_reg_out;
    assign adder_out = adder_reg_out + mux_shift_out;
    register #(8) reg_add(.clk(clk), .rst(rst), .ld(ld_r), .inREG(adder_out), .outREG(adder_reg_out), .init0(init0));

    assign out = adder_reg_out;

endmodule

module CU4x4(clk, rst, start, init0, ld_a, ld_b, sel_a, sel_b, sel_p, ld_r, done);
    input clk, rst, start;
    output init0, ld_a, ld_b, sel_a, sel_b, ld_r, done;
    output [1:0] sel_p;

    reg[2:0] ps; //ns: D2, D1, D0  ps: V2, V1, V0
    wire [2:0] ns;
    
    assign ns[2] = (~ps[2] & ps[1] & ps[0]) | (~ps[2] & ~ps[1] & ~ps[0]);
    assign ns[1] = (~ps[2] & ~ps[1] & ps[0]) | (~ps[2] & ~ps[1] & ~ps[0]);
    assign ns[0] = (~ps[2] & ~ps[0] & start) | (~ps[2] & ~ps[1] & ~ps[0]) | (ps[2] & ~ps[0] & ~ps[1]);

    always @(posedge clk, posedge rst)
    begin
        if (rst)
            ps <= 3'b000;
        else
            ps <= ns;
    end

    
    assign done = (~ps[2] & ~ps[1] & ~ps[0]);
    assign ld_a = (~ps[2] & ~ps[1] & ps[0]);
    assign ld_b = (~ps[2] & ~ps[1] & ps[0]);
    assign init0 = (~ps[2] & ~ps[1] & ps[0]);
    assign sel_a = (ps[2] & ~ps[1] & ps[0]) | (ps[2] & ps[1] & ~ps[0]);
    assign sel_b = (ps[2] & ~ps[1] & ps[0]) | (~ps[2] & ps[1] & ps[0]);
    assign sel_p[0] = (~ps[2] & ps[1] & ps[0]) | (ps[2] & ~ps[1] & ~ps[0]);
    assign sel_p[1] = (~ps[2] & ps[1] & ~ps[0]);
    assign ld_r = (ps[2] & ~ps[1] & ps[0]);
endmodule

module Mult4x4(clk, rst, start, done, a, b, out);
    input clk, rst, start;
    input [3:0] a, b;
    output done;
    output [7:0] out;

    wire ld_a, ld_b, sel_a, sel_b, ld_r, init0;
    wire [1:0] sel_p;

    DP4x4 data_path(.clk(clk), .rst(rst), .a(a), .b(b), .ld_a(ld_a), .ld_b(ld_b), 
                    .sel_a(sel_a), .sel_b(sel_b), .sel_p(sel_p), .ld_r(ld_r), .init0(init0), .done(done), .out(out));

    CU4x4 controller(clk, rst, start, init0, ld_a, ld_b, sel_a, sel_b, sel_p, ld_r, done);

endmodule

module Mult4x4_TB();
    reg [3:0] a, b;
    reg start, clk, rst;
    wire [7:0] out;
    wire done;

    initial begin
        start = 1;
        repeat(100) begin
            clk = 1; #10; clk = 0; #10;
        end

        //(a, b) * (c, d) = (a + bj)(c + dj) += (ac - bd, ad + bc)
        //0 <= a, b, c, d <= 3

        //(2, 2) * (1, 2) = (-2, 6)
        //(2, 3) * (2, 1) = (1, 8)
        //(1, 0) * (1, 3) = (1, 3)

        a = {2'b10, 2'b10};
        b = {2'b01, 2'b10};
        #50;
        a = {2'd2, 2'd3};
        b = {2'd2, 2'd1};
        #50;
        a = {2'd1, 2'd0};
        b = {2'd1, 2'd3};
        #50;
    end

    
endmodule