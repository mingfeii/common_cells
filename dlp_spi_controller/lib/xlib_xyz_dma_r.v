
module xlib_xyz_dma_r #(parameter AW=32, AL=2, BL=3, LW=24, DW=8*(2**AL))(
input clk,
input rst_n,
input bus_rst_n,
input pio_adr_we,
input pio_len_we,
input [31:0] pio_d,
output [31:0] pio_adr,
output [31:0] pio_len,
output dma_done,
output dma_err,
input dma_rdy,
output dma_val,
output dma_eof,
output [DW-1:0] dma_d,
input bus_rrdy,
output bus_rval,
output [BL-0:0] bus_rlen,
output [AW-1:0] bus_raddr,
input [DW-1:0] bus_rdata,
input bus_rdval);

localparam FW=8; // hardware dependent
wire dff_eof;
wire [FW:0] dff_cnt;



xlib_dma_rc_bst #(.AW(AW), .AL(AL), .BL(BL), .LW(LW), .FW(FW)) u_dma (
.clk        (clk),
.rst_n      (rst_n),
.bus_rst_n  (bus_rst_n),
.pio_adr_we (pio_adr_we),
.pio_len_we (pio_len_we),
.pio_d      (pio_d),
.pio_adr    (pio_adr),
.pio_len    (pio_len),
.pio_cst    (),
.dff_cnt    (dff_cnt), // i
.dff_eof    (dff_eof), // o
.dff_ack    (), // o
.done       (dma_done),
.err        (dma_err),
.biu_adr    (bus_raddr),
.biu_len    (bus_rlen),
.biu_req    (bus_rval),
.biu_ack    (bus_rval & bus_rrdy),
.rsp_val    (bus_rdval));

xlib_xyz_fifo #(.DW(DW+1)) u_dff (
.clk        (clk),
.rst_n      (rst_n),
.cnt        (dff_cnt),
.wrdy       (/*NC*/),
.wval       (bus_rdval),
.wd         ({dff_eof, bus_rdata}),
.rrdy       (dma_rdy),
.rval       (dma_val),
.rd         ({dma_eof, dma_d}));


endmodule
