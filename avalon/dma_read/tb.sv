`timescale 1ns / 1ns 

module tb();


parameter WIDTH = 1280;
parameter HEIGHT = 960;
parameter PW = 8;
parameter AW = 32;
parameter DW = 64;
parameter DMA_BL = 3;
parameter BL = 4;
parameter APB_AW = 5;
parameter ID = 32'hCE5;
localparam SZ = WIDTH * HEIGHT;

parameter   BUSNW=1,//write channel : dst image write 
            BUSNR=2,// read channel : src image channel + map table channel  
            SDR_ARDY_RATE=100,
            SDR_SZ=2**25;

localparam IDR = 0;
localparam CR = 1;
localparam SR = 2;
localparam SA = 3;
localparam DMA_LR = 4;

logic clk;
logic rst_n;
logic cpb_r; // no use
logic cpb_w;
logic [APB_AW-1:0] cpb_a; // [6-12]
logic [31:0] cpb_d;
logic [31:0] cpb_q;
logic irq;

initial begin:GEN_CLK
    clk=0;
    forever begin 
        #5 clk=~clk;
    end 
end 

initial begin:GEN_RST
    rst_n=1'b0;
    repeat(100)
    @(posedge clk);
    rst_n=1'b1;
end 

//read dma 
logic          src_bus_rrdy;
logic          src_bus_rval;
bit [BL-1:0] src_bus_rlen;
logic [AW-1:0] src_bus_raddr;
logic [DW-1:0] src_bus_rdata;
logic          src_bus_rdval;


logic        dst_str_rdy;
logic        dst_str_val;
logic        dst_str_eof;
logic  [PW-1:0]    dst_str_d;


logic  [BUSNR-1:0]               bus_rrdy ;
logic  [BUSNR-1:0]               bus_rval ;
logic  [BUSNR-1:0] [BL-1:0]      bus_rlen ;
logic  [BUSNR-1:0] [AW-1:0]      bus_raddr;
logic  [BUSNR-1:0] [DW-1:0]      bus_rdata;
logic  [BUSNR-1:0]               bus_rdval;
logic  [BUSNW-1:0]               bus_wrdy ;
logic  [BUSNW-1:0]               bus_wval = 0 ;
logic  [BUSNW-1:0] [BL-1:0]      bus_wlen = 8 ;
logic  [BUSNW-1:0] [AW-1:0]      bus_waddr = 0;
logic  [BUSNW-1:0] [DW-1:0]      bus_wdata = 0;
logic                            sdr_wrdy ;
logic                            sdr_wval ;
logic              [BL-1:0]      sdr_wlen ;
logic              [AW-1:0]      sdr_waddr;
logic              [DW-1:0]      sdr_wdata;
logic                            sdr_rrdy ;
logic                            sdr_rval ;
logic              [BL-1:0]      sdr_rlen ;
logic              [AW-1:0]      sdr_raddr;
logic              [DW-1:0]      sdr_rdata;
logic                            sdr_rdval;


assign dst_str_rdy = 1'b1;

assign  src_bus_rrdy=bus_rrdy;
assign  src_bus_rdval=bus_rdval;
assign  src_bus_rdata=bus_rdata;
assign  bus_rval=src_bus_rval;
assign  bus_rlen=src_bus_rlen;
assign  bus_raddr=src_bus_raddr;

localparam BASE0_ADDR = 32'h1000;

initial begin 
    integer i,j,ch,mem_addr;
    mem_addr = BASE0_ADDR;
    for(i=0;i<HEIGHT;i++)
        for(j=0;j<WIDTH;j++)begin 
            sdr.mem[i*WIDTH+j+mem_addr]=(i*WIDTH+j)% 256 ;
        end   
end


initial begin 

    @(posedge rst_n);
    wrreg(CR,1);
    wrreg(SA,BASE0_ADDR);
    wrreg(DMA_LR,SZ);
    wait(irq);
    repeat(10)@(posedge clk);
    wrreg(SR,1);
    repeat(1000);
    $finish();
end 

xlib_avalon_bus #(
 .NW(BUSNW),
 .NR(BUSNR),
 .DW(DW),
 .AW(AW),
 .BL(BL),
 .R_FW(4)
 ) bus (
.clk      (clk),
.rst_n    (rst_n),
.s_wrdy   (bus_wrdy),  
.s_wval   (bus_wval),
.s_wlen   (bus_wlen),
.s_waddr  (bus_waddr),
.s_wdata  (bus_wdata),
.s_rrdy   (bus_rrdy),
.s_rval   (bus_rval),
.s_rlen   (bus_rlen),
.s_raddr  (bus_raddr),
.s_rdata  (bus_rdata),
.s_rdval  (bus_rdval),
.m_wrdy   (sdr_wrdy),
.m_wval   (sdr_wval),
.m_wlen   (sdr_wlen),
.m_waddr  (sdr_waddr),
.m_wdata  (sdr_wdata),
.m_rrdy   (sdr_rrdy),
.m_rval   (sdr_rval),
.m_rlen   (sdr_rlen),
.m_raddr  (sdr_raddr),
.m_rdata  (sdr_rdata),
.m_rdval  (sdr_rdval));


xlib_avalon_ram #(
.DW(DW),
.AW(AW),
.BL(BL),
.BI(1),
.SZ(SDR_SZ),
.ARDY_RATE(SDR_ARDY_RATE)
) sdr (
.clk    (clk),
.rst_n  (rst_n),
.rrdy   (sdr_rrdy),
.rval   (sdr_rval),
.rlen   (sdr_rlen),
.raddr  (sdr_raddr),
.rdata  (sdr_rdata),
.rdval  (sdr_rdval),
.wrdy   (sdr_wrdy),
.wval   (sdr_wval),
.wlen   (sdr_wlen),
.waddr  (sdr_waddr),
.wdata  (sdr_wdata));

dma_read #(

.WIDTH    (WIDTH  ),
.HEIGHT   (HEIGHT ),
.PW       (PW     ),
.AW       (AW     ),
.DW       (DW     ),
.DMA_BL   (DMA_BL ),
.BL       (BL     ),
.APB_AW   (APB_AW ),
.ID       (ID     )

)dma_r_U(

.clk             (clk             ),                               
.rst_n           (rst_n           ),                               
.cpb_r           (cpb_r           ),                               
.cpb_w           (cpb_w           ),                               
.cpb_a           (cpb_a           ),                               
.cpb_d           (cpb_d           ),                               
.cpb_q           (cpb_q           ),                               
.irq             (irq             ),                               
.src_bus_rrdy  (src_bus_rrdy  ),                               
.src_bus_rval  (src_bus_rval  ),                               
.src_bus_rlen  (src_bus_rlen  ),                               
.src_bus_raddr (src_bus_raddr ),                               
.src_bus_rdata (src_bus_rdata ),                               
.src_bus_rdval (src_bus_rdval ),                               
                               
.dst_str_rdy   (dst_str_rdy   ),                               
.dst_str_val   (dst_str_val   ),                               
// .dst_str_eof   (dst_str_eof   ),                               
.dst_str_d     (dst_str_d     )  
);

task wrreg(input logic [APB_AW-1:0] addr, input logic [31:0] d);
    cpb_d <= d;
    cpb_a <= addr;
    @(negedge clk);
    cpb_w <= 1;
    @(posedge clk);
    cpb_w <= 0;
    @(posedge clk);
endtask



endmodule