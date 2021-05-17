module Mult4x4_DP(
    clk, 
    rst, 
    a, 
    b, 
    ld_a, 
    ld_b, 
    sel_a, 
    sel_b, 
    sel_p, 
    ld_r, 
    init0, 
    out
);
    input clk, rst;
    input [3 : 0] a, b;
    input ld_a, ld_b, sel_a, sel_b;
    input [1 : 0] sel_p;
    input ld_r, init0;
    output [7 : 0] out;

    wire [3:0] a_out, b_out;
    Register #(.N(4)) reg_a(
        .clk(clk), 
        .rst(rst), 
        .ld(ld_a), 
        .in(a), 
        .out(a_out), 
        .init0(1'b0)
    );
    Register #(.N(4)) reg_b(
        .clk(clk), 
        .rst(rst), 
        .ld(ld_b), 
        .in(b), 
        .out(b_out), 
        .init0(1'b0)
    );  
    
    wire [1:0] mux_a_out, mux_b_out;
    Mux2to1 #(.N(2)) mux_a(
        .a(a_out[1:0]), 
        .b(a_out[3:2]), 
        .s(sel_a), 
        .out(mux_a_out)
    );

    Mux2to1 #(.N(2)) mux_b(
        .a(b_out[1:0]), 
        .b(b_out[3:2]), 
        .s(sel_b), 
        .out(mux_b_out)
    );


    wire [3:0] mult2x2_out;
    Mult2x2 Mul2x2(
        .a(mux_a_out), 
        .b(mux_b_out), 
        .out(mult2x2_out)
    );

    wire [7:0] in1_mux3, in2_mux3, in3_mux3;
    assign in1_mux3 = {4'b0000, mult2x2_out};   
    assign in2_mux3 = {2'b00, mult2x2_out ,2'b00};
    assign in3_mux3 = {mult2x2_out, 4'b00}; 


    wire [7:0] mux_shift_out;
    MUX3to1_8b mux_shift(
        .a(in1_mux3), 
        .b(in2_mux3), 
        .c(in3_mux3), 
        .s(sel_p), 
        .out(mux_shift_out)
    );

       
    wire [7:0] adder_out, adder_reg_out;

    wire co;
    Adder #(.N(8)) ADD(
        .a(mux_shift_out), 
        .b(adder_reg_out), 
        .ci({1'b0}), 
        .s(adder_out),
        .co(co) 
    );

    Register #(.N(8)) reg_add(
        .clk(clk), 
        .rst(rst), 
        .ld(ld_r), 
        .in(adder_out), 
        .out(adder_reg_out), 
        .init0(init0)
    );

    assign out = adder_reg_out;

endmodule


module Mult4x4_CU(
    clk, 
    rst, 
    start, 
    init0, 
    ld_a, 
    ld_b, 
    ld_r, 
    sel_p, 
    sel_a, 
    sel_b, 
    done
);
        
    input clk, rst, start;
    output init0, ld_a, ld_b, ld_r, sel_a, sel_b, done;
    output [1:0] sel_p;

    wire [2:0] ps, ns;

    wire Fout;


    Register #(.N(3)) state_reg(
        .clk(clk),
        .rst(rst),
        .ld(1'b1),
        .init0(1'b0),
        .in(ns),
        .out(ps)
    );


    C2 NS0(start, 1'b0, 1'b1, 1'b0, ps[0], ps[1], 1'b1, ps[2], ns[0]);

    C1 NS1(ps[0], 1'b0, ps[2], 1'b1, 1'b0, ps[0], ps[1], 1'b0, ns[1]);

    C1 NS2(1'b0, 1'b1, ps[2], 1'b0, 1'b1, ps[1], ps[0], ps[0], ns[2]);

    C1 F(1'b0, 1'b1, ps[0], 1'b0, 1'b0, 1'b0, ps[2], ps[1], Fout);

    assign init0 = Fout;

    assign ld_a = Fout;

    assign ld_b = Fout;

    C1 LDR(1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, ps[2], ps[1], ld_r);

    C1 SELP0(1'b0, ps[0], ps[1], 1'b1, 1'b0, ps[0], ps[2], ps[2], sel_p[0]);

    C1 SELP1(1'b0, 1'b0, 1'b0, 1'b0, 1'b1, ps[0], ps[2], ps[2], sel_p[1]);

    assign sel_a = ps[2];

    assign sel_b = ps[0];

    C1 DONE(1'b1, 1'b0, ps[0], 1'b0, 1'b0, 1'b0, ps[2], ps[1], done);

endmodule


module Mult4x4_Real(
    clk, 
    rst, 
    start, 
    A, 
    B, 
    out, 
    done
);
    input clk, rst, start; 
    input [3:0] A, B;

    output [7:0] out;
    output done;

    wire [1:0]  sel_p;
    wire init0, ld_a, ld_b, ld_r, sel_a, sel_b;

    Mult4x4_DP DP(
        .clk(clk), 
        .rst(rst), 
        .a(A), 
        .b(B), 
        .ld_a(ld_a), 
        .ld_b(ld_b), 
        .sel_a(sel_a), 
        .sel_b(sel_b), 
        .sel_p(sel_p), 
        .ld_r(ld_r), 
        .init0(init0), 
        .out(out)
    );

    Mult4x4_CU CU(
        .clk(clk), 
        .rst(rst), 
        .start(start), 
        .init0(init0), 
        .ld_a(ld_a), 
        .ld_b(ld_b), 
        .ld_r(ld_r), 
        .sel_p(sel_p), 
        .sel_a(sel_a), 
        .sel_b(sel_b), 
        .done(done)
    );

 endmodule


 module Mult4x4_Real_TB();
    reg clk = 0; 
    reg rst, start;
    reg [3:0] A, B;

    wire [7 : 0] out;
    wire done;

    Mult4x4_Real MUT(
        .clk(clk), 
        .rst(rst), 
        .start(start), 
        .A(A), 
        .B(B), 
        .out(out), 
        .done(done)
    );

    initial begin
        

        rst = 1'b1;
        {A, B} = {4'd14, 4'd11};
        start = 1'b0;
        #12 rst = 1'b0;
        #3 start = 1'b1;
        #7 start = 1'b0;
        #100;

        {A, B} = {4'd6, 4'd12};
        #200;
        #3 start = 1'b1;
        #7 start = 1'b0;
        #100;

        {A, B} ={4'd13, 4'd13};
        #200;
        #1 start=1;
        #7 start=0;
        #150 $stop;
    end

    initial 
        repeat (200)
            #5 clk = ~clk;
    
 endmodule