
module xlib_fifos #(parameter 
FW=4, // FW>0
DW=32, 
FAST_FLAG=0,
AW=FW+1, // AW>FW
INIT_MEM=0, 
INIT_MEM_D={DW{1'b0}}
)(
input   clk,
input   rst_n,
input   init,
input   [AW-1:0] init_a,
output  reg [AW-1:0] wa,
output  reg [AW-1:0] ra,
output  [FW:0] lv,
input   we,
input   re,
input   [DW-1:0] d,
output  [DW-1:0] q,
output  ne,
output  nf);

reg [FW:0] lf;
reg [DW-1:0] rf [0:2**FW-1];

always @(posedge clk or negedge rst_n)
if (~rst_n) begin
  wa <= 0;
  ra <= 0;
  lf <= 0;
end
else if (init) begin
  wa <= init_a;
  ra <= init_a;
  lf <= 0;
end
else begin
  if (we) wa <= wa+1;
  if (re) ra <= ra+1;
  lf <= lf + we - re;
end

generate if (INIT_MEM==0) begin
  always  @(posedge clk) 
    if (we) rf [wa[FW-1:0]] <= d;
end else begin
  integer i;
  always  @(posedge clk or negedge rst_n) 
    if (~rst_n) for (i=0; i<2**FW; i=i+1) rf[i] <= INIT_MEM_D;
    else if (we) rf [wa[FW-1:0]] <= d;
end endgenerate

wire [FW:0] s = FAST_FLAG ? lf : wa - ra;
assign lv = s;
assign nf = ~s[FW];//s!=(1<<FW);
assign ne = s!=0;
assign q = rf [ra[FW-1:0]];

endmodule
