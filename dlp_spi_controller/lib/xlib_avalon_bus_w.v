
// higher port have higher priority
// one arbitration cycle for each burst
// if DEC_CNT=0, wlen must keep same value during burst
// TODO: add support for DEC_CNT=1

module xlib_avalon_bus_w #(parameter NW=4, DW=32, AW=32, BL=8, BI=1, DEC_CNT=0)(
input   clk,
input   rst_n,

output  [NW-1:0] s_wrdy,
input   [NW-1:0] s_wval,
input   [NW*BL-1:0] s_wlen,
input   [NW*AW-1:0] s_waddr,
input   [NW*DW-1:0] s_wdata,

input   m_wrdy,
output  m_wval,
output  [BL-1:0] m_wlen,
output  [AW-1:0] m_waddr,
output  [DW-1:0] m_wdata);

integer i;

reg en;
reg [$clog2(NW)-1:0] wid;
reg [BL-1:0] wcnt;
wire wlast = DEC_CNT ? wcnt==BI : wcnt==m_wlen;
wire x_wval = |s_wval;

assign s_wrdy = (en & m_wrdy) ? 1<<wid : 0;
assign m_wval = en & s_wval[wid];
assign m_wlen = s_wlen[wid*BL+:BL];
assign m_waddr = s_waddr[wid*AW+:AW];
assign m_wdata = s_wdata[wid*DW+:DW];

always @(posedge clk or negedge rst_n) 
if (~rst_n) begin
  en <= 0;
  wid <= 'bx;
  wcnt <= 'bx;
end
else begin
  en <= en==0 ? x_wval : ~(m_wval & m_wrdy & wlast);
  if (en==0 & x_wval) for (i=0;i<NW;i=i+1) if (s_wval[i]) wid <= i;
  if (en==0 ? x_wval : m_wval & m_wrdy) wcnt <= en==0 ? (DEC_CNT ? 'bx : BI) : (wlast ? 'bx : DEC_CNT ? wcnt-1 : wcnt+1);
end

endmodule
