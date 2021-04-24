module Mux2to1 #(parameter N = 32)(in1, in2, sel, outMUX);
    input	[N-1:0] in1, in2;
    input 			sel; 
    output	[N-1:0] outMUX;

    assign outMUX = (sel) ? in2 : in1;
endmodule
