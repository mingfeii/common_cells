/*
1. need to check type after crc header

*/




module spi_packet_rx (
    input  logic        clk,            
    input  logic        rst_n,          
    input  logic [31:0] rx_data,        
    input  logic        rx_data_valid,

    input  logic        pkt_rx_enable,
    output logic [31:0] pkt_rx_addr,       
    output logic [31:0] pkt_rx_length,     
    output logic [31:0] pkt_rx_data,       
    output logic [15:0] pkt_rx_id,
    output logic [15:0] pkt_rx_type,

    output logic        pkt_rx_clear,

    output logic        header_crc_error, 
    output logic        data_crc_error, 

    output logic        pkt_rx_start,
    output logic        pkt_rx_end,
    output logic        pkt_rx_data_valid, 
    output logic        pkt_rx_data_last,
    output logic        pkt_rx_valid,
    output logic        error           
);

localparam SYNC_WORD     = 32'h55AA55AA; 
localparam WORD_SIZE     = 4;            
localparam TIMEOUT_LIMIT = 16'hFFFF; 

typedef enum logic [3:0] {
    WAIT_SYNC,
    RECV_ADDR,
    RECV_LEN,
    RECV_ID,
    RECV_HEADER_CRC,
    ST_CLEAR_PRE,
    ST_CLEAR,
    RECV_DATA,
    RECV_DATA_CRC,
    ERROR
} state_t;

state_t state, next_state;

logic [31:0] addr_reg;       
logic [31:0] length_reg;     
logic [31:0] data_cnt;       
logic [15:0] timeout_cnt;    
logic        timeout;        
logic [31:0] header_crc_reg; 
logic [31:0] data_crc_reg;   
logic [31:0] header_crc;     
logic [31:0] data_crc;       


logic [1:0] clear_cnt;


assign pkt_rx_clear = state == ST_CLEAR_PRE;



crc crc_header(
  .data_in(rx_data),
  .crc_en(rx_data_valid && (state == RECV_ID || state == RECV_ADDR || state == RECV_LEN )),
  .crc_out(header_crc),
  .rst(~rst_n || (state == WAIT_SYNC)),
  .clk(clk)
  );

crc crc_data(
  .data_in(rx_data),
  .crc_en(rx_data_valid && state == RECV_DATA),
  .crc_out(data_crc),
  .rst(~rst_n || (state == WAIT_SYNC || state == RECV_HEADER_CRC)),
  .clk(clk)
  );

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= WAIT_SYNC;
    else if (!pkt_rx_enable)
        state <= WAIT_SYNC; 
    else
        state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        WAIT_SYNC:
            if (rx_data_valid) begin
                if (rx_data == SYNC_WORD)
                    next_state = RECV_ADDR;
            end
        RECV_ADDR:
            if (rx_data_valid)
                next_state = RECV_LEN;
            else if (timeout)
                next_state = ERROR;
        RECV_LEN:
            if (rx_data_valid)
                next_state = RECV_ID;
            else if (timeout)
                next_state = ERROR;
        RECV_ID:
            if (rx_data_valid)
                next_state = RECV_HEADER_CRC;
            else if (timeout)
                next_state = ERROR;
        RECV_HEADER_CRC:
            if (rx_data_valid) begin
                if (header_crc == rx_data)
                    next_state = ST_CLEAR_PRE;
                else
                    next_state = ERROR;
            end else if (timeout)
                next_state = ERROR;

        ST_CLEAR_PRE : begin 
            next_state = ST_CLEAR;
        end 

        ST_CLEAR : begin 
            next_state = (length_reg == 32'd0 || pkt_rx_type[1:0] == 2'b01 || pkt_rx_type[1:0] == 2'b11) ? WAIT_SYNC :  RECV_DATA; //if read cmd , rerturn , read cmd no rxdata follow
        end 

        RECV_DATA:
            if (rx_data_valid && (data_cnt + WORD_SIZE >= length_reg))
                next_state = RECV_DATA_CRC;
            else if (timeout)
                next_state = ERROR;
        RECV_DATA_CRC:
            if (rx_data_valid)
                next_state = WAIT_SYNC;
            else if (timeout)
                next_state = ERROR;
        ERROR:
            next_state = WAIT_SYNC;
    endcase
end

assign data_crc_error = (state == RECV_DATA_CRC && rx_data_valid) && (data_crc != rx_data);

logic data_crc_error_reg;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pkt_rx_data_valid  <= 0;
        pkt_rx_data_last   <= 0;
        pkt_rx_valid       <= 0;
        pkt_rx_addr        <= 0;
        pkt_rx_length      <= 0;
        pkt_rx_data        <= 0;
        pkt_rx_id          <= 0;
        pkt_rx_type        <= 0;
        addr_reg           <= 0;
        length_reg         <= 0;
        data_cnt           <= 0;
        timeout_cnt        <= 0;
        timeout            <= 0;
        error              <= 0;
        header_crc_reg     <= 0;
        data_crc_reg       <= 0;
        header_crc_error   <= 0;
        data_crc_error_reg     <= 0;
    end else begin
        pkt_rx_data_valid <= 0;
        pkt_rx_data_last  <= 0;
        pkt_rx_valid      <= 0;
        error             <= 0;

        if (rx_data_valid || state == WAIT_SYNC) begin
            timeout_cnt <= 0;
            timeout     <= 0;
        end else if (state != WAIT_SYNC && state != ERROR) begin
            timeout_cnt <= timeout_cnt + 1;
            if (timeout_cnt >= TIMEOUT_LIMIT - 1)
                timeout <= 1;
        end

        if (state == RECV_HEADER_CRC && rx_data_valid)
            header_crc_error <= (header_crc != rx_data);
        else if (state == WAIT_SYNC)
            header_crc_error <= 0;

        if (state == RECV_DATA_CRC && rx_data_valid)
            data_crc_error_reg <= (data_crc != rx_data);
        else if (state == WAIT_SYNC)
            data_crc_error_reg <= 0;

        if (rx_data_valid) begin
            case (state)
                RECV_ADDR: begin
                    pkt_rx_addr <= rx_data;
                    addr_reg    <= rx_data;
                end
                RECV_LEN: begin
                    pkt_rx_length <= rx_data;
                    length_reg    <= rx_data;
                    data_cnt      <= 0;
                end
                RECV_ID: begin
                    pkt_rx_id   <= rx_data[15:0];
                    pkt_rx_type <= rx_data[31:16];
                end
                RECV_HEADER_CRC: begin
                    header_crc_reg <= rx_data;
                end
                RECV_DATA: begin
                    pkt_rx_data        <= rx_data;
                    pkt_rx_data_valid  <= 1;
                    data_cnt           <= data_cnt + WORD_SIZE;
                    pkt_rx_data_last   <= (data_cnt + WORD_SIZE >= length_reg);
                    pkt_rx_valid       <= (data_cnt + WORD_SIZE >= length_reg);
                end
                RECV_DATA_CRC: begin
                    data_crc_reg <= rx_data;
                end
            endcase
        end

        if (state == ERROR || header_crc_error || data_crc_error_reg)
            error <= 1;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pkt_rx_start <= 0;
    else if (!pkt_rx_enable)
        pkt_rx_start <= 0;
    else if (state == ST_CLEAR && next_state == WAIT_SYNC)
        pkt_rx_start <= 1;
    else if (state == ST_CLEAR && next_state == RECV_DATA)
        pkt_rx_start <= 1;
    else
        pkt_rx_start <= 0;
end 

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pkt_rx_end <= 0;
    else if (!pkt_rx_enable)
        pkt_rx_end <= 0;
    else if (state == RECV_DATA_CRC && next_state == WAIT_SYNC)
        pkt_rx_end <= 1;
    else if (state == RECV_HEADER_CRC && next_state == WAIT_SYNC)
        pkt_rx_end <= 1; // End of packet if no data
    // else if (state == ERROR)
    //     pkt_rx_end <= 1; // End of packet on error
    else
        pkt_rx_end <= 0;
end 

endmodule
