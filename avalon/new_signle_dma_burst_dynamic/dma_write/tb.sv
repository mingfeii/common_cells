`timescale 1ns / 1ns 

module tb();


parameter WIDTH = 128;
parameter HEIGHT = 32;
parameter PW = 8;
parameter AW = 32;
parameter DW = 32;
parameter DMA_BL = 3;
parameter BL = 4;
parameter APB_AW = 5;
parameter ID = 32'hCE6;
localparam SZ = WIDTH * HEIGHT;

localparam IDR = 0;
localparam CR = 1;
localparam SR = 2;
localparam DA0 = 3;
localparam DMA_LR = 4;
localparam BURSTR= 5;

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

    //write DMA
logic  bus_wrdy;
logic  bus_wval;
logic  [BL-1:0] bus_wlen;
logic  [AW-1:0] bus_waddr;
logic  [DW-1:0] bus_wdata;

logic src_rdy;
logic src_val;
logic src_eof;

logic [7:0] src_d;

localparam BASE0_ADDR = 32'h0;


int src_cnt;

bit [7:0] data_ch0;
logic [DW-1:0] bus_ch0;



always@(posedge clk or negedge rst_n)
    if (!rst_n) begin 
        bus_ch0 <= 0;
    end else if (bus_wrdy && bus_wval) begin 
        if (bus_waddr >= BASE0_ADDR)
            bus_ch0 <= bus_wdata;
    end 


assign src_eof = src_cnt == SZ - 1 && src_val && src_rdy;
assign bus_wrdy = 1'b1;


initial begin 
    data_ch0 = 0;
    src_d = data_ch0;
    src_val = 1'b0;
    @(posedge rst_n);
    while (src_cnt < SZ) begin 
        src_val = 1'b1;
        @(posedge clk);

        if (src_val & src_rdy) begin 
            data_ch0 = data_ch0 + 1;
            src_d = data_ch0;
        end 
    end 
    src_val = 1'b0;
    // repeat(1000)@(posedge clk);
    // $finish;
end 


always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        src_cnt <= 0;
    else if (src_val && src_rdy)
        src_cnt <= src_cnt + 1'b1;


initial begin 

    @(posedge rst_n);
    wrreg(CR,1);
    wrreg(DA0,BASE0_ADDR);
    wrreg(DMA_LR,1'b1);
    wrreg(BURSTR,8);
    wait(irq);
    repeat(10)@(posedge clk);
    wrreg(SR,1);
    repeat(1000);
    $finish();
end 




owl_dma_write #(

.WIDTH    (WIDTH  ),
.HEIGHT   (HEIGHT ),
.PW       (PW     ),
.AW       (AW     ),
.DW       (DW     ),
.DMA_BL   (DMA_BL ),
.BL       (BL     ),
.APB_AW   (APB_AW ),
.ID       (ID     )

)dma_w_U(

.clk       (clk   ),                               
.rst_n     (rst_n ),                               
.cpb_r     (cpb_r ),                               
.cpb_w     (cpb_w ),                               
.cpb_a     (cpb_a ),                               
.cpb_d     (cpb_d ),                               
.cpb_q     (cpb_q ),                               
.irq       (irq   ),                               
.bus_wrdy  (bus_wrdy  ),                               
.bus_wval  (bus_wval  ),                               
.bus_wlen  (bus_wlen  ),                               
.bus_waddr (bus_waddr ),                               
.bus_wdata (bus_wdata ),                               
                               
.src_rdy   (src_rdy   ),                               
.src_val   (src_val   ),                               
.src_eof   (src_eof   ),                               
.src_d     (src_d     )  
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