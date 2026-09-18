module spi_dma_wc_bst #(parameter 
    AL=2, // address lsb (DATA_WIDTH=8*(2**AL))
    AW=32, // address msb
    BL=4, // burst length width (BURST_LENGTH_IN_WORDS=2**BL); must: BL>0
    FW=6, // fifo level width (FIFO_SIZE=2**FW);  must: FW>=BL
    ALWAYS_EN=0 // RUN bit always set. if 1, RSP_CNT_W must set 0
)(
    input   clk,
    input   rst_n, // dma reset
    input   bus_rst_n, // bus reset
    input   pio_adr_we,
    input   pio_len_we, // if ALWAYS_EN==1, not used
    input   [BL:0] burstcount, // 外部输入的burst长度
    input   [31:0] pio_d,
    output  [31:0] pio_adr,
    output  [31:0] pio_len, // if ALWAYS_EN==1, output fixed 1
    output  [31:0] pio_cst,
    input   [FW:0] dff_cnt,
    input   dff_ack,
    input   dff_eof,
    input   dff_rval,
    output  done,
    output  [AW-1:0] biu_adr,
    output  [BL:0] biu_len,
    output  biu_req,
    input   biu_ack,
    input   rsp_val
);

    reg [AW-1:AL] adr_reg; // 字对齐的基地址
    reg run_reg;

    wire dff_done = dff_ack & dff_eof;

    always @(posedge clk)
    if (pio_adr_we) adr_reg <= pio_d[AW-1:AL]; // 初始化地址
    else if (biu_ack) adr_reg <= adr_reg + burstcount; // 根据burstcount递增

    always @(posedge clk or negedge rst_n)
    if (~rst_n) run_reg <= ALWAYS_EN ? 1 : 0; else
    if (pio_len_we | dff_done) run_reg <= ALWAYS_EN ? 1 : pio_len_we ? pio_d[0] : 0;

    assign pio_adr = {adr_reg, {AL{1'b0}}}; // 字对齐的字节地址
    assign pio_len = run_reg;
    assign pio_cst = dff_cnt << 16;
    assign biu_adr = {adr_reg, {AL{1'b0}}}; // 起始地址为字对齐
    assign biu_len = burstcount; // 直接使用外部burstcount
    assign biu_req = run_reg & (dff_cnt >= burstcount) & dff_rval; //不能依赖fifo的计数器，有时候计数器先有但是fifo_not_empty后拉起的
    assign done = dff_done;

endmodule