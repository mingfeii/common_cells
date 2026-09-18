/*

Tx data source from two ways : 
1. from ack package but no data append in the end of package 
2. from ack plus read data from reg or DDR

*/
module spi_packet_tx (
    input  logic        clk,          
    input  logic        rst_n,        
    input  logic        pkt_rx_clear,
    input  logic [31:0] data_in,      
    input  logic        data_in_valid,
    output logic        data_in_ready,
    output logic        ack_ready,
    input  logic        read_cmd_is, //正在进行读操作，读命令已经校验通过
    input  logic        sim_wr,
    input  logic        bypass_syncword, // bypass sync word for test
    
    input  logic [31:0] tx_base_addr,    
    input  logic [31:0] tx_length,       
    input  logic [15:0] tx_id,          
    input  logic [15:0] tx_packet_type,
    input  logic        tx_enable,
    output logic [31:0] tx_data,      
    output logic        tx_data_valid,
    input  logic        tx_data_ready,
    output logic        tx_data_end,
    output logic        sending,      
    output logic        error         
);

localparam SYNC_WORD = 32'h55AA55AA; 
localparam TIMEOUT_LIMIT = 16'hFFFF; 
localparam WORD_SIZE = 4;            

typedef enum logic [3:0] {
    IDLE,       
    SYNC,       
    SEND_ADDR,  
    SEND_LEN,   
    SEND_ID,
    SEND_HEADER_CRC, 
    SEND_DATA,  
    SEND_DATA_CRC, 
    ERROR       
} state_t;

state_t state, next_state;

logic [31:0] data_cnt;       
logic [31:0] word_cnt;       
logic [31:0] tx_data_r;      
logic        tx_data_valid_r;
logic [15:0] timeout_cnt;    
logic        timeout;        
logic        length_error;   

logic [31:0] header_crc;     
logic [31:0] data_crc;       


logic [31:0] tx_base_addr_reg;    
logic [31:0] tx_length_reg;       
logic [15:0] tx_id_reg;          
logic [15:0] tx_packet_type_reg;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_base_addr_reg <= '0;
        tx_length_reg <= '0;
        tx_id_reg <= '0;
        tx_packet_type_reg <= '0;
    end else if (state == IDLE && data_in_valid && ack_ready) begin
        tx_base_addr_reg <= tx_base_addr;
        tx_length_reg <= tx_length;
        tx_id_reg <= tx_id;
        tx_packet_type_reg <= tx_packet_type;
    end
end




crc crc_header(
  .data_in(tx_data_r),
  .crc_en(tx_data_valid_r && tx_data_ready && (state == SEND_ADDR || state == SEND_LEN || state == SEND_ID)),
  .crc_out(header_crc),
  .rst(~rst_n || (state == IDLE)),
  .clk(clk)
  );


crc crc_data(
  .data_in(tx_data_r),
  .crc_en(tx_data_valid_r && tx_data_ready && state == SEND_DATA),
  .crc_out(data_crc),
  .rst(~rst_n || !(state == SEND_DATA || state == SEND_DATA_CRC)),
  .clk(clk)
  );



assign word_cnt = tx_length >> 2;
assign length_error = (tx_length == '0) || (tx_length[1:0] != 2'b00);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else if (!tx_enable)
        state <= IDLE;
    else if (pkt_rx_clear)
        state <= IDLE;
    else
        state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        IDLE:
            if (data_in_valid && ack_ready)
                next_state = SYNC;
        SYNC:
            if (tx_data_valid_r && tx_data_ready)
                next_state = SEND_ADDR;
        SEND_ADDR:
            if (tx_data_valid_r && tx_data_ready)
                next_state = SEND_LEN;
        SEND_LEN:
            if (tx_data_valid_r && tx_data_ready)
                next_state = SEND_ID;
        SEND_ID:
            if (tx_data_valid_r && tx_data_ready)
                next_state = SEND_HEADER_CRC;
        SEND_HEADER_CRC:
            if (tx_data_valid_r && tx_data_ready)
                // next_state = (word_cnt == 0) ? SEND_DATA_CRC : SEND_DATA;
                next_state = (tx_base_addr_reg == 16'h00 && read_cmd_is ) || sim_wr ? SEND_DATA : IDLE;
        SEND_DATA:
            if (tx_data_valid_r && tx_data_ready && data_cnt >= word_cnt - 1)
                next_state = SEND_DATA_CRC;
            else if (length_error)
                next_state = ERROR;
        SEND_DATA_CRC:
            if (tx_data_valid_r && tx_data_ready)
                next_state = IDLE;
        ERROR:
            next_state = IDLE;
    endcase
end

always_comb begin 
    tx_data_valid_r = '0;
    tx_data_r       = '0;
    case (state)
        SYNC: begin
            tx_data_r       = bypass_syncword ? '0 : SYNC_WORD;
            tx_data_valid_r = '1;
        end
        SEND_ADDR: begin
            tx_data_r       = tx_base_addr_reg;
            tx_data_valid_r = '1;
        end
        SEND_LEN: begin
            tx_data_r       = tx_length_reg;
            tx_data_valid_r = '1;
        end
        SEND_ID: begin
            tx_data_r       = {tx_packet_type_reg, tx_id_reg};
            tx_data_valid_r = '1;
        end
        SEND_HEADER_CRC: begin
            tx_data_r       = header_crc;
            tx_data_valid_r = '1;
        end
        SEND_DATA: begin
            if (data_in_valid) begin
                tx_data_r       = data_in;
                tx_data_valid_r = '1;
            end
        end
        SEND_DATA_CRC: begin
            tx_data_r       = data_crc;
            tx_data_valid_r = '1;
        end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_cnt <= '0;
    else if (state == IDLE || state == SYNC || state == SEND_ADDR || state == SEND_LEN || state == SEND_ID || state == SEND_HEADER_CRC)
        data_cnt <= '0;
    else if (state == SEND_DATA && tx_data_valid_r && tx_data_ready)
        data_cnt <= data_cnt + 1;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        timeout_cnt <= '0;
    else if (state == IDLE || (tx_data_valid_r && tx_data_ready))
        timeout_cnt <= '0;
    else if (state != IDLE && state != ERROR)
        timeout_cnt <= timeout_cnt + 1;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        timeout <= '0;
    else if (state == IDLE || (tx_data_valid_r && tx_data_ready))
        timeout <= '0;
    else if (timeout_cnt >= TIMEOUT_LIMIT - 1)
        timeout <= '1;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        tx_data_end <= '0;
    else if (state == SEND_DATA_CRC && tx_data_valid_r && tx_data_ready)
        tx_data_end <= '1;
    else
        tx_data_end <= '0;
end

assign error = (state == ERROR) || length_error;
assign tx_data = tx_data_r;
assign tx_data_valid = tx_data_valid_r;
assign data_in_ready = (state == SEND_DATA) && tx_data_ready;
assign sending = (state != IDLE);
assign ack_ready = (state == IDLE);

endmodule
