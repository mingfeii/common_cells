
module xlib_avalon_ram #(
AW=32,
DW=32,
BL=4,
BI=1, // burst init value, 0: 0-15, 1: 1-16
SZ=2**20, // num of bytes
ARDY_RATE=100 // [1%-100%]
)(
input clk,
input rst_n,
// single valid, multiple data
output rrdy,
input rval,
input [BL-1:0] rlen,
input [AW-1:0] raddr,
output reg [DW-1:0] rdata,
output reg rdval,
// multiple valid, multiple data
output wrdy,
input wval,
input [BL-1:0] wlen,
input [AW-1:0] waddr,
input [DW-1:0] wdata
);

localparam BS=DW/8,AL=$clog2(BS);
localparam MEM_AW=$clog2(SZ);

reg mval;
reg mwr;
reg [BL-1:0] mcnt;
reg [AW-1:0] maddr;
reg [DW-1:0] mdata;

integer mrdy_rand=0; 
always @(posedge clk) if (mval) mrdy_rand <= {$random}%100;
wire mrdy = mrdy_rand<ARDY_RATE;

wire mlast = mcnt==BI;
wire mdone = mwr | mlast; // write or read-last

wire xrdy = ~mval | mrdy & mdone;
wire xval = wval | rval;
wire xwr = wval ? 1 : rval ? 0 : 1'bx;
assign rrdy = xrdy & ~wval;
assign wrdy = xrdy;

always @(posedge clk or negedge rst_n)
if (~rst_n) begin
  mval <= 0;
  mwr <= 0;
  mcnt <= 'bx;
  maddr <= 'bx;
  mdata <= 'bx;
  rdval <= 0;
end
else begin
  if (xrdy) mval <= xval;
  if (xval & xrdy) begin
    mwr <= xwr;
    mcnt <= xwr ? wlen : rlen;
    maddr <= xwr ? waddr : raddr;
    mdata <= xwr ? wdata : 'bx;
  end
  else if (mval & mrdy & ~mdone) begin
    mcnt <= mcnt - 1;
    maddr <= (maddr & (-1<<AL)) + BS;
  end
  rdval <= mval & mrdy & ~mwr;
end

integer i;
reg [7:0] mem [0:SZ-1];
always @(posedge clk) if (mval & mrdy & mwr) for (i=0; i<BS; i++) mem[maddr[MEM_AW-1:AL]*BS+i] <= mdata[8*i+:8];
always @(posedge clk) if (mval & mrdy) for (i=0; i<BS; i++) rdata[8*i+:8] <= mwr ? 8'bx : mem[maddr[MEM_AW-1:AL]*BS+i];

endmodule
