
// higher port have higher priority
// one arbitration cycle for each burst

module xlib_avalon_bus_r #(parameter NR=4, DW=32, AW=32, BL=4, BI=1, FW=4)(
input   clk,
input   rst_n,

output  [NR-1:0] s_rrdy,
input   [NR-1:0] s_rval,
input   [NR*BL-1:0] s_rlen,
input   [NR*AW-1:0] s_raddr,
output  [NR*DW-1:0] s_rdata,
output  [NR-1:0] s_rdval,

input   m_rrdy,
output  m_rval,
output  [BL-1:0] m_rlen,
output  [AW-1:0] m_raddr,
input   [DW-1:0] m_rdata,
input   m_rdval);

integer i;

wire rff_ne, rff_nf;

reg en; wire ee = en & rff_nf;
reg [$clog2(NR)-1:0] rid;
wire x_rval = |s_rval;

assign s_rrdy = (m_rrdy & ee) ? 1<<rid : 0;
assign m_rval = s_rval[rid] & ee;
assign m_rlen = s_rlen[rid*BL+:BL];
assign m_raddr = s_raddr[rid*AW+:AW];

always @(posedge clk or negedge rst_n) 
if (~rst_n) begin
  en <= 0;
  rid <= 'bx;
end
else begin
  en <= en==0 ? x_rval : ~(m_rval & m_rrdy);
  if (en==0 & x_rval) for (i=0;i<NR;i=i+1) if (s_rval[i]) rid <= i;
end

// =========================================================
// == read data ============================================
wire [$clog2(NR)-1:0] rdid;
wire [BL-1:0] rdlen;
reg  [BL-1:0] rdcnt;
wire rdlast = rdlen==rdcnt;
assign s_rdata = {NR{m_rdata}};
assign s_rdval = m_rdval ? 1<<rdid : 0;

xlib_fifos #(.FW(FW), .DW($clog2(NR)+BL)) u (
.clk    (clk),
.rst_n  (rst_n),
.init   (1'b0),
.init_a ({FW+1{1'bx}}),
.wa     (),
.ra     (),
.we     (m_rval & m_rrdy),
.re     (m_rdval & rdlast),
.d      ({m_rlen, rid}),
.q      ({rdlen, rdid}),
.ne     (rff_ne),
.nf     (rff_nf),
.lv     ());

always @(posedge clk or negedge rst_n)
if (~rst_n) rdcnt <= BI;
else if (m_rdval) rdcnt <= rdlast ? BI : rdcnt+1;

endmodule
