/*

* SCLKCPOL=0 is a clock which idles at the logical low voltage.
* SCLKCPOL=1 is a clock which idles at the logical high voltage.

CPHA represents the phase of each data bit's transmission cycle relative to SCLK
For CPHA=0:
    * The first data bit is output immediately when SS activates.
    * Subsequent bits are output when SCLK transitions to its idle voltage level.
    * Sampling occurs when SCLK transitions from its idle voltage level.
For CPHA=1:
    * The first data bit is output on SCLK's first clock edge after SS activates.
    * Subsequent bits are output when SCLK transitions from its idle voltage level.
    * Sampling occurs when SCLK transitions to its idle voltage level.


SPI mode	Clock polarity(CPOL)	Clock phase(CPHA)	Data is shifted out on	                    Data is sampled on
0	        0	                    0	                falling SCLK, and when SS activates	        rising SCLK
1	        0	                    1	                rising SCLK	                                falling SCLK
2	        1	                    0	                rising SCLK, and when SS activates	        falling SCLK
3	        1	                    1	                falling SCLK	                            rising SCLK


// CPOL: Clock Polarity
// CPOL=0 means clock idles at 0, leading edge is rising edge.
// CPOL=1 means clock idles at 1, leading edge is falling edge.

// CPHA: Clock Phase
// CPHA=0 means the "out" side changes the data on trailing edge of clock
//              the "in" side captures data on leading edge of clock
// CPHA=1 means the "out" side changes the data on leading edge of clock
//              the "in" side captures data on the trailing edge of clock

*/
module spi_master (
    input  logic        sys_clk,
    input  logic        sys_rst_n,

    // SPI interface
    input  logic        miso,
    output logic        mosi,
    output logic        sclk,
    output logic        cs_n,

    // Control interface
    input  logic [31:0] control,        // control[4]=CPHA, control[3]=CPOL
    input  logic        tx_data_valid,
    output logic        tx_data_ready,
    input  logic [31:0] tx_data,
    output logic [31:0] rx_data_o,
    output logic        rx_data_valid_o
);

// -----------------------------
// Control decoding
// -----------------------------
logic       CPHA, CPOL;
logic [2:0] half_clk_div; // 半个spi周期的分频系数，例如如果是2，那么一个spi_clk就是4个sys_clk周期
logic [4:0] bit_length;
logic [3:0] full_clk_div; // 一个spi周期的分频系数
logic [6:0] max_clk_edges;

assign CPHA        = control[3];
assign CPOL        = control[4];
assign half_clk_div      = control[2:0] == 0 ? 1 : control[2:0]; // 最小分频系数为1
assign bit_length  = (control[15:11] > 31) ? 31 : control[15:11] == 0 ? 7 : control[15:11]; // bit_length is 0-31, default to 8 bits

// CSN control logic
logic [2:0] csn_hold_delay;     // configurable delay after last rx_data_valid
logic [15:0] burst_len;          // how many spi tx_data per burst
logic [15:0] burst_index;
logic       in_burst;
logic [2:0] csn_hold_cnt;

assign csn_hold_delay = control[10:8];   // e.g. 3 => cs_n 延迟 3 个 sys_clk
assign burst_len      = control[31:16];    // e.g. 4 => 每个 burst 发送 4 包

assign max_clk_edges = (bit_length + 1) * 2; 

logic leading_edge;
logic trailing_edge;
logic [6:0] spi_clk_edges; //max 64 edges, enough for 32 bits
logic [4:0] tx_bit_count,rx_bit_count;
logic spi_clk_r;
logic [3:0] spi_clk_count; // 4 bits is enough for 16 clk div

logic [31:0] tx_data_1r;

logic internal_spi_ready;

localparam DW = 32; // Data width
localparam FW = 10;  // FIFO width   

logic fifo_wnf; // FIFO is not full, can write data
logic fifo_rne; // FIFO is not empty, can read data
logic [DW-1:0] fifo_rd; // FIFO read data
logic [FW:0] fifo_wcnt; // FIFO write count
logic fifo_rreq; // FIFO read request

assign tx_data_ready = fifo_wnf; // FIFO is not full, can write data

xlib_xyz_fifo #(
    .DW(DW),
    .FW(FW),
    .SYNC_RST(0)
) fifo_sys_inst (
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .wrdy(fifo_wnf), // FIFO is not full, can write data
    .wval(tx_data_valid),
    .wd(m_byte_swap32(tx_data)),
    .rrdy(fifo_rreq),
    .rval(fifo_rne),
    .rd(fifo_rd),
    .cnt(fifo_wcnt)
);


wire tx_ack = fifo_rreq;
logic tx_ack_1r;


always_comb begin
    full_clk_div = half_clk_div << 1;
end

always_ff@(posedge sys_clk or negedge sys_rst_n)
if (!sys_rst_n)begin 
    internal_spi_ready <= 1'b0;
    spi_clk_edges <= 'd0;
    leading_edge <= 1'b0;
    trailing_edge <= 1'b0;
    spi_clk_r <= 0;
    spi_clk_count <= '0;
end 
else begin 
        leading_edge <= 1'b0;
        trailing_edge <= 1'b0;
        if (tx_ack)begin 
            internal_spi_ready <= 1'b0;
            spi_clk_edges <= max_clk_edges;
        end  else if (spi_clk_edges > 0 && ~cs_n)begin 
                internal_spi_ready <= 1'b0;
                if (spi_clk_count == full_clk_div - 1)begin 
                    spi_clk_edges <= spi_clk_edges - 1;
                    trailing_edge <= 1'b1;
                    spi_clk_count <= 0;
                    spi_clk_r <= ~spi_clk_r;
                end 
                else if (spi_clk_count == half_clk_div - 1)begin 
                    spi_clk_edges <= spi_clk_edges - 1;
                    leading_edge <= 1'b1;
                    spi_clk_count <= spi_clk_count + 1;
                    spi_clk_r <= ~spi_clk_r;
                end 
                else  begin 
                    spi_clk_count <= spi_clk_count + 1;
                end 
            end 
        else  
        internal_spi_ready <= 1'b1;
    end 


logic trans_update;

assign trans_update = spi_clk_edges == 0 && (trailing_edge || leading_edge);



typedef enum logic [1:0] {
    IDLE,       
    CHECK_PKG_CNT,
    DELAY_CSN
    
} state_t;

state_t state, next_state;


always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        state <= IDLE;
    else
        state <= next_state;


always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        burst_index <= 0;
    else if (cs_n)
        burst_index <= 0; // Reset burst index when CS is low
    else if (trans_update)
        burst_index <= burst_index + 1; // Increment burst index on each SPI clock edge


always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (trans_update) begin
                next_state = CHECK_PKG_CNT;
            end
        end

        CHECK_PKG_CNT: begin
            if ((burst_index == burst_len)) begin
                next_state = DELAY_CSN;
            end
        end 

        DELAY_CSN: begin
            if (csn_hold_cnt == csn_hold_delay) begin
                next_state = IDLE;
            end
        end

        default: next_state = IDLE;
    endcase 
end 

assign fifo_rreq = (internal_spi_ready  && !(trans_update || (state == CHECK_PKG_CNT && (burst_index == burst_len)) || (state == DELAY_CSN))) && fifo_rne; // FIFO read request when SPI is ready and CS is low


//csn_hold_cnt
always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        csn_hold_cnt <= 0; 
    else if (state == DELAY_CSN) begin
        if (csn_hold_cnt == csn_hold_delay)
            csn_hold_cnt <= 0;
        else 
            csn_hold_cnt <= csn_hold_cnt + 1; // Increment counter in delay state
    end else begin
        csn_hold_cnt <= 0; // Reset counter when not in delay state
    end


//cs_n
always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        cs_n <= 1'b1; // Active high, idle state is high
    else if (tx_ack && (state == IDLE)) begin
        cs_n <= 1'b0; // Assert CS when in IDLE state
    end else if (state == CHECK_PKG_CNT && next_state == DELAY_CSN) begin
        cs_n <= 1'b1; // Deassert CS in DELAY_CSN state
    end

 always_ff@(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        sclk <= 0;
    else sclk <= spi_clk_r ? ~CPOL : CPOL; // CPOL=0 means sclk is low when idle, CPOL=1 means sclk is high when idle

always_ff@(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)begin 
        tx_ack_1r <= 1'b0;
        tx_data_1r <= '0;
    end else begin 
        tx_ack_1r <= tx_ack;
        if (tx_ack)
            tx_data_1r <= fifo_rd;
    end 

// MOSI
always_ff @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n) begin
        mosi <= 1'b0;
        tx_bit_count <= 5'd0;
    end else begin
        if (internal_spi_ready) begin
            tx_bit_count <= bit_length;
        end
        else if (tx_ack_1r && ~CPHA) begin // CPHA=0
            mosi <= tx_data_1r[bit_length];
            tx_bit_count <= bit_length - 1;
        end
        else if ((leading_edge && CPHA) || (trailing_edge && ~CPHA)) begin
            mosi <= tx_data_1r[tx_bit_count];
            tx_bit_count <= tx_bit_count - 1;
        end
    end

logic [31:0] rx_data;
logic rx_data_valid;
//MISO
always_ff @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n) begin
        rx_data <= '0;
        rx_data_valid <= 1'b0;
        rx_bit_count <= 5'd0;
    end else begin
        rx_data_valid <= 1'b0;

        if (internal_spi_ready) begin
            rx_bit_count <= bit_length;
        end
        else if ((leading_edge && ~CPHA) || (trailing_edge && CPHA)) begin
            rx_data[rx_bit_count] <= miso;
            if (rx_bit_count == 0)
                rx_data_valid <= 1'b1;
            rx_bit_count <= rx_bit_count - 1;
        end
    end


// assign rx_data_o = m_byte_swap32(rx_data);

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        rx_data_valid_o <= 1'b0;
    else 
        rx_data_valid_o <= rx_data_valid;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        rx_data_o <= 'b0;
    else 
        rx_data_o <= m_byte_swap32(rx_data);



function reg [31:0] m_byte_swap32;
    input [31:0] din;
    begin
        m_byte_swap32 = {din[7:0], din[15:8], din[23:16], din[31:24]};
    end
endfunction



endmodule
