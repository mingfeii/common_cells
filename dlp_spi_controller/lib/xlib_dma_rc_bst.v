// Compact DMA engine. address and length must align to burst size
module xlib_dma_rc_bst #(parameter 
AL=2, // address lsb (DATA_WIDTH=BW*(2**AL))
AW=32, // address msb
BL=4, // burst length width (BURST_LENGTH_IN_WORDS=2**BL); must: BL>0
FW=6, // fifo level width (FIFO_SIZE=2**FW);  must: FW>=BL
LW=24, // length msb
BLEN_TYPE=0, // 0=VCI/AVM, 1=AXI
DELAY_CNT=0 // Altera dcfifo's USEDW is delay 1 cycle
//BS=2**AL, // data width in bytes, derived parameter
//DW=BW*BS, // data width in bits, derived parameter
)(
input   clk,
input   rst_n, // dma reset
input   bus_rst_n, // bus reset
input   pio_adr_we,
input   pio_len_we,
input   [31:0] pio_d,
output  [31:0] pio_adr,
output  [31:0] pio_len,
output  [31:0] pio_cst,
input   [FW:0] dff_cnt,
output  dff_ack,
output  dff_eof,
output  done,
output  err,
output  [AW-1:0] biu_adr,
output  [BL-BLEN_TYPE:0] biu_len,
output  biu_req,
input   biu_ack,
input   rsp_val);

reg [AW-1:BL+AL] adr_reg;
reg [LW-1:BL+AL] len_reg;
reg [FW:0] rsp_cnt;
reg delay_cyc;

wire [LW:BL+AL] len_reg_1 = len_reg-1;
wire run_reg = ~len_reg_1[LW];
wire [FW:0] dat_cnt = rsp_cnt + dff_cnt + delay_cyc;

always @(posedge clk)
if (pio_adr_we | biu_ack) adr_reg <= pio_adr_we ? pio_d[31:BL+AL] : adr_reg+1;

always @(posedge clk or negedge rst_n)
if (~rst_n) len_reg <= 0; else 
if (pio_len_we | biu_ack) len_reg <= pio_len_we ? pio_d[31:BL+AL] : len_reg_1;

always @(posedge clk or negedge bus_rst_n)
if (~bus_rst_n) rsp_cnt <= 0; else 
rsp_cnt <= rsp_cnt + (biu_ack ? (2**BL-1) : -1) + (rsp_val ? 0 : 1);

always @(posedge clk or negedge bus_rst_n)
if (~bus_rst_n) delay_cyc <= 0; else 
delay_cyc <= DELAY_CNT ? dff_ack : 0;

assign pio_adr = adr_reg << (BL+AL);
assign pio_len = len_reg << (BL+AL);
assign pio_cst = rsp_cnt | dff_cnt<<16;
assign biu_adr = adr_reg << (BL+AL);
assign biu_len = BLEN_TYPE ? 2**BL-1 : 2**BL;
assign biu_req = run_reg & dat_cnt<=(2**FW-2**BL);
assign dff_ack = rsp_val;
assign dff_eof = ~run_reg & rsp_cnt==1;
assign done = ~run_reg & rsp_cnt==1 & rsp_val;
assign err = rsp_cnt==0 & rsp_val;

endmodule
