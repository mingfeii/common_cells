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

/*

在连续传输中，包间必须停顿(cs_n拉起或者停顿sclk)，以使得同步信号同步到系统时钟域，
从而能及时取数据发送到miso上。


*/

module spi_slave (
    input  logic        sys_clk,
    input  logic        sys_rst_n,

    // SPI interface
    input  logic        mosi,
    output logic        miso,
    input  logic        sclk,
    input  logic        cs_n,

    // Control interface
    input  logic [31:0] control,        // control[4]=CPHA, control[3]=CPOL
    input  logic        tx_data_valid,
    output logic        tx_data_ready,
    output logic        tx_error,
    output logic        tx_done_pulse,
    input  logic [31:0] tx_data,
    output logic [31:0] rx_data,
    output logic        rx_data_valid
);

// -----------------------------
// Control decoding
// -----------------------------
logic       CPHA, CPOL;
logic [4:0] bit_length;
logic [1:0] SPI_MODE; // SPI mode 0-3
assign CPHA        = control[3];
assign CPOL        = control[4];
assign bit_length  = (control[15:11] > 31) ? 31 : control[15:11] == 0 ? 7 : control[15:11]; // bit_length is 0-31, default to 8 bits
assign SPI_MODE    = {CPOL, CPHA}; // SPI mode 0-3

logic [31:0] rx_shift_data_pos_sclk;
logic [31:0] rx_shift_data_pos_sclk_tmp;
logic [4:0] rx_data_count_pos_sclk;
logic rx_done_pos_sclk;

// --------------------------- SPI 从机接收部分 ---------------------------
// MOSI在SCLK上升沿采样（CPOL=0&CPHA=0 或 CPOL=1&CPHA=1）
always @(posedge sclk or negedge sys_rst_n) 
    if (!sys_rst_n) begin 
        rx_shift_data_pos_sclk <= 'd0;
        rx_done_pos_sclk <= 1'b0;
    end else if ((SPI_MODE == 0 || SPI_MODE == 3) && !cs_n) begin
        if (rx_data_count_pos_sclk == bit_length) begin 
                rx_done_pos_sclk <= 1'b1;
                rx_shift_data_pos_sclk <= {rx_shift_data_pos_sclk_tmp[31-1:0],mosi};
        end  else if (rx_data_count_pos_sclk == 'd3) begin// 把done信号延迟拉低，方便系统时钟采样
                rx_done_pos_sclk <= 1'b0;
                rx_shift_data_pos_sclk <= 0;
        end 
   end 

always @(posedge sclk or posedge cs_n)
    if (cs_n) begin 
        rx_data_count_pos_sclk <= 0;
        rx_shift_data_pos_sclk_tmp <= '0;
    end  else if (SPI_MODE == 0 || SPI_MODE == 3) begin 
        if (rx_data_count_pos_sclk == bit_length) begin 
                rx_data_count_pos_sclk <= 0;
        end else begin 
            rx_data_count_pos_sclk <= rx_data_count_pos_sclk + 1;
            rx_shift_data_pos_sclk_tmp <= {rx_shift_data_pos_sclk_tmp[31-1:0],mosi};
        end 
    end 

// MOSI在SCLK下降沿采样（CPOL=1&CPHA=0 或 CPOL=0&CPHA=1）
logic [31:0] rx_shift_data_neg_sclk;
logic [31:0] rx_shift_data_neg_sclk_tmp;
logic [4:0] rx_data_count_neg_sclk;
logic rx_done_neg_sclk;

// MOSI在SCLK上升沿采样（CPOL=0&CPHA=0 或 CPOL=1&CPHA=1）
always @(negedge sclk or negedge sys_rst_n) 
    if (!sys_rst_n) begin 
        rx_shift_data_neg_sclk <= 'd0;
        rx_done_neg_sclk <= 1'b0;
    end else if ((SPI_MODE == 1 || SPI_MODE == 2) && !cs_n) begin
        if (rx_data_count_neg_sclk == bit_length) begin 
                rx_done_neg_sclk <= 1'b1;
                rx_shift_data_neg_sclk <= {rx_shift_data_neg_sclk_tmp[31-1:0],mosi};
        end  else if (rx_data_count_neg_sclk == 'd3) begin// 把done信号延迟拉低，方便系统时钟采样
                rx_done_neg_sclk <= 1'b0;
                rx_shift_data_neg_sclk <= 0;
        end 
   end 

always @(negedge sclk or posedge cs_n)
    if (cs_n) begin 
        rx_data_count_neg_sclk <= 0;
        rx_shift_data_neg_sclk_tmp <= '0;
    end else if (SPI_MODE == 1 || SPI_MODE == 2) begin 
        if (rx_data_count_neg_sclk == bit_length) begin 
                rx_data_count_neg_sclk <= 0;
        end else begin 
            rx_data_count_neg_sclk <= rx_data_count_neg_sclk + 1;
            rx_shift_data_neg_sclk_tmp <= {rx_shift_data_neg_sclk_tmp[31-1:0],mosi};
        end 
    end 

logic rx_done_reg1;
logic rx_done_reg2;
logic rx_done_reg3;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n) begin 
        rx_done_reg1 <= 1'b0;
        rx_done_reg2 <= 1'b0;
        rx_done_reg3 <= 1'b0;
    end else begin 
        if (SPI_MODE == 0 || SPI_MODE == 3) begin 
            rx_done_reg1 <= rx_done_pos_sclk;
        end else begin 
            rx_done_reg1 <= rx_done_neg_sclk;
        end 
        rx_done_reg2 <= rx_done_reg1;
        rx_done_reg3 <= rx_done_reg2;
    end 

assign rx_data_valid = rx_done_reg2 & ~rx_done_reg3;
assign rx_data = (SPI_MODE == 0 || SPI_MODE == 3) ? byte_swap32(rx_shift_data_pos_sclk) : byte_swap32(rx_shift_data_neg_sclk);

//TX MISO side 
logic miso_01 , miso_11;
logic [31:0] txdata_reg;
logic [4:0] tx_data_count_neg_sclk;
logic [4:0] tx_data_count_pos_sclk;
logic tx_done_neg;
logic tx_done_pos;

localparam DW = 32;
localparam FW = 8; 
logic fifo_wne, fifo_wnf;
logic [FW:0] fifo_wcnt;   
logic [DW-1:0] fifo_rd;
logic fifo_rne, fifo_rnf;
logic [FW:0] fifo_rcnt; 
logic spi_fifo_rreq;

// CPOL=0&CPHA=0时的MISO输出（数据在SCLK上升沿前准备）
// always_comb 
//     miso_00 = txdata_reg[bit_length - tx_data_count_neg_sclk];


// always @(negedge sclk or posedge cs_n)
//     if (cs_n)
//         miso_00 <= 1'b1;
//     else 
//         miso_00 <= txdata_reg[bit_length - tx_data_count_neg_sclk - 1];

// // CPOL=1&CPHA=0时的MISO输出（数据在SCLK下降沿前准备）
// // always_comb 
// //     miso_10 = txdata_reg[bit_length - tx_data_count_pos_sclk];

// always @(posedge sclk or posedge cs_n)
//     if (cs_n)
//         miso_10 <= 1'b1;
//     else 
//         miso_10 <= txdata_reg[bit_length - tx_data_count_pos_sclk - 1];


// CPOL=0&CPHA=1时的MISO输出（数据在SCLK上升沿时更新）
always @(posedge sclk or posedge cs_n)
    if (cs_n)
        miso_01 <= 1'b1;
    else 
        miso_01 <= txdata_reg[bit_length - tx_data_count_pos_sclk];

// CPOL=1&CPHA=1时的MISO输出（数据在SCLK下降沿时更新）
// always @(negedge sclk or posedge cs_n)
//     if (cs_n)
//         miso_11 <= 1'b0;
//     else 
//         miso_11 <= txdata_reg[bit_length - tx_data_count_neg_sclk];

wire [4:0] tx_index;

assign tx_index = rx_data_count_pos_sclk == 5'd31 ? 5'd31 : bit_length - 1 - rx_data_count_pos_sclk;

always @(posedge sclk or posedge cs_n)
    if (cs_n)
        miso_11 <= 1'b0;
    else 
        miso_11 <= txdata_reg[tx_index];

//tx_data_count_neg_sclk 发送计数（SCLK下降沿计数，适用于CPOL=0&CPHA=0和CPOL=1&CPHA=1）
always @(negedge sclk or posedge cs_n)
    if (cs_n) begin 
        tx_data_count_neg_sclk <= 0;
    end else if (tx_data_count_neg_sclk == bit_length) begin 
        tx_data_count_neg_sclk <= 0;
    end else begin 
        tx_data_count_neg_sclk <= tx_data_count_neg_sclk + 1;
    end 
        
always @(negedge sclk or negedge sys_rst_n) 
    if (!sys_rst_n) begin 
        tx_done_neg <= 1'b0;
    end else if (tx_data_count_neg_sclk == bit_length) begin 
        tx_done_neg <= 1'b1;
    end  else if (tx_data_count_neg_sclk == 'd3) begin// 把done信号延迟拉低，方便系统时钟采样
        tx_done_neg <= 1'b0;
    end 

// 发送计数（SCLK上升沿计数，适用于CPOL=1&CPHA=0和CPOL=0&CPHA=1）
always @(posedge sclk or posedge cs_n)
    if (cs_n) begin 
        tx_data_count_pos_sclk <= 0;
    end else if (tx_data_count_pos_sclk == bit_length) begin 
        tx_data_count_pos_sclk <= 0;
    end else begin 
        tx_data_count_pos_sclk <= tx_data_count_pos_sclk + 1;
    end 
        
always @(posedge sclk or negedge sys_rst_n) 
    if (!sys_rst_n) begin 
        tx_done_pos <= 1'b0;
    end else if (tx_data_count_pos_sclk == bit_length) begin 
        tx_done_pos <= 1'b1;
    end  else if (tx_data_count_pos_sclk == 'd3) begin// 把done信号延迟拉低，方便系统时钟采样
        tx_done_pos <= 1'b0;
    end 

// MISO输出选择（根据CPOL和CPHA）slave tx only support mode 1 and mode 3
always_comb begin 
    if (SPI_MODE == 1) begin 
        miso = miso_01; // CPOL=1, CPHA=0
    end else if (SPI_MODE == 3) begin 
        miso = miso_11; // CPOL=1, CPHA=1
    end else 
        miso = 1'b0; // 默认高阻态
end

logic tx_done_reg1;
logic tx_done_reg2;
logic tx_done_reg3;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n) begin 
        tx_done_reg1 <= 1'b0;
        tx_done_reg2 <= 1'b0;
        tx_done_reg3 <= 1'b0;
    end else begin 
        if (SPI_MODE == 0 || SPI_MODE == 3) begin 
            tx_done_reg1 <= tx_done_neg;
        end else begin 
            tx_done_reg1 <= tx_done_pos;
        end 
        tx_done_reg2 <= tx_done_reg1;
        tx_done_reg3 <= tx_done_reg2;
    end 

//use async fifo to store miso data to be sent        



assign tx_data_ready = fifo_wnf; // FIFO is not full, can write data

/** FIFO read from spi clock **/
// assign fifo_rreq = tx_done_reg2 == 1'b1 && tx_done_reg3 == 1'b0;

//read new data from when fifo_sys_inst prepared 
logic spi_rd_started; 
logic spi_rd_started_1d; 
logic spi_rd_started_2d; 
logic spi_rd_started_3d; 
logic spi_rd_started_pos; 

assign tx_error = spi_fifo_rreq && !fifo_rne; // FIFO read request but FIFO is empty
assign tx_done_pulse = tx_done_reg2 & (~tx_done_reg3);

// assign spi_rd_started = (SPI_MODE == 0 || SPI_MODE == 3) ? rx_data_count_pos_sclk == 2 : rx_data_count_neg_sclk == 2;

always @(posedge sclk or posedge cs_n)
    if (cs_n) begin
        spi_rd_started <= 1'b0;
    end else if (SPI_MODE == 3) begin
        spi_rd_started <= rx_data_count_pos_sclk == 2 ? 1'b1 : rx_data_count_pos_sclk == bit_length ? 1'b0 : spi_rd_started;  
    end else begin 
        spi_rd_started <= rx_data_count_neg_sclk == 2 ? 1'b1 : rx_data_count_neg_sclk == bit_length ? 1'b0 : spi_rd_started;  
    end

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n) begin
        spi_rd_started_1d <= 1'b0;
        spi_rd_started_2d <= 1'b0;
        spi_rd_started_3d <= 1'b0;
    end else begin
        spi_rd_started_1d <= spi_rd_started;
        spi_rd_started_2d <= spi_rd_started_1d;
        spi_rd_started_3d <= spi_rd_started_2d;
    end

assign spi_rd_started_pos = spi_rd_started_2d && ~spi_rd_started_3d; // detect the rising edge of spi_rd_started


xlib_xyz_fifoa #(
    .DW(DW),
    .FW(FW)
) fifo_sys_inst (
    .rst_n(sys_rst_n),
    .wclk(sys_clk),
    .wreq(tx_data_valid && tx_data_ready),
    .wd(tx_data),
    .wne(),
    .wnf(fifo_wnf),   
    .wcnt(fifo_wcnt),
    .rclk(sclk),
    .rreq(spi_fifo_rreq),
    .rd(fifo_rd),
    .rne(fifo_rne),
    .rnf(),         // Not used
    .rcnt()         // Not used
);



logic spi_rd_started_sync; 
logic spi_fifo_full;
logic spi_fifo_ne;
logic [31:0] spi_fifo_rd;


always @(posedge sclk or negedge sys_rst_n)
    if (!sys_rst_n)
        txdata_reg <= 0;
    else if (spi_fifo_rreq)
        txdata_reg <= byte_swap32(fifo_rd);


assign spi_fifo_rreq = (SPI_MODE == 3) ? rx_data_count_pos_sclk == bit_length - 1 : rx_data_count_neg_sclk == bit_length;


function reg [31:0] byte_swap32;
    input [31:0] din;
    begin
        byte_swap32 = {din[7:0], din[15:8], din[23:16], din[31:24]};
    end
endfunction



endmodule
    