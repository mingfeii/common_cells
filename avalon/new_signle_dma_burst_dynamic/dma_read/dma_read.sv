module dma_read #(

parameter WIDTH = 1280,
parameter HEIGHT = 960,
parameter PW = 32,
parameter AW = 32,
parameter DW = 64,
parameter DMA_BL = 3,
parameter BL = 4,
parameter APB_AW = 5,
parameter ID = 32'hCE5

)(

input clk,
input rst_n,

input cpb_r, // no use
input cpb_w,
input [APB_AW-1:0] cpb_a, // [6-12]
input [31:0] cpb_d,
output logic [31:0] cpb_q,
output logic irq,

//read dma 
input           src_bus_rrdy,
output          src_bus_rval,
output [BL-1:0] src_bus_rlen,
output [AW-1:0] src_bus_raddr,
input  [DW-1:0] src_bus_rdata,
input           src_bus_rdval,

//dst_str
input           dst_str_rdy,
output          dst_str_val,
// output          dst_str_eof_0,
output [PW-1:0] dst_str_d

);

localparam IDR = 0;
localparam CR = 1;
localparam SR = 2;
localparam SA = 3;
localparam DMA_LR = 4;
localparam DMA_BURSTR = 5;

wire cr_we = cpb_w & cpb_a==CR;
wire sr_we = cpb_w & cpb_a==SR;
wire src_ar_we = cpb_w & cpb_a==SA;
wire dma_lr_we = cpb_w & cpb_a == DMA_LR;
wire dma_burst_we = cpb_w & cpb_a == DMA_BURSTR;



//reg  [95:0] src_adr;
reg [32-1:0] src_adr;
logic [BL:0] burstcount;

reg [31:0] cr;
reg [31:0] dma_length;

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        dma_length <= 0;
    else if (dma_lr_we)
        dma_length <= cpb_d;

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        burstcount <= 0;
    else if (dma_burst_we)
        burstcount <= cpb_d[BL:0];


always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        cr <= 0;
    else if (cr_we)
        cr <= cpb_d;

wire en = cr[0];

logic  dma_rdy/*synthesis keep*/;
logic  dma_val/*synthesis keep*/;
logic  dma_eof/*synthesis keep*/;
logic  dma_done/*synthesis keep*/;
logic [DW-1:0] dma_d;

logic  dma_rdy_1/*synthesis keep*/;
logic  dma_val_1/*synthesis keep*/;
logic  dma_eof_1/*synthesis keep*/;
logic [PW-1:0] dma_d_1;
logic  dst_adr_we = '0;

logic  dst_done,dst_done_is;


always_ff@(posedge clk)begin:PROC_DST_DONE_IS
  if (~en)
    dst_done_is <= '0;
  else begin 
      if (dst_done_is)
        dst_done_is <= '0;
      else if (dst_done==1'b1)
        dst_done_is <= 1'b1;
    end 
  end 


always_ff @(posedge clk or negedge rst_n)
if (~rst_n) begin
  irq <= 0;
end
else begin

  irq <= ~irq ? dst_done_is : ~(sr_we & cpb_d[0]);
end


always_comb begin 

case (cpb_a)
  IDR : cpb_q = ID;
  CR : cpb_q = {31'b0,en};
  SR : cpb_q = {31'b0,irq};
  SA : cpb_q = src_adr[0*32+:32];
  DMA_LR : cpb_q = dma_length;
  default:cpb_q = ID;
endcase 
end 


spi_dma_r #(
.AW(AW), 
.AL($clog2(DW/8)), 
.BL(DMA_BL), 
.LW($clog2(WIDTH*HEIGHT)+2)
) u_src_dma (
.clk        (clk),
.rst_n      (en),
.bus_rst_n  (rst_n),
.pio_adr_we (src_ar_we),
.pio_len_we (dma_lr_we),
.pio_d      (cpb_d),
.pio_adr    (src_adr[0*32+:32]),
.pio_len    (),
.dma_done   (dma_done),
.burstcount (burstcount),

.dma_err    (),
.dma_rdy    (dma_rdy),
.dma_val    (dma_val),
.dma_eof    (dma_eof),
.dma_d      (dma_d),
.bus_rrdy   (src_bus_rrdy),
.bus_rval   (src_bus_rval),
.bus_rlen   (src_bus_rlen),
.bus_raddr  (src_bus_raddr),
.bus_rdata  (src_bus_rdata),
.bus_rdval  (src_bus_rdval));

wire [2:0] bpp = PW / 8 - 1;

xlib_stream_w2p #(
.PW(PW), 
.DW(DW)
)w2p_U(
.clk(clk),
.rst_n(en),
.clr_n(1'b1),
.bpp(bpp), // byte per primitive: 0=1B, 1=2B, 2=3B, 3=4B ...
.m_rdy(dma_rdy),
.m_val(dma_val),
.m_eof(dma_eof),
.m_dat(dma_d),
.s_rdy(dma_rdy_1),
.s_val(dma_val_1),
.s_eof(dma_eof_1),
.s_dat(dma_d_1)
);

assign dst_done = dma_rdy_1 & dma_val_1 & dma_eof_1;
assign dma_rdy_1 = dst_str_rdy;
assign dst_str_val = dma_val_1;
assign dst_str_d = dma_d_1;


  
endmodule 
