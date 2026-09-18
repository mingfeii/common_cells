/*
Top level module for dlp spi controller 

*/
module spi_slave_top #(

parameter WIDTH_MAX = 1280,
parameter HEIGHT_MAX = 960,
parameter PW = 32,
parameter AW = 32,
parameter DW = 32, //use 32 bit burst data width
parameter DMA_BL = 3,
parameter BL = 4,
parameter APB_AW = 6,
parameter ID = 32'hACC

) (
input clk,
input rst_n,
//read dma 
input           src_bus_rrdy,
output          src_bus_rval,
output [BL-1:0] src_bus_rlen,
output [AW-1:0] src_bus_raddr,
input  [DW-1:0] src_bus_rdata,
input           src_bus_rdval,
output logic    dma_done_R, //dma read done signal, used to ack spi master
//write DMA
input   bus_wrdy,
output  bus_wval,
output  [BL-1:0] bus_wlen,
output  [AW-1:0] bus_waddr,
output  [DW-1:0] bus_wdata,
output logic     dma_done_w, //dma write done signal, used to ack spi master
// SPI interface
input  logic        mosi,
output logic        miso,
input  logic        sclk,
input  logic        cs_n
);



// package rx side  
logic [31:0] rx_data_s;
logic rx_data_valid_s;
logic [31:0] pkt_rx_addr;
logic [31:0] pkt_rx_length;
logic [31:0] pkt_rx_data;
logic        pkt_rx_data_valid;
logic [15:0] pkt_rx_id;
logic [15:0] pkt_rx_type;
logic        pkt_rx_start;
logic        pkt_rx_end;
logic        pkt_rx_enable;
logic        pkg_rx_error;
logic        pkt_rx_data_last;
logic        header_crc_error;
logic        data_crc_error;

//package tx side 
logic [31:0] data_in;      
logic        data_in_valid;
logic        data_in_ready;
logic        ack_ready;
logic        read_cmd_is; 
logic [31:0] tx_base_addr;    
logic [31:0] tx_length;       
logic [15:0] tx_id;          
logic [15:0] tx_packet_type;
logic        tx_enable;
logic [31:0] tx_data;      
logic        tx_data_valid;
logic        tx_data_ready;
logic        tx_data_end;
logic        sending;      
logic        tx_error;

//spi low level
logic spi_tx_error;
logic spi_tx_done_pulse;
logic [31:0] control;

//dma_write signals
logic [DMA_BL:0] write_burstcount;
logic [31:0] pio_d_w;
logic pio_adr_we_w;
logic [DW-1:0] dma_d_w;
logic dma_val_w;
logic dma_eof_w;
logic dma_rdy_w;
logic [31:0] data_in_w;
logic        data_in_valid_w;
logic        data_in_ready_w; 
logic        ack_ready_w; 
logic [31:0] tx_base_addr_w;   
logic [31:0] tx_length_w;      
logic [15:0] tx_id_w;          
logic [15:0] tx_packet_type_w;
logic [31:0] dst_adr;

//dma_read signals
logic [DMA_BL:0] read_burstcount;
logic [31:0] pio_d_R;
logic [31:0] pio_d_len_R;
logic pio_adr_we_R;
logic pio_len_we_R;
logic [DW-1:0] dma_d_R;
logic dma_val_R;
logic dma_eof_R;
logic dma_rdy_R;
logic [31:0] data_in_R;
logic        data_in_valid_R;
logic        data_in_ready_R; 
logic        ack_ready_R; 
logic [31:0] tx_base_addr_R;   
logic [31:0] tx_length_R;      
logic [15:0] tx_id_R;          
logic [15:0] tx_packet_type_R;

logic pkt_rx_clear;

//config spi slave , fixed config when in spi_slave_top module
assign control = {16'd0, 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};

spi_packet_tx u_spi_packet_tx_slave (
    .clk           (clk),
    .pkt_rx_clear (pkt_rx_clear),
    .rst_n         (rst_n),
    .data_in       (data_in),
    .data_in_valid (data_in_valid),
    .data_in_ready (data_in_ready),
    .tx_base_addr  (tx_base_addr),
    .tx_length     (tx_length),
    .tx_data       (tx_data),
    .tx_data_valid (tx_data_valid),
    .tx_data_ready (tx_data_ready),
    .tx_packet_type (tx_packet_type),
    .tx_id         (tx_id),
    .tx_data_end   (tx_data_end),
    .tx_enable     (1'b1),
    .read_cmd_is   (read_cmd_is),
    .sim_wr        (1'b0),
    .bypass_syncword (1'b0), // bypass sync word for test
    .ack_ready     (ack_ready),
    .sending       (sending),
    .error         (tx_error)
);

assign data_in = data_in_R;
assign data_in_valid = data_in_valid_R | data_in_valid_w;
assign data_in_ready_R = data_in_ready;
assign data_in_ready_w = data_in_ready;
assign tx_base_addr = tx_base_addr_R | tx_base_addr_w;
assign tx_length = tx_length_R | tx_length_w;
assign tx_packet_type = tx_packet_type_R | tx_packet_type_w;
assign tx_id = tx_id_R | tx_id_w;
assign ack_ready_R = ack_ready;
assign ack_ready_w = ack_ready;


spi_packet_rx u_spi_packet_rx (
    .clk           (clk),
    .rst_n         (rst_n),
    .rx_data       (rx_data_s),
    .rx_data_valid (rx_data_valid_s),
    .pkt_rx_enable (1'b1),
    .pkt_rx_addr    (pkt_rx_addr),
    .pkt_rx_length  (pkt_rx_length),
    .pkt_rx_clear   (pkt_rx_clear),
    .pkt_rx_data      (pkt_rx_data),
    .pkt_rx_data_valid(pkt_rx_data_valid),
    .pkt_rx_id        (pkt_rx_id),
    .pkt_rx_type      (pkt_rx_type),  
    .pkt_rx_start  (pkt_rx_start),
    .pkt_rx_end    (pkt_rx_end),
    .pkt_rx_data_last(pkt_rx_data_last),
    .header_crc_error(header_crc_error),
    .data_crc_error(data_crc_error),
    .error(pkg_rx_error)
);


spi_slave uut_slave (
    .sys_clk(clk),
    .sys_rst_n(rst_n),
    .mosi(mosi),
    .miso(miso),
    .sclk(sclk),
    .cs_n(cs_n),
    .control(control),
    .tx_data_valid(tx_data_valid),
    .tx_data_ready(tx_data_ready),
    .tx_error(spi_tx_error),
    .tx_done_pulse(spi_tx_done_pulse),
    .tx_data(tx_data),
    .rx_data(rx_data_s),
    .rx_data_valid(rx_data_valid_s)
);


bus_write_control #(
    .BL(DMA_BL),
    .DW(DW)
) bus_write_ctl(
.clk(clk),            
.rst_n(rst_n),          
.pkt_rx_clear(pkt_rx_clear),
//from spi_package_rx module
.pkt_rx_addr         (pkt_rx_addr      ),                                      
.pkt_rx_length       (pkt_rx_length    ),                                    
.pkt_rx_data         (pkt_rx_data      ),                                      
.pkt_rx_id           (pkt_rx_id        ),                           
.pkt_rx_type         (pkt_rx_type      ),                               
.header_crc_error    (header_crc_error ),                                    
.data_crc_error      (data_crc_error   ),                                
.pkt_rx_start        (pkt_rx_start     ),                               
.pkt_rx_end          (pkt_rx_end       ),                           
.pkt_rx_data_valid   (pkt_rx_data_valid),                                    
.pkt_rx_data_last    (pkt_rx_data_last ),                                   
//output to dma 
.write_burstcount(write_burstcount),
.pio_d(pio_d_w),
.pio_adr_we(pio_adr_we_w),
.dma_d(dma_d_w),
.dma_val(dma_val_w),
.dma_eof(dma_eof_w),
.dma_rdy(dma_rdy_w),
.dma_done(dma_done_w),
//output to ack logic 
.data_in(data_in_w),      //not use for resp ack 
.data_in_valid(data_in_valid_w),
.data_in_ready(data_in_ready_w), //not use for resp ack 
.ack_ready(ack_ready_w), 
.tx_base_addr(tx_base_addr_w),    //also called status as in write ack, resue this word position
.tx_length(tx_length_w),       
.tx_id(tx_id_w),          
.tx_packet_type(tx_packet_type_w)
);


bus_read_control #(
    .BL(DMA_BL),
    .DW(DW)
) bus_read_ctl(

.clk(clk),            
.rst_n(rst_n),       
.pkt_rx_clear(pkt_rx_clear),      
//from spi_package_rx module
.pkt_rx_addr        (pkt_rx_addr     ),                           
.pkt_rx_length      (pkt_rx_length   ),                         
.pkt_rx_data        (pkt_rx_data     ),                           
.pkt_rx_id          (pkt_rx_id       ),                
.pkt_rx_type        (pkt_rx_type     ),                    
.header_crc_error   (header_crc_error),                         
.data_crc_error     (data_crc_error  ),                     
.pkt_rx_start       (pkt_rx_start    ),                    
//output to dma 
.read_burstcount(read_burstcount),
.pio_d(pio_d_R),
.pio_d_len(pio_d_len_R), // Length in bytes, must be aligned to 2**AL
.pio_adr_we(pio_adr_we_R),
.pio_len_we(pio_len_we_R),
//read data from bus 
.dma_d(dma_d_R),
.dma_val  (dma_val_R  ),          
.dma_eof  (dma_eof_R  ),          
.dma_rdy  (dma_rdy_R  ),          
.dma_done (dma_done_R ),           
//output to ack logic 
.data_in(data_in_R),      
.data_in_valid(data_in_valid_R),
.data_in_ready(data_in_ready_R),
.ack_ready(ack_ready_R),   
.tx_data_end(tx_data_end),
.read_cmd_is(read_cmd_is),
.tx_base_addr(tx_base_addr_R),    //also called status as in write ack, resue this word position
.tx_length(tx_length_R),       
.tx_id(tx_id_R),          
.tx_packet_type(tx_packet_type_R)

);



//dma read part ************************************************************

logic [31:0] src_rd_adr;


spi_dma_r #(
.AW(AW), 
.AL($clog2(DW/8)), 
.BL(DMA_BL), 
.LW($clog2(WIDTH_MAX*HEIGHT_MAX)+2)
) u_src_dma (
.clk        (clk),
.rst_n      (rst_n),
.bus_rst_n  (rst_n),
.pio_adr_we (pio_adr_we_R),
.pio_len_we (pio_len_we_R),
.pio_d      (pio_d_R),
.pio_d_len  (pio_d_len_R),
.pio_adr    (src_rd_adr),
.pio_len    (),
.burstcount (read_burstcount),
.dma_done   (dma_done_R),
.dma_err    (),
.dma_rdy    (dma_rdy_R),
.dma_val    (dma_val_R),
.dma_eof    (dma_eof_R),
.dma_d      (dma_d_R),
.bus_rrdy   (src_bus_rrdy),
.bus_rval   (src_bus_rval),
.bus_rlen   (src_bus_rlen),
.bus_raddr  (src_bus_raddr),
.bus_rdata  (src_bus_rdata),
.bus_rdval  (src_bus_rdval));


spi_dma_w #(
.AW(AW),
.AL($clog2(DW/8)),
.BL(DMA_BL)
) spi_dma_w_dut (
.clk(clk),
.rst_n(rst_n),
.bus_rst_n(rst_n),
.pio_adr_we(pio_adr_we_w),
.pio_d(pio_d_w),
.burstcount(write_burstcount),
.pio_adr(dst_adr),  //output 
.dma_done(dma_done_w),
.dma_rdy(dma_rdy_w),
.dma_val(dma_val_w),
.dma_eof(dma_eof_w),
.dma_d(dma_d_w),
.bus_wrdy(bus_wrdy),
.bus_wval(bus_wval),
.bus_wlen(bus_wlen),
.bus_waddr(bus_waddr),
.bus_wdata(bus_wdata)
);







endmodule 