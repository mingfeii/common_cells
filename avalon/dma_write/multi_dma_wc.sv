// Compact DMA engine. address and length must align to burst size
module multi_dma_wc #(parameter 
AL=2, // address lsb (DATA_WIDTH=BW*(2**AL))
AW=32, // address msb
BL=4, // burst length width (BURST_LENGTH_IN_WORDS=2**BL); must: BL>0
FW=6, // fifo level width (FIFO_SIZE=2**FW);  must: FW>=BL
CH=3,
CW=$clog2(CH),
ALWAYS_EN=0, // RUN bit always set. if 1, RSP_CNT_W must set 0
RSP_CNT_W=0, // width of response counter, if 0, no response wait
BURST_RSP=0, // 0=per data, 1=per request. used when RSP_CNT_W!=0
BLEN_TYPE=0, // 0=VCI/AVM, 1=AXI
DELAY_CNT=0 // Altera dcfifo's USEDW is delay 1 cycle
//BS=2**AL, // data width in bytes, derived parameter
//DW=BW*BS, // data width in bits, derived parameter
)(
input                   clk,
input                   rst_n, // dma reset
input                   bus_rst_n, // bus reset
input   [CH-1:0]        pio_adr_we,
input                   pio_len_we, // if ALWAYS_EN==1, not used
input   [31:0]          pio_d,
output  [CH-1:0][31:0]  pio_adr,
output  [31:0]          pio_len, // if ALWAYS_EN==1, output fixed 1
output  [31:0]          pio_cst,
input   [CH-1:0][FW:0]  dff_cnt,
output                  dff_ack,
input                   dff_eof,
output                  done,
output  [AW-1:0]        biu_adr,
output  [BL-BLEN_TYPE:0]biu_len,
output                  biu_sob,
output [CW-1:0]         biu_ch,
output                  biu_eob,
output                  biu_val,
input                   biu_rdy,
input                   rsp_val// used only when RSP_CNT_W!=0
); 

reg     [BL-1:0] cnt_reg;
wire    [BL:0] cnt_reg_1 = cnt_reg+1;
wire    biu_req; // burst request
assign  biu_val = biu_req | cnt_reg!=0;
assign  biu_sob = cnt_reg==0;
assign  biu_eob = cnt_reg_1[BL];
wire    biu_ack = biu_val & biu_rdy & biu_eob;
wire    [AW-1:0] biu_adr_bst;
assign  biu_adr = {biu_adr_bst[AW-1:BL+AL], cnt_reg, {AL{1'b0}}};
assign  dff_ack = biu_val & biu_rdy;

always @(posedge clk or negedge bus_rst_n)
if (~bus_rst_n) cnt_reg <= 0; else
if (biu_val & biu_rdy) cnt_reg <= cnt_reg_1;

multi_dma_wc_bst #(
.AL(AL),
.AW(AW),
.BL(BL),
.CH(CH),
.FW(FW),
.ALWAYS_EN(ALWAYS_EN),
.RSP_CNT_W(RSP_CNT_W),
.BURST_RSP(BURST_RSP),
.BLEN_TYPE(BLEN_TYPE),
.DELAY_CNT(DELAY_CNT)
) u0 (
.clk        (clk),
.rst_n      (rst_n),
.bus_rst_n  (bus_rst_n),
.pio_adr_we (pio_adr_we),
.pio_len_we (pio_len_we),
.pio_d      (pio_d),
.pio_adr    (pio_adr),
.pio_len    (pio_len),
.pio_cst    (pio_cst),
.dff_cnt    (dff_cnt),
.dff_ack    (dff_ack),
.dff_eof    (dff_eof),
.biu_ch     (biu_ch),
.done       (done),
.biu_adr    (biu_adr_bst),
.biu_len    (biu_len),
.biu_req    (biu_req),
.biu_ack    (biu_ack),
.rsp_val    (rsp_val));

endmodule
