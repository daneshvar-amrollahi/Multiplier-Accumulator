module Mux4to1 #(parameter N = 32)(in1, in2, in3, in4, sel, outMUX);
    input	[N-1:0] in1, in2, in3, in4;
    input 	[1:0]		sel; 
    output	[N-1:0] outMUX;

    assign outMUX = (sel == 2'b00) ? in1 :
                    (sel == 2'b01) ? in2 :
                    (sel == 2'b10) ? in3 :
                    (sel == 2'b11) ? in4 :
                     {(N){1'b0}};
endmodule
