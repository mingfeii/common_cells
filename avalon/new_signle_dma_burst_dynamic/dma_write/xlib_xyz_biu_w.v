
module xlib_xyz_biu_w #(parameter
DMA=1,
UNALIGN=0,
PW=8,
DW=32,
AW=32,
BL=3,
AL=$clog2(DW/8)
)(
input clk,
input rst_n,
input bus_rst_n,
input [1:0] sel, // x0=STR_PW, 01=STR_DW, 11=DMA
input [AL-1:0] bpp, // byte per primitive: 0=1B, 1=2B, 2=3B, 3=4B ...
input [31:0] pio_d,
input pio_adr_we,
output [31:0] pio_adr,
output dma_done,
output sti_rdy,
input sti_val,
input sti_eof,
input [PW-1:0] sti_d,
input sto_rdy,
output sto_val,
output sto_eof,
output [DW-1:0] sto_d,
input bus_wrdy,
output bus_wval,
output [BL:0] bus_wlen,
output [AW-1:0] bus_waddr,
output [DW-1:0] bus_wdata
);

wire st0_rdy, st0_val, st0_eof; wire [PW-1:0] st0_d;
wire st1_rdy, st1_val, st1_eof; wire [PW-1:0] st1_d;
wire p2w_rdy, p2w_val, p2w_eof; wire [DW-1:0] p2w_d;
wire st2_rdy, st2_val, st2_eof; wire [DW-1:0] st2_d;
wire dma_rdy, dma_val, dma_eof; wire [DW-1:0] dma_d;

//xlib_stream_demux #(.DW(PW+1)) u_demux_sti (.sel(sel[0]),
// .m_rdy(sti_rdy),  .m_val(sti_val),  .m_dat({sti_eof, sti_d}),
//.s0_rdy(st0_rdy), .s0_val(st0_val), .s0_dat({st0_eof, st0_d}),
//.s1_rdy(st1_rdy), .s1_val(st1_val), .s1_dat({st1_eof, st1_d}));
assign sti_rdy = sel[0] ? st1_rdy : st0_rdy;
assign st0_val = sel[0] ? 0 : sti_val;
assign st1_val = sel[0] ? sti_val : 0;
assign st0_eof = sti_eof;
assign st1_eof = sti_eof;
assign st0_d   = sti_d;
assign st1_d   = sti_d;

xlib_stream_p2w #(.UNALIGN(UNALIGN), .PW(PW), .DW(DW)) u_p2w (
.clk(clk), .rst_n(rst_n), .clr_n(1'b1), .bpp(bpp),
.m_rdy(st1_rdy), .m_val(st1_val), .m_eof(st1_eof), .m_dat(st1_d),
.s_rdy(p2w_rdy), .s_val(p2w_val), .s_eof(p2w_eof), .s_dat(p2w_d));

//xlib_stream_demux #(.DW(DW+1)) u_demux_p2w (.sel(sel[1]),
// .m_rdy(p2w_rdy),  .m_val(p2w_val),  .m_dat({p2w_eof, p2w_d}),
//.s0_rdy(st2_rdy), .s0_val(st2_val), .s0_dat({st2_eof, st2_d}),
//.s1_rdy(dma_rdy), .s1_val(dma_val), .s1_dat({dma_eof, dma_d}));
assign p2w_rdy = sel[1] ? dma_rdy : st2_rdy;
assign st2_val = sel[1] ? 0 : p2w_val;
assign dma_val = sel[1] ? p2w_val : 0;
assign st2_eof = p2w_eof;
assign dma_eof = p2w_eof;
assign st2_d   = p2w_d;
assign dma_d   = p2w_d;

//wire [DW-1:0] st0_dx = st0_d;
//xlib_stream_mux #(.DW(DW+1)) u_mux_sto (.sel(sel[0]),
//.m0_rdy(st0_rdy), .m0_val(st0_val), .m0_dat({st0_eof, st0_dx}),
//.m1_rdy(st2_rdy), .m1_val(st2_val), .m1_dat({st2_eof, st2_d}),
// .s_rdy(sto_rdy),  .s_val(sto_val),  .s_dat({sto_eof, sto_d}));
assign st0_rdy = sel[0] ? 0 : sto_rdy;
assign st2_rdy = sel[0] ? sto_rdy : 0;
assign sto_val = sel[0] ? st2_val : st0_val;
assign sto_eof = sel[0] ? st2_eof : st0_eof;
assign sto_d   = sel[0] ? st2_d   : st0_d;

generate if (DMA) begin
xlib_xyz_dma_w #(.AW(AW), .AL(AL), .BL(BL)) u_dma (
.clk        (clk),
.rst_n      (rst_n),
.bus_rst_n  (bus_rst_n),
.pio_adr_we (pio_adr_we),
.pio_d      (pio_d),
.pio_adr    (pio_adr),
.dma_done   (dma_done),
.dma_rdy    (dma_rdy),
.dma_val    (dma_val),
.dma_eof    (dma_eof),
.dma_d      (dma_d),
.bus_wrdy   (bus_wrdy),
.bus_wval   (bus_wval),
.bus_wlen   (bus_wlen),
.bus_waddr  (bus_waddr),
.bus_wdata  (bus_wdata));
end else begin
assign pio_adr = 'bx;
assign dma_done = 1'bx;
assign dma_rdy = 1'bx;
assign bus_wval = 1'b0;
assign bus_wlen = 'bx;
assign bus_waddr = 'bx;
assign bus_wdata = 'bx;
end endgenerate

endmodule
