module owl_dma_write #(
    parameter WIDTH = 1280,
    parameter HEIGHT = 960,
    parameter PW = 8,
    parameter AW = 32,
    parameter DW = 64,
    parameter DMA_BL = 3,
    parameter BL = 4,
    parameter APB_AW = 5,
    parameter CH = 1, //must <= 3
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
    input [11:0] src_d //fixed 12 bit input 

);

localparam IDR = 0;
localparam CR = 1;
localparam SR = 2;
localparam DA0 = 3;
localparam DMA_LR = 4;
localparam DA1 = 5;
localparam DA2 = 6;


logic [2:0] pio_adr_we;
logic [CH-1:0] [31:0] dst_adr;
logic [CH*8-1:0] pack_data;
logic dma_done;
reg [31:0] cr;

assign pio_adr_we[0] = cpb_w && cpb_a == DA0;
assign pio_adr_we[1] = cpb_w && cpb_a == DA1;
assign pio_adr_we[2] = cpb_w && cpb_a == DA2;
wire cr_we = cpb_w && cpb_a==CR;
wire sr_we = cpb_w && cpb_a==SR;
wire pio_len_we = cpb_w && cpb_a == DMA_LR; 

always_comb begin 
    integer i;
    for (i = 0; i < CH; i++) begin
        pack_data[i*8+:8] = {src_d[i*4+:4],4'b0000};
    end 
end 

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        cr <= 0;
    else if (cr_we)
        cr <= cpb_d;

wire en = cr[0];


wire [2:0] dst_bpp = PW/8 - 1;
logic [CH-1:0] rdy;
assign src_rdy = &rdy;

logic [CH-1:0] p2w_rdy;
logic [CH-1:0] p2w_val;
logic [CH-1:0] p2w_eof;
logic [DW*CH-1:0] p2w_d;

generate 
genvar ch;
for (ch = 0; ch < CH; ch = ch + 1) begin : GEN_P2W
    xlib_stream_p2w #(
        .UNALIGN(0),
        .PW(PW),
        .DW(DW)
    ) u_p2w (
        .clk  (clk),
        .rst_n(rst_n),
        .clr_n(1'b1),
        .bpp  (dst_bpp),
        .m_rdy(rdy[ch]),
        .m_val(src_val),
        .m_eof(src_eof),
        .m_dat(pack_data[ch*8+:8]),
        .s_rdy(p2w_rdy),   //always request
        .s_val(p2w_val[ch]),
        .s_eof(p2w_eof[ch]),
        .s_dat(p2w_d[ch*DW+:DW])
    );
end
endgenerate

multi_dma_w #(
    .AW(AW),
    .AL($clog2(DW/8)),
    .BL(DMA_BL),
    .CH(CH)
) multi_dma_w_dut (
    .clk(clk),
    .rst_n(rst_n),
    .bus_rst_n(rst_n),
    .pio_adr_we(pio_adr_we[CH-1:0]),
    .pio_len_we(pio_len_we),
    .pio_d(cpb_d),
    .pio_adr(dst_adr),  //output 
    .dma_done(dma_done),
    .dma_rdy(p2w_rdy),
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

//   DA1 : cpb_q = dst_adr[1*32+:32];
//   DA2 : cpb_q = dst_adr[2*32+:32];
  SR : cpb_q = {31'b0,dst_done_is};
  default:cpb_q = ID;
endcase 
end 






endmodule 