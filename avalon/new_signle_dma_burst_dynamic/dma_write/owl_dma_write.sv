module owl_dma_write #(
    parameter WIDTH = 1280,
    parameter HEIGHT = 960,
    parameter PW = 8,
    parameter AW = 32,
    parameter DW = 64,
    parameter DMA_BL = 3,
    parameter BL = 4,
    parameter APB_AW = 5,
    parameter ID = 32'hCE6
)(
    input clk,
    input rst_n,

    input cpb_r, // no use
    input cpb_w,
    input [APB_AW-1:0] cpb_a, // [6-12]
    input [31:0] cpb_d,
    output logic [31:0] cpb_q,
    output logic irq,
    //write DMA
    input   bus_wrdy,
    output  bus_wval,
    output  [BL-1:0] bus_wlen,
    output  [AW-1:0] bus_waddr,
    output  [DW-1:0] bus_wdata,

    //input stream 
    output logic src_rdy,
    input src_val,
    input src_eof,
    input [7:0] src_d 

);

localparam IDR = 0;
localparam CR = 1;
localparam SR = 2;
localparam DA0 = 3;
localparam DMA_LR = 4;
localparam BURSTR= 5;


logic [0:0] pio_adr_we;
logic  [31:0] dst_adr;
logic [7:0] pack_data;
logic dma_done;
reg [31:0] cr;

logic [BL:0] burstcount;

assign pio_adr_we = cpb_w && cpb_a == DA0;
wire cr_we = cpb_w && cpb_a==CR;
wire sr_we = cpb_w && cpb_a==SR;
wire pio_len_we = cpb_w && cpb_a == DMA_LR; 
wire burst_len_we = cpb_w && cpb_a == BURSTR;



always @(posedge clk or negedge rst_n)
  if (!rst_n)
    burstcount <= 2**DMA_BL;
  else if (burst_len_we)
    burstcount <= cpb_d[BL:0];


always_comb begin 
        pack_data = src_d;
    end 

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        cr <= 0;
    else if (cr_we)
        cr <= cpb_d;

wire en = cr[0];


wire [2:0] dst_bpp = PW/8 - 1;
logic rdy;
assign src_rdy = &rdy;

logic p2w_rdy;
logic p2w_val;
logic p2w_eof;
logic [DW-1:0] p2w_d;


  xlib_stream_p2w #(
      .UNALIGN(0),
      .PW(PW),
      .DW(DW)
  ) u_p2w (
      .clk  (clk),
      .rst_n(rst_n),
      .clr_n(1'b1),
      .bpp  (dst_bpp),
      .m_rdy(rdy),
      .m_val(src_val),
      .m_eof(src_eof),
      .m_dat(pack_data),
      .s_rdy(p2w_rdy),   //always request
      .s_val(p2w_val),
      .s_eof(p2w_eof),
      .s_dat(p2w_d)
  );


spi_dma_w #(
    .AW(AW),
    .AL($clog2(DW/8)),
    .BL(DMA_BL)
) spi_dma_w_dut (
    .clk(clk),
    .rst_n(rst_n),
    .bus_rst_n(rst_n),
    .pio_adr_we(pio_adr_we),
    .pio_d(cpb_d),
    .pio_adr(dst_adr),  //output 
    .dma_done(dma_done),
    .dma_rdy(p2w_rdy),
    .burstcount(burstcount),
    .dma_val(p2w_val),
    .dma_eof(p2w_eof),
    .dma_d(p2w_d),
    .bus_wrdy(bus_wrdy),
    .bus_wval(bus_wval),
    .bus_wlen(bus_wlen),
    .bus_waddr(bus_waddr),
    .bus_wdata(bus_wdata)
);


logic  dst_done,dst_done_is;


always_ff@(posedge clk)begin:PROC_DST_DONE_IS
  if (~en)
    dst_done_is <= '0;
  else begin 
      if (dst_done_is)
        dst_done_is <= '0;
      else if (dma_done==1'b1)
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
  SR : cpb_q = {31'b0,dst_done_is};
  default:cpb_q = ID;
endcase 
end 






endmodule 