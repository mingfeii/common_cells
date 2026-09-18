/*
1. 1 个 burst地址发出的时候，此时应该立即把fifo的计数器usewdw + burst_length,数据可能还有延迟，
   但是相应fifo空间视为已经占用。
2. 等待这个当前burst地址的数据接受完毕之后，才能把fifo计数器当作burst_request的判断条件。
*/
// Compact DMA engine. address and length must align to burst size
module multi_dma_rc_bst #(parameter 
    AL=2, // address lsb (DATA_WIDTH=BW*(2**AL))
    AW=32, // address msb
    DW=64,
    BL=4, // burst length width (BURST_LENGTH_IN_WORDS=2**BL); must: BL>0
    FW=6, // fifo level width (FIFO_SIZE=2**FW);  must: FW>=BL
    LW=24, // length msb
    CH = 5, //maximal channels of DMA READ
    CW = $clog2(CH),
    BLEN_TYPE=0, // 0=VCI/AVM, 1=AXI
    DELAY_CNT=0 // Altera dcfifo's USEDW is delay 1 cycle
    //BS=2**AL, // data width in bytes, derived parameter
    //DW=BW*BS, // data width in bits, derived parameter
)(
input   clk,
input   rst_n, // dma reset
input   bus_rst_n, // bus reset

output logic [CH-1:0] done,
output logic [CH-1:0] err,
output  [AW-1:0] biu_adr,
output  [BL-BLEN_TYPE:0] biu_len,
output  biu_req,
input   biu_ack,

//add new 
input [CW-1:0]              nch,
input [CH-1:0]              pio_adr_we,
input [CH-1:0]              pio_len_we,
input [31:0]                pio_d,
//DMA RD bus signals 
input                       rsp_val,  //bus rdval signal
input [DW-1:0]              bus_rdata, 

//外部信号，给CPU观察的
output  logic [CH-1:0][31:0] pio_adr,
output  logic [CH-1:0][31:0] pio_len,

//DMA interface to next instance
input  [CH-1:0]             dma_rdy,
output logic [CH-1:0]       dma_val,
output logic [CH-1:0]       dma_eof,
output logic [CH-1:0][DW-1:0]dma_d
);

reg [CH-1:0][AW-1:BL+AL] adr_reg;
reg [CH-1:0][LW-1:BL+AL] len_reg;
reg [CH-1:0][LW:BL+AL] len_reg_1;
reg [CH-1:0]  run_reg;

reg [CH-1:0][FW:0] rsp_cnt;
reg delay_cyc;
logic [CH-1:0] burst_request;
logic dff_ack;
reg  [CW-1:0] biu_ch;
logic [CH-1:0][FW:0] dat_cnt;

// wire [LW:BL+AL] len_reg_1 = len_reg-1;
// wire run_reg = ~len_reg_1[LW];


logic [CH-1:0][FW:0] dff_cnt;

//signals about disp rdval 
logic [BL-1:0] rd_cnt;
bit  [CW-1:0] rd_cnt_sel;

//dma to fifo port signals 
logic [CH-1:0] dff_eof;

//each channel mantain its own run_reg
always_comb begin 
    integer i;
    for (i = 0; i < CH; i++) begin
        len_reg_1[i] = len_reg[i] - 1;
        run_reg[i] = ~len_reg_1[i][LW];
    end 
end         

//dat_cnt
always_comb begin 
    integer i;
    for (i = 0; i < CH; i++) begin:DAT_CNT 
        dat_cnt[i] = rsp_cnt[i] + dff_cnt[i] + delay_cyc;
    end 
end 

//biu_ch
always @(posedge clk or negedge rst_n)
    if (~rst_n) 
        biu_ch <= 0;
    else if (biu_ack) 
        biu_ch <= biu_ch==nch ? 0 : biu_ch+1; 

//adr_reg
always @(posedge clk) begin 
    integer i; 
    for (i=0; i<CH; i=i+1) begin 
        if (pio_adr_we[i] | biu_ack & biu_ch==i) 
            adr_reg[i] <= pio_adr_we[i] ? pio_d[31:BL+AL] : adr_reg[i]+1; 
        end
end 

//len_reg
always @(posedge clk or negedge rst_n) begin 
    integer i;
    if (~rst_n) 
        len_reg <= {CH{1'b0}};
    else begin 
        for (i = 0; i < CH; i++) begin 
            if (pio_len_we[i] | (biu_ack && biu_ch == i)) begin 
                len_reg[i] <= pio_len_we[i] ? pio_d[31:BL+AL] : len_reg_1[i];
            end 
        end 
    end 
end 


//rd_cnt
always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        rd_cnt <= '0;
    else if (rsp_val) begin 
        if (rd_cnt == 2**BL - 1)
            rd_cnt <= 0;
        else  
            rd_cnt <= rd_cnt + 1'b1;
    end 

//rd_cnt_sel
always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        rd_cnt_sel <= '0;
    else if (rsp_val && rd_cnt == 2**BL - 1) begin 
        if (rd_cnt_sel == nch)
            rd_cnt_sel <= 0;
        else 
            rd_cnt_sel <= rd_cnt_sel + 1'b1;
    end 
//rsp_cnt
always @(posedge clk or negedge bus_rst_n) begin 
    integer i;
    if (~bus_rst_n) 
        rsp_cnt <= '0;
    else begin 
        for (i = 0; i < CH; i++) begin:GET_RSP_DELAY
            rsp_cnt[i] <= rsp_cnt[i] + (biu_ack && i == biu_ch ? (2**BL-1) : -1) + (rsp_val && rd_cnt_sel == i  ? 0 : 1);
        end 
    end 
end 

//delay_cyc
always @(posedge clk or negedge bus_rst_n)
    if (~bus_rst_n) 
        delay_cyc <= 0; 
    else    
        delay_cyc <= DELAY_CNT ? dff_ack : 0;

assign biu_adr = adr_reg[biu_ch] << (BL+AL);
assign biu_len = BLEN_TYPE ? 2**BL-1 : 2**BL;


always_comb begin 
    integer i;
    for (i = 0; i < CH; i++) begin:BURST_REQUEST
        pio_len[i] = len_reg[i] << (BL+AL);
        pio_adr[i] = adr_reg[i] << (BL+AL); 
        burst_request[i] = run_reg[i] & dat_cnt[i] <= (2**FW-2**BL);
    end 
end 

assign dff_ack = rsp_val;
assign biu_req = burst_request[biu_ch];


always_comb begin 
    integer i;
    for (i = 0; i < CH; i++)begin:EOF_AND_DONE
        dff_eof[i] = i == rd_cnt_sel ?  ~run_reg[i] & rsp_cnt[rd_cnt_sel]==1 : 1'b0;
        done[i] = i == rd_cnt_sel ? ~run_reg[i] & rsp_cnt[rd_cnt_sel]==1 & rsp_val : 1'b0;
        err[i] = i == rd_cnt_sel ? rsp_cnt[rd_cnt_sel]==0 & rsp_val : 1'b0;
    end 
end 

genvar ch;
generate 
    for (ch = 0; ch < CH; ch++) begin:DMA_RFFIN

    xlib_xyz_fifo #(
        .DW(DW+1),
        .FW(FW)
    ) u_dff (
    .clk        (clk),
    .rst_n      (rst_n),
    .cnt        (dff_cnt[ch]),
    .wrdy       (/*NC*/),
    .wval       (rsp_val && ch == rd_cnt_sel),
    .wd         ({dff_eof[ch], bus_rdata}),
    .rrdy       (dma_rdy[ch]),
    .rval       (dma_val[ch]),
    .rd         ({dma_eof[ch], dma_d[ch]}));

    end 
endgenerate 



endmodule
