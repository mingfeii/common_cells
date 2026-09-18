// Compact DMA engine. address and length must align to burst size
module multi_dma_wc_bst #(parameter
AL=2, // address lsb (DATA_WIDTH=BW*(2**AL))
AW=32, // address msb
BL=4, // burst length width (BURST_LENGTH_IN_WORDS=2**BL); must: BL>0
FW=6, // fifo level width (FIFO_SIZE=2**FW);  must: FW>=BL
CH=2,
CW=$clog2(CH),
ALWAYS_EN=0, // RUN bit always set. if 1, RSP_CNT_W must set 0
RSP_CNT_W=0, // width of response counter, if 0, no response wait
BURST_RSP=0, // 0=per data, 1=per request. used when RSP_CNT_W!=0
BLEN_TYPE=0, // 0=VCI/AVM, 1=AXI
DELAY_CNT=0 // Altera dcfifo's USEDW is delay 1 cycle
//BS=2**AL, // data width in bytes, derived parameter
//DW=BW*BS, // data width in bits, derived parameter
)(
input                    clk,
input                    rst_n, // dma reset
input                    bus_rst_n, // bus reset
input   [CH-1:0]         pio_adr_we,
input                    pio_len_we, // if ALWAYS_EN==1, not used,statrt transfer
input   [31:0]           pio_d,
output  [CH-1:0][31:0]   pio_adr,
output  [31:0]           pio_len, // if ALWAYS_EN==1, output fixed 1
output  [31:0]           pio_cst,
input   [CH-1:0][FW:0]   dff_cnt,//from muti fifo 
//below signal hava only port 
input                    dff_ack,
input                    dff_eof,
output                   done,
output  [AW-1:0]         biu_adr,
output  [BL-BLEN_TYPE:0] biu_len,
output logic [CW-1:0]    biu_ch,

output                   biu_req,
input                    biu_ack,
input                    rsp_val // used only when RSP_CNT_W!=0
); 

logic [CH-1:0] burst_request; //muti channel req

reg   [CH-1:0][AW-1:BL+AL] adr_reg;
reg   [CH-1:0] run_reg;
reg   [RSP_CNT_W:0] rsp_cnt;
reg   delay_cyc;

wire dff_done = dff_ack & dff_eof;

always@(posedge clk) begin
    integer i;
    for (i=0;i<CH;i++) if (pio_adr_we[i] | biu_ack & biu_ch==i)
        adr_reg[i] <= pio_adr_we[i] ? pio_d[31:BL+AL] : adr_reg[i]+1;
  end

always_ff@(posedge clk or negedge rst_n)
  if(~rst_n)
    run_reg <= ALWAYS_EN ? {CH{1'b1}} : '0;
  else  
    begin 
      integer i;
      for (i=0;i<CH;i++)
        begin 
          if (pio_len_we || (dff_done && i==biu_ch))
            run_reg[i ] <= ALWAYS_EN ? 1 : pio_len_we ? pio_d[0] : 0;
        end 
    end

always @(posedge clk or negedge bus_rst_n)
if (~bus_rst_n) rsp_cnt <= 0; else
rsp_cnt <= RSP_CNT_W!=0 ? rsp_cnt + ((BURST_RSP ? biu_ack : dff_ack) ? 1 : 0) + (rsp_val ? -1 : 0) : 0;

always @(posedge clk or negedge bus_rst_n)
  if (~bus_rst_n) delay_cyc <= 0; 
  else delay_cyc <= DELAY_CNT ? dff_ack : 0;

genvar i;
generate for (i=0;i<CH;i=i+1)begin:PIO_ADRR
  assign pio_adr[i] = adr_reg[i] << (BL+AL);
  assign burst_request[i] = run_reg[i] & dff_cnt[i]>=(2**BL+delay_cyc) & ~rsp_cnt[RSP_CNT_W];
end endgenerate

assign pio_len = run_reg[biu_ch];
assign pio_cst = rsp_cnt | dff_cnt[biu_ch]<<16;
assign biu_adr = adr_reg[biu_ch] << (BL+AL);
assign biu_len = BLEN_TYPE ? 2**BL-1 : 2**BL;
assign done = RSP_CNT_W==0 ? dff_done : ~run_reg[biu_ch] & rsp_cnt==1 & rsp_val;




always@(posedge clk or negedge rst_n)
  if (!rst_n)
    biu_ch <= 0;
  else if (biu_ack)
    biu_ch <= biu_ch == CH-1 ? 0 : biu_ch + 1'b1; 

assign biu_req = burst_request[biu_ch];

// assign biu_req = grant[biu_ch];
// wire [CH-1:0] grant;

//  ch_sel #(
// .CH(CH)
// )ch_sel_inst(
//   .clk     (clk    ),
//   .rst_n   (rst_n  ),
//   .run_sel (run_reg ),
//   .request (burst_request),
//   .gnt_pos (biu_ch ),
//   .update  (biu_ack ),
//   .grant_o (grant )
// );




endmodule
