module register #(parameter N = 16)(inREG, outREG, ld, clk, rst, init0);

  input 	 [N-1:0] inREG;
  input 			 clk, rst, ld, init0;
  output reg [N-1:0] outREG;
  
  always @(posedge clk, posedge rst) begin
    if(rst)
        outREG <= 0;
    else if(init0)
        outREG <= 0;
    else if(ld)
      outREG <= inREG;
  end
  
endmodule
