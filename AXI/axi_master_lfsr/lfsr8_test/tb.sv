`timescale 1ns / 1ns 
module tb();

logic clk;
logic rst_n;


//生成复位
  initial
  begin:GEN_RST
    rst_n = 1'b0;
    repeat(100)@(posedge clk);
    rst_n=1'b1;
  end

//生成时钟
  initial
  begin:GEN_CLK
  clk = 1'b0;
    forever
      #(5) clk=~clk;
  end



parameter N = 128;
parameter SEED = 4'b0001;

logic [N-1:0] q;


lfsr_test #(
    .N(N),
    .SEED(SEED)
)lfsr_u(
    .clk    (clk    ),                        
    .rst_n  (rst_n  ),                        
    .q      (q      )                     

);




endmodule 