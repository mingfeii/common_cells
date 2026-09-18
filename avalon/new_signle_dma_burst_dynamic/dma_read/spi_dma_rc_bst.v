module spi_dma_rc_bst #(
    parameter 
    AL=2, // address lsb (DATA_WIDTH=8*(2**AL))
    AW=32, // address msb
    BL=4, // max burst length exponent (MAX_BURST_LENGTH_IN_WORDS=2**BL); must: BL>0
    FW=6, // fifo level width (FIFO_SIZE=2**FW); must: FW>=BL
    LW=24 // length msb
)(
    input   clk,
    input   rst_n, // dma reset
    input   bus_rst_n, // bus reset
    input   pio_adr_we,
    input   pio_len_we,
    input   [31:0] pio_d,
    output  [31:0] pio_adr,
    output  [31:0] pio_len,  
    output  [31:0] pio_cst,
    input   [FW:0] dff_cnt,
    input   [BL:0] burstcount, // External burst length input (1 to 2**BL) 
    output  dff_ack,
    output  dff_eof,
    output  done,
    output  err,
    output  [AW-1:0] biu_adr,
    output  [BL:0] biu_len,
    output  biu_req,
    input   biu_ack,
    input   rsp_val
);

reg [AW-1:AL] adr_reg; // Address in bytes
reg [LW-1:0] len_reg; // Length in words
reg [FW:0] rsp_cnt; // Response counter in words

wire [LW-1:0] len_reg_1 = len_reg - 1;
wire run_reg = |len_reg; // DMA active if length is non-zero , length MUST be consider aligned !!!!!!
wire [FW:0] dat_cnt = rsp_cnt + dff_cnt; // Total words in flight

// Constrain burstcount to valid range (1 to 2**BL, limited by remaining length and FIFO space)
wire [BL:0] max_burst = 2**BL; // Maximum burst size in words
wire [LW-1:0] words_remaining = len_reg; // Remaining words to transfer
wire [FW:0] fifo_space = (2**FW) - dat_cnt; // Available FIFO space in words
wire [BL:0] burst_words = (burstcount > max_burst) ? max_burst : 
                          (burstcount > words_remaining) ? words_remaining[BL:0] : 
                          (burstcount == 0) ? 1 : burstcount; // Ensure at least 1 word
wire [BL:0] burst_len = burst_words; // Avalon-MM: biu_len is number of words

// Address register update (in bytes)
always @(posedge clk)
if (pio_adr_we | biu_ack)
    adr_reg <= pio_adr_we ? pio_d[AW-1:AL] : adr_reg + burst_words; // Increment by burst size in bytes

// Length register update (in words)
always @(posedge clk or negedge rst_n)
if (~rst_n) len_reg <= 0;
else if (pio_len_we | biu_ack)
    len_reg <= pio_len_we ? pio_d[LW-1:0] >> AL : len_reg - burst_words; // Convert bytes to words

// Response counter (in words)
always @(posedge clk or negedge bus_rst_n)
if (~bus_rst_n) rsp_cnt <= 0;
else
    rsp_cnt <= rsp_cnt + (biu_ack ? burst_words : 0) - (rsp_val ? 1 : 0);

// Output assignments
assign pio_adr = adr_reg << AL; // Convert to bytes
assign pio_len = len_reg << AL; // Convert words to bytes
assign pio_cst = {dff_cnt, 8'h0, rsp_cnt}; // Status: FIFO count and response count
assign biu_adr = adr_reg << AL; // Convert to bytes
assign biu_len = run_reg ? burst_len : 0; // Only issue valid burst length when running
assign biu_req = run_reg & (dat_cnt <= (2**FW - burst_words)) & (|burst_words); // Ensure FIFO space and valid burst
assign dff_ack = rsp_val;
assign dff_eof = ~run_reg & (rsp_cnt == 1);
assign done = ~run_reg & (rsp_cnt == 1) & rsp_val;
assign err = (rsp_cnt == 0) & rsp_val;

endmodule