
module xlib_avalon_bus #(parameter NW=4, NR=4, DW=32, AW=32, BL=4, BI=1, R_FW=4)(
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
output  [DW-1:0] m_wdata,

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

xlib_avalon_bus_w #(.NW(NW), .DW(DW), .AW(AW), .BL(BL), .BI(BI)) bus_w (
.clk      (clk),
.rst_n    (rst_n),
.s_wrdy   (s_wrdy),
.s_wval   (s_wval),
.s_wlen   (s_wlen),
.s_waddr  (s_waddr),
.s_wdata  (s_wdata),
.m_wrdy   (m_wrdy),
.m_wval   (m_wval),
.m_wlen   (m_wlen),
.m_waddr  (m_waddr),
.m_wdata  (m_wdata));

xlib_avalon_bus_r #(.NR(NR), .DW(DW), .AW(AW), .BL(BL), .BI(BI), .FW(R_FW)) bus_r (
.clk      (clk),
.rst_n    (rst_n),
.s_rrdy   (s_rrdy),
.s_rval   (s_rval),
.s_rlen   (s_rlen),
.s_raddr  (s_raddr),
.s_rdata  (s_rdata),
.s_rdval  (s_rdval),
.m_rrdy   (m_rrdy),
.m_rval   (m_rval),
.m_rlen   (m_rlen),
.m_raddr  (m_raddr),
.m_rdata  (m_rdata),
.m_rdval  (m_rdval));

endmodule

