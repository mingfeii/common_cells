/*

* merege data convert to write dma
* control data which sent to ack  
* consider add ack_ready for padding  read and write ack , read ack is priority : what is tx2 read long data while write to DMA
ack may not be guarteen
*/

module bus_write_control #(
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
input logic        pkt_rx_end,
input logic        pkt_rx_data_valid, 
input logic        pkt_rx_data_last,
//output to dma 
output logic [BL:0] write_burstcount,
output logic [31:0] pio_d,
output logic pio_adr_we,
output logic [DW-1:0] dma_d,
output logic dma_val,
output logic dma_eof,
input  logic dma_rdy,
input  logic dma_done,
//output to ack logic 
output  logic [31:0] data_in,      //not use for resp ack 
output  logic        data_in_valid,
input   logic        data_in_ready, //not use for resp ack 
input   logic        ack_ready, 

output  logic [31:0] tx_base_addr,    //also called status as in write ack, resue this word position
output  logic [31:0] tx_length,       
output  logic [15:0] tx_id,          
output  logic [15:0] tx_packet_type

//for notice tx module state machine if resp package

);

localparam TYPE_WR_DDR = 16'h0000;
localparam TYPE_WR_REG = 16'h0002;
localparam TYPE_RD_DDR = 16'h0001;
localparam TYPE_RD_REG = 16'h0003;

//manin state control of dma write 
typedef enum logic [3:0] {
    IDLE,
    HEADER_ERROR_ACK,
    WAIT_WR_DDR_PRE,
    WAIT_WR_DDR,
    WAIT_WR_REG_PRE,
    WAIT_WR_REG,
    DATA_ERROR_ACK,
    LEN_ERROR_ACK,
    WR_ACK_OK
} state_t;

state_t state, next_state;

logic [2:0] padding_cnt; // burst is aligned with 8 * 8 = 64 bytes 
logic pkt_rx_valid_1;

assign pkt_rx_valid_1 = (state == WAIT_WR_DDR) && pkt_rx_data_valid;

//dam padding logic 
typedef enum logic [2:0] {
    PADD_IDLE,
    PADD_SYNC_DMA,
    DMA_PADDING,
    PADD_DONE
} padd_state_t;

padd_state_t padd_state, padd_next_state;

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        padd_state <= PADD_IDLE;
    else if (pkt_rx_clear)
        padd_state <= PADD_IDLE;
    else 
        padd_state <= padd_next_state;

always_comb begin 
     padd_next_state = padd_state;
     case (padd_state)
        PADD_IDLE : begin 
            if (state == IDLE && next_state == WAIT_WR_DDR_PRE)
                padd_next_state = PADD_SYNC_DMA;
        end 

        PADD_SYNC_DMA : begin 
            if (pkt_rx_data_last) begin 
                if (padding_cnt == 3'd7)
                    padd_next_state = PADD_DONE;
                else 
                    padd_next_state = DMA_PADDING;
            end 
        end 
        DMA_PADDING : begin 
            if (padding_cnt == 3'd7)
                padd_next_state = PADD_DONE;
        end 
        PADD_DONE : begin 
            padd_next_state = PADD_IDLE;
        end 
     endcase 
end 

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        padding_cnt <= 0;
    else if ((pkt_rx_valid_1) ||  padd_state == DMA_PADDING) begin 
            padding_cnt <= padding_cnt + 1'b1;
    end else if (padd_state == PADD_IDLE)
        padding_cnt <= 0;


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
                    next_state = LEN_ERROR_ACK; //length error
                else if (pkt_rx_type == TYPE_WR_DDR)
                    next_state = WAIT_WR_DDR_PRE;
                else if (pkt_rx_type == TYPE_WR_REG)
                    next_state = WAIT_WR_REG_PRE;
            end 
            else if (header_crc_error)
                next_state =  HEADER_ERROR_ACK;
        end 

        HEADER_ERROR_ACK : begin 
            if (data_in_valid && ack_ready)
                next_state = IDLE;
        end 

        LEN_ERROR_ACK : begin 
            if (data_in_valid && ack_ready)
                next_state = IDLE;
        end
        
        WAIT_WR_DDR_PRE: begin 
            next_state = WAIT_WR_DDR;
        end 

        WAIT_WR_DDR : begin 
            if (dma_done)
                next_state = WR_ACK_OK;
            else if (data_crc_error)
                next_state = DATA_ERROR_ACK;
        end 

        WAIT_WR_REG_PRE : begin 
            if (data_crc_error)
                next_state = DATA_ERROR_ACK;
            else if (pkt_rx_end) //delay one cycle after data_crc_error
                next_state = WAIT_WR_REG;
        end 

        WAIT_WR_REG : begin 
            if (dma_done)
                next_state = WR_ACK_OK;
        end 
        DATA_ERROR_ACK : begin 
            if (data_in_valid && ack_ready)
            next_state = IDLE;
        end 

        WR_ACK_OK : begin 
            if (data_in_valid && ack_ready)
                next_state = IDLE;
        end 
    endcase 
end 

//write_burstcount
always @(posedge clk or negedge rst_n)
    if (!rst_n)
        write_burstcount <= 8;
    else if (state == IDLE && pkt_rx_start && pkt_rx_type == TYPE_WR_REG)
        write_burstcount <= 1;
    else if (state == IDLE && pkt_rx_start && pkt_rx_type == TYPE_WR_DDR)
        write_burstcount <= 8;

//pio_d and pio_we , config write address 
always @(posedge clk or negedge rst_n)
    if (!rst_n) begin 
        pio_adr_we <= 0;
        pio_d <= 0;
    end else if ((state == IDLE) && (next_state == WAIT_WR_DDR_PRE || next_state == WAIT_WR_REG_PRE)) begin 
        pio_adr_we <= 1'b1;
        pio_d <= pkt_rx_addr;
    end else begin 
        pio_adr_we <= 1'b0;
        pio_d <= 0;
    end 

/***************** dma w  logic ************************/
//dma w signals for burst ddr trans 
logic dma_val_burst;
logic dma_eof_burst;
logic dma_eof_burst_aligned;
logic [31:0] dma_d_burst;

assign dma_val_burst = (pkt_rx_valid_1 || (padd_state == DMA_PADDING)) && (state ==  WAIT_WR_DDR);
assign dma_d_burst = padd_state == DMA_PADDING ? 0 : pkt_rx_data;
assign dma_eof_burst_aligned = (padd_state == PADD_SYNC_DMA && pkt_rx_data_last && padding_cnt == 3'd7);
assign dma_eof_burst = dma_eof_burst_aligned | (padd_state == DMA_PADDING && padding_cnt == 3'd7);

//dma w signals for reg write 
logic dma_val_reg;
logic [31:0] dma_d_reg;
logic dma_eof_reg;

always @(posedge clk or negedge  rst_n)
    if (!rst_n)
        dma_d_reg <= 0;
    else if (state == WAIT_WR_REG_PRE && pkt_rx_data_last)
        dma_d_reg <= pkt_rx_data;
    else if (state == IDLE)
        dma_d_reg <= 0;

assign dma_val_reg = (state == WAIT_WR_REG_PRE && next_state == WAIT_WR_REG);
assign dma_eof_reg = (state == WAIT_WR_REG_PRE && next_state == WAIT_WR_REG);

//merge all dma signals 
assign dma_val = dma_val_burst | dma_val_reg;
assign dma_eof = dma_eof_burst | dma_eof_reg;
assign dma_d = dma_d_burst | dma_d_reg;


/***************** responce logic ************************/
  
logic [15:0] tx_id_reg;          

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_id_reg <= '0;
    end else if (pkt_rx_start || header_crc_error) begin
        tx_id_reg <= pkt_rx_id;
    end
end

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        tx_base_addr <= 0;
    else if (state == HEADER_ERROR_ACK)
        tx_base_addr <= 16'h0001; //header crc error;
    else if (state == DATA_ERROR_ACK)
        tx_base_addr <= 16'h0002; //header crc error;
    else if (state == WR_ACK_OK)
        tx_base_addr <= 16'h0000; //header crc error;
    else if (state == LEN_ERROR_ACK)
        tx_base_addr <= 16'h0003; //length error;
    else 
        tx_base_addr <= 0; //reset addr when idle

assign tx_length = 0;

always @(posedge clk or negedge rst_n) 
    if (!rst_n)
        tx_id <= 0;
    else if (state == HEADER_ERROR_ACK || state == DATA_ERROR_ACK || state == WR_ACK_OK || state == LEN_ERROR_ACK)
        tx_id <= tx_id_reg;
    else 
        tx_id <= 0; //reset id when idle

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        data_in_valid <= 0;
    else 
        data_in_valid <= (state == HEADER_ERROR_ACK || state == DATA_ERROR_ACK || state == WR_ACK_OK || state == LEN_ERROR_ACK);

always @(posedge clk or negedge rst_n)
    if (!rst_n)
        tx_packet_type <= 0;
    else if (state == HEADER_ERROR_ACK || state == DATA_ERROR_ACK || state == WR_ACK_OK || state == LEN_ERROR_ACK)
        tx_packet_type <= 16'h04;
    else 
        tx_packet_type <= 0; //reset type when idle


//add a fifo save ack


endmodule 