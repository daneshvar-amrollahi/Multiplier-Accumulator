module Mux3to1 #(parameter N = 32)(in1, in2, in3, sel, outMUX);
    input	[N-1:0] in1, in2, in3;
    input 	[1:0]		sel; 
    output	[N-1:0] outMUX;

    assign outMux = (sel == 3'b000) ? in3 :
                    (sel == 3'b001) ? in2 :
                    (sel == 3'b010) ? in1 :
                    {(N){1'b0}};
endmodule
