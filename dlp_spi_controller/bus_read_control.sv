/*

* merege data convert to read dma
* control data which sent to ack  
*/

module bus_read_control #(
    parameter BL = 4,
    parameter DW = 32

)(

input  logic        clk,            
input  logic        rst_n,          
input  logic        pkt_rx_clear,
//from spi_package_rx module
input logic [31:0] pkt_rx_addr,       
input logic [31:0] pkt_rx_length,     
input logic [31:0] pkt_rx_data,       
input logic [15:0] pkt_rx_id,
input logic [15:0] pkt_rx_type,
input logic        header_crc_error, 
input logic        data_crc_error, 
input logic        pkt_rx_start,

//output to dma 
output logic [BL:0] read_burstcount,
output logic [31:0] pio_d,
output logic [31:0] pio_d_len, // Length in bytes, must be aligned to 2**AL
output logic pio_adr_we,
output logic pio_len_we,
//read data from bus 
input  logic [DW-1:0] dma_d,
input  logic dma_val,
input  logic dma_eof,
output logic dma_rdy,
input  logic dma_done,
//output to ack logic 
output  logic [31:0] data_in,      
output  logic        data_in_valid,
input   logic        data_in_ready,
input   logic        ack_ready,   
output  logic        read_cmd_is,

input   logic        tx_data_end,
output  logic [31:0] tx_base_addr,    //also called status as in write ack, resue this word position
output  logic [31:0] tx_length,       
output  logic [15:0] tx_id,          
output  logic [15:0] tx_packet_type

);


localparam TYPE_WR_DDR = 16'h0000;
localparam TYPE_WR_REG = 16'h0002;
localparam TYPE_RD_DDR = 16'h0001;
localparam TYPE_RD_REG = 16'h0003;

//manin state control of read
typedef enum logic [2:0] {
    IDLE,
    HEADER_ERROR_ACK,
    WAIT_RD_PRE,
    WAIT_RD_LEN_PRE,
    WAIT_RD,
    LEN_ERROR_ACK
} state_t;

state_t state, next_state;


always @(posedge clk or negedge rst_n)
    if (!rst_n)
        state <= IDLE;
    else if (pkt_rx_clear)
        state <= IDLE;
    else 
        state <= next_state;

always_comb begin 
    next_state = state;
    case (state)
        IDLE : begin 
            if (pkt_rx_start) begin 

                if (pkt_rx_length == 0)
                    next_state = LEN_ERROR_ACK;
                else if (pkt_rx_type == TYPE_RD_DDR || pkt_rx_type == TYPE_RD_REG)
                    next_state = WAIT_RD_PRE;
            end 
            else if (header_crc_error)
                next_state =  HEADER_ERROR_ACK;
        end 

        HEADER_ERROR_ACK : begin 
            if (data_in_valid && ack_ready)
                next_state = IDLE;
        end 

        WAIT_RD_PRE: begin 
            next_state = WAIT_RD_LEN_PRE;
        end 

        WAIT_RD_LEN_PRE : begin 
            next_state = WAIT_RD;
        end
            

        WAIT_RD : begin 
            if (tx_data_end)
                next_state = IDLE;
        end  

    endcase 
end 

/***************** dma read  logic ************************/

//read_burstcount
always @(posedge clk or negedge rst_n)
    if (!rst_n)
        read_burstcount <= 8;
    else if (state == IDLE && pkt_rx_start && pkt_rx_type == TYPE_RD_REG)
        read_burstcount <= 1;
    else if (state == IDLE && pkt_rx_start && pkt_rx_type == TYPE_RD_DDR)
        read_burstcount <= 8;

//pio_d and pio_we , config write address 
always @(posedge clk or negedge rst_n)
    if (!rst_n) begin 
        pio_adr_we <= 0;
        pio_d <= 0;
    end else if (state == WAIT_RD_PRE) begin 
        pio_adr_we <= 1'b1;
        pio_d <= pkt_rx_addr;
    end else begin 
        pio_adr_we <= 1'b0;
        pio_d <= 0;
    end 

//start read command
always @(posedge clk or negedge rst_n)
    if (!rst_n) begin 
        pio_len_we <= 0;
        pio_d_len <= 0;
    end else if (state == WAIT_RD_LEN_PRE) begin 
        pio_len_we <= 1'b1;
        pio_d_len <= pkt_rx_length;
    end else begin 
        pio_len_we <= 0;
        pio_d_len <= 0;
    end 


/***************** read responce logic ************************/


assign tx_base_addr = state == LEN_ERROR_ACK ? 16'h0003 : state == HEADER_ERROR_ACK ? 16'h0001 : 16'h0000;

assign tx_length = state == WAIT_RD ? pkt_rx_length : 0;

assign tx_id = (state == HEADER_ERROR_ACK || state == WAIT_RD) ? pkt_rx_id : 0;

assign data_in_valid = (dma_val && (state == WAIT_RD)) | (state == HEADER_ERROR_ACK);

assign dma_rdy = data_in_ready;

assign data_in = dma_d;

assign tx_packet_type = 16'h04;

assign read_cmd_is = state == WAIT_RD;


endmodule 