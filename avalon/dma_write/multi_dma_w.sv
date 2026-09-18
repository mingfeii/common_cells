
module multi_dma_w #(parameter 
  AW=32, 
  AL=2, 
  BL=3,
  CH=2,
  DW=8*(2**AL)
)(
input                     clk,
input                     rst_n,
input                     bus_rst_n,
input   [CH-1:0]          pio_adr_we,
input   [31:0]            pio_d,
output  [CH-1:0][31:0]    pio_adr,
input                     pio_len_we,

output                    dma_done,
output  [CH-1:0]          dma_rdy,
input   [CH-1:0]          dma_val,
input   [CH-1:0]          dma_eof,
input   [CH-1:0][DW-1:0]  dma_d,

input                     bus_wrdy,
output                    bus_wval,
output [BL-0:0]           bus_wlen,
output [AW-1:0]           bus_waddr,
output [DW-1:0]           bus_wdata
);

localparam FW=8; // hardware dependent
localparam CW=$clog2(CH);
logic [CW-1:0] biu_ch;
logic          dff_eof;
logic [CH-1:0] dff_eof_1;
logic dff_ack, dff_rval,dff_eof_ffo;
logic [CH-1:0] dff_rval_1;
logic [CH-1:0]  dff_pop;
logic [CH-1:0][FW:0] dff_cnt;
logic [CH-1:0] [DW-1:0] bus_wdata_1;
logic           dma_done_1;
logic  [CH-1:0] done;

assign dff_pop=dff_ack << biu_ch;
assign dff_rval=dff_rval_1[biu_ch];
assign dff_eof_ffo=dff_eof_1[biu_ch];
assign bus_wdata=bus_wdata_1[biu_ch];
assign dff_eof =  dff_eof_ffo & dff_rval; //ensure eof is 0 if fifo empty
assign dma_done= &done ;

always_ff@(posedge clk or negedge rst_n)
  if (~rst_n)
    done <= 1'b0;
  else  begin 
    if (dma_done_1) 
       done[biu_ch] <= 1'b1;
    else if (dma_done)
      done <= '0;
  end 



generate 
  genvar i;
  for (i=0;i<CH;i++)begin:FF_IN

  wire wreq_pre =  dma_val[i] & dma_rdy[i];

  xlib_xyz_fifo #(
    .DW(DW+1),
    .FW(FW)
  ) u_dff (
  .clk        (clk),
  .rst_n      (rst_n),
  .wrdy       (dma_rdy[i]),
  .wval       (wreq_pre),
  .wd         ({dma_eof[i],dma_d[i]}),
  .cnt        (dff_cnt[i]),
  .rrdy       (dff_pop[i]),
  .rval       (dff_rval_1[i]),
  .rd         ({dff_eof_1[i], bus_wdata_1[i]}));
  end
endgenerate

multi_dma_wc #(
  .AW(AW),
  .AL(AL), 
  .BL(BL), 
  .FW(FW),
  .CH(CH), 
  .ALWAYS_EN(0)
) u_dma (
.clk        (clk),
.rst_n      (rst_n),
.bus_rst_n  (bus_rst_n),
.pio_adr_we (pio_adr_we),
.pio_len_we (pio_len_we),
.pio_d      (pio_d),
.pio_adr    (pio_adr),
.biu_ch     (biu_ch),
.pio_len    (),
.pio_cst    (),
.dff_cnt    (dff_cnt), // i
.dff_eof    (dff_eof), // i
.dff_ack    (dff_ack), // o
.done       (dma_done_1),
.biu_adr    (bus_waddr),
.biu_len    (bus_wlen),
.biu_sob    (),
.biu_eob    (),
.biu_val    (bus_wval),
.biu_rdy    (bus_wrdy),
.rsp_val    (1'bx));

endmodule
