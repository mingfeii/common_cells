//axi uart  to read a signal address location 
//TODO write support
//usage : send these bytes from PC UART  
// 8'h52 + araddr0 + araddr1 + araddr2 + araddr3 + read_length
//when araddr [31:0] = {araddr0,araddr1,araddr2,araddr3};
module axi_uart_read #(
    parameter DATA_WIDTH   = 128, //fixed 
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 8,
    parameter ID           = 0,
    parameter CLOCK_FRQ    = 100_000_000,
    parameter BADRATE      = 115_200,
    parameter UART_BIT     =    8,
    parameter FW           =    4

)(
    input                                  clk,
    input                                  rst_n,

    input   logic                          uart_rx,
    output  logic                          uart_tx,


    output  bit [ID_WIDTH - 1 : 0]        awid,
    output  bit [ADDR_WIDTH - 1 : 0]      awaddr,
    output  bit [7 : 0]                   awlen,
    output  bit [2 : 0]                   awsize,
    output  bit [1 : 0]                   awburst,
    output  bit                           awlock,
    output  bit [3 : 0]                   awcache,
    output  bit [2 : 0]                   awprot,
    output  bit [3 : 0]                   awqos,
    output  bit [3 : 0]                   awregion,
    output  bit                           awvalid,
    input   logic                           awready,

    output  bit [DATA_WIDTH - 1 : 0]      wdata,
    output  bit [DATA_WIDTH / 8 - 1 : 0]  wstrb,
    output  bit                           wlast,
    output  bit                           wvalid,
    input  logic                            wready,

    input  logic [ID_WIDTH - 1 : 0]         bid,
    input  logic [1 : 0]                    bresp,
    input  logic                            bvalid,
    output  bit                           bready,

    output   logic [ID_WIDTH - 1 : 0]       arid,
    output   logic [ADDR_WIDTH - 1 : 0]     araddr,
    output   logic [7 : 0]                  arlen,
    output   logic [2 : 0]                  arsize,
    output   logic [1 : 0]                  arburst,
    output   logic                          arlock,
    output   logic [3 : 0]                  arcache,
    output   logic [2 : 0]                  arprot,
    output   logic [3 : 0]                  arqos,
    output   logic [3 : 0]                  arregion,
    output   logic                          arvalid,
    input  logic                            arready,

    input  logic [ID_WIDTH - 1 : 0]         rid,
    input  logic [DATA_WIDTH - 1 : 0]       rdata,
    input  logic [1 : 0]                    rresp,
    input  logic                            rlast,
    input  logic                            rvalid,
    output  logic                           rready

);
localparam UART_READ = 8'h52;
localparam FIFO_DEPTH = 2 ** FW;


  // assign awid       = 0;   
  // assign awaddr     = 0;   
  // assign awlen      = 0;   
  // assign awsize     = 3'b100;   
  // assign awburst    = 2'b01;   
  // assign awlock     = 0;   
  // assign awcache    = 0;   
  // assign awprot     = 0;   
  // assign awqos      = 0;   
  // assign awregion   = 0;   
  // assign awvalid    = 0;   
  // assign bready     = 1'b0; 

  //  assign   wdata  =  0;
  //  assign   wstrb  =  0;
  //  assign   wlast  =  0;
  //  assign   wvalid =  0;
//command format 
/*
  UART_READ + UART_BURST_LENGTH 
*/

logic [7:0] rx_data_byte;
logic rx_valid;

logic tx_complete;

usart_rx #(
  .CLOCK_FRQ(CLOCK_FRQ),
  .BADRATE(BADRATE),
  .UART_BIT(UART_BIT)

)uart_rx_in_axi_U (
	.clock(clk),
	.rxd(uart_rx),
	.rst_n(rst_n),
	.rx_data_byte(rx_data_byte),
	.rx_valid_wire(rx_valid)
);



assign arid = ID;
assign arsize = 3'b100;
assign arburst = 2'b01;
// assign arlen = 0;


wire rd_start = rx_valid==1'b1 && rx_data_byte==UART_READ;

logic [7:0] tx_count;


enum int unsigned {RD_IDLE,
                  RD_ADDRESS0,
                  RD_ADDRESS1,
                  RD_ADDRESS2,
                  RD_ADDRESS3,
                  RD_BURST_LENGTH,
                  RD_DATA} rd_state,rd_state_nxt;

always_ff@(posedge clk or negedge rst_n)
  if (!rst_n)
    rd_state <= RD_IDLE;
  else 
    rd_state <= rd_state_nxt;

always_comb begin 
  rd_state_nxt = rd_state;
  case (rd_state)
    RD_IDLE: begin 
      if (rd_start)
        rd_state_nxt = RD_ADDRESS0;
    end 
    RD_ADDRESS0: begin 
      if (rx_valid)
        rd_state_nxt = RD_ADDRESS1;
    end 
    RD_ADDRESS1: begin 
      if (rx_valid)
        rd_state_nxt = RD_ADDRESS2;
    end 
    RD_ADDRESS2: begin 
      if (rx_valid)
        rd_state_nxt = RD_ADDRESS3;
    end 
    RD_ADDRESS3: begin 
      if(rx_valid) 
        rd_state_nxt = RD_BURST_LENGTH;
    end 
    RD_BURST_LENGTH:begin 
      if (rx_valid)
        rd_state_nxt = RD_DATA;
    end 
    RD_DATA: begin 
      if (tx_complete)
        rd_state_nxt = RD_IDLE;   
    end 
endcase
end 

always_ff@(posedge clk or negedge rst_n)
  if (!rst_n) 
    arlen <= 0;
  else if (rd_state == RD_BURST_LENGTH && rx_valid == 1'b1)
    arlen <= rx_data_byte;
  else if (tx_complete)
    arlen <= 0;

always_ff@(posedge clk or negedge rst_n)
  if (!rst_n)
    araddr <= 32'h00000000;
  else if (rd_state == RD_ADDRESS0 && rx_valid==1'b1)
    araddr[3*8+:8] <= rx_data_byte;
  else if (rd_state == RD_ADDRESS1 && rx_valid==1'b1)
    araddr[2*8+:8] <= rx_data_byte;
  else if (rd_state == RD_ADDRESS2 && rx_valid==1'b1)
    araddr[1*8+:8] <= rx_data_byte;
  else if (rd_state == RD_ADDRESS3 && rx_valid==1'b1)
    araddr[0*8+:8] <= rx_data_byte;
  else if (tx_complete)
    araddr <= 32'h00000000;

always_ff@(posedge clk or negedge rst_n)
  if (!rst_n)
    arvalid <= 1'b0;
  else if (rd_state == RD_BURST_LENGTH && rx_valid == 1'b1)
    arvalid <= 1'b1;
  else if (arvalid && arready)
    arvalid <= 1'b0;
  

logic                       ff_rd_write;
logic [DATA_WIDTH-1:0]      ff_rd_wdata;
logic                       ff_rd_read;
logic [DATA_WIDTH-1:0]      ff_rd_rdata;
logic                       ff_rd_full;
logic                       ff_rd_empty;
wire  [FW-1:0]              datacount_o_2;

efx_sc_fifo #(
.DEPTH             (FIFO_DEPTH   ),   
.DATA_WIDTH        (DATA_WIDTH   ),   
.FW                (FW           )
) 
rdata_fifo(
.almost_full_o  (               ),
.full_o         ( ff_rd_full    ),
.overflow_o     (               ),
.wr_ack_o       (               ),
.empty_o        ( ff_rd_empty   ),
.almost_empty_o (               ),
.underflow_o    (               ),
.rd_valid_o     (               ),
.rdata          ( ff_rd_rdata   ),
.clk_i          ( clk          ),
.wr_en_i        ( ff_rd_write   ),
.rd_en_i        ( ff_rd_read    ),
.a_rst_i        ( ~rst_n      ),
.wdata          ( ff_rd_wdata   ),
.datacount_o    ( datacount_o_2 ),
.rst_busy       (               )
);


assign rready = ~ff_rd_full;
assign ff_rd_write = rvalid && rready;
assign ff_rd_wdata = rdata;

logic [3:0] rd_cnt;
logic tx_data_valid;
logic tx_data_ready;
logic [7:0] tx_data;

assign tx_data_valid = ~ff_rd_empty;
assign ff_rd_read = tx_data_valid && tx_data_ready && rd_cnt==4'b1111;

always_ff@(posedge clk or negedge rst_n)
  if (!rst_n)
    tx_count <= 0;
  else if (ff_rd_read && tx_count==arlen)
    tx_count  <= 0;
  else if (ff_rd_read)
    tx_count <= tx_count + 1'b1;


assign tx_complete = ff_rd_read && tx_count==arlen;


always_ff@(posedge clk or negedge rst_n)
  if (!rst_n)
    rd_cnt <= 0;
  else if (tx_data_valid && tx_data_ready)
    rd_cnt <= rd_cnt + 1'b1;

always_comb begin 
  integer  i;
  tx_data = 8'h00;
  for (i=0;i<DATA_WIDTH/8;i++) begin 
    if (i==rd_cnt)
      tx_data = ff_rd_rdata[(DATA_WIDTH/8-1-i)*8+:8];
  end 
end 

 usart_tx #(
	.CLK_FRE(CLOCK_FRQ),      //clock frequency(Mhz)
	.BAUD_RATE(BADRATE)//serial baud rate
)usart_tx_U (
	.clk(clk),              //clock input
	.rst_n(rst_n),            //asynchronous reset input, low active 
	.tx_data( tx_data   ),          //data to send
	.tx_data_valid(  tx_data_valid),    //data to be sent is valid
	.tx_data_ready( tx_data_ready ),    //send ready
	.tx_pin   (uart_tx)         //serial data output
);




endmodule 