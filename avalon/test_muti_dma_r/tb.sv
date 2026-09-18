`timescale 1ns / 1ns
module tb();


parameter AW=32;
localparam BL=8;
localparam  SRC_BL=3;
parameter LW=24;
parameter CH = 3;
parameter CW=$clog2(CH+1);
parameter DW=64;
parameter BS = DW / 8;
parameter AL=$clog2(BS); 
parameter RANDOM = 1'b0;
localparam SMOTH_DMA_RDY = 1'b0;

localparam  SDR_ARDY_RATE=80,
            SDR_SZ=2**25;

localparam SRC_FILE_NAME = "src.txt";

parameter FN = 1;

localparam DMA_LENGTH = 32'h12c00;
localparam DMA0_BASE_ADDRESS =  32'h00000000;

event check_done;
reg [31:0] DMA_ADDRESS [CH-1:0];

initial begin 
    integer i;
    DMA_ADDRESS[0] = DMA0_BASE_ADDRESS;
    for (i = 1; i < CH; i++) begin:ASSIGN_ADDRESS
        DMA_ADDRESS[i] = DMA_ADDRESS[i-1] + DMA_LENGTH;
    end 
end 


logic                   clk;
logic                   rst_n;
logic                   bus_rst_n;
logic [CH-1:0]          pio_adr_we;
logic [CH-1:0]          pio_len_we;
logic [CW-1:0]          nch;
logic [31:0]            pio_d;
logic  [32*CH-1:0]      pio_adr;
logic  [31:0]           pio_len;

logic   [CH-1:0]        dma_done;
logic   [CH-1:0]        dma_err;
bit [CH-1:0]            dma_rdy,dma_rdy_1;
logic   [CH-1:0]        dma_val;
logic   [CH-1:0]        dma_eof;
logic   [CH-1:0][DW-1:0]dma_d;
logic [CH-1:0]          dst_done,dst_done_is;
logic                   irq;
int                     dma_done_irq_cnt;
logic                   sr_we;



logic   [CH-1:0]        dma_val_o;
logic   [CH-1:0]        dma_rdy_o;
logic   [CH-1:0]        dma_eof_o;
logic   [CH-1:0][7:0]   dma_d_o;



bit                     bus_rrdy;
bit                     bus_rval;
bit  [BL-0:0]           bus_rlen;
bit  [AW-1:0]           bus_raddr;
bit [DW-1:0]            bus_rdata;
bit                     bus_rdval;

bit                     bus_wrdy ;
bit                     bus_wval = 0;
bit   [BL-1:0]          bus_wlen = 0;
bit   [AW-1:0]          bus_waddr = 0;
bit   [DW-1:0]          bus_wdata = 0;


initial
    begin:GEN_RST
    rst_n <= '0;
    repeat(100)@(posedge clk);
    rst_n=1'b1;
end


initial
    begin:GEN_BUSRST
    bus_rst_n <= '0;
    repeat(100)@(posedge clk);
    bus_rst_n=1'b1;
end


initial
    begin:GEN_CLK
    clk <= '0;
    forever #(5) clk=~clk;
end

reg [7:0] src_mem [CH-1:0][DMA_LENGTH-1:0];
reg [7:0] dst_mem [CH-1:0][DMA_LENGTH-1:0];
reg [CH-1:0] [31:0] dst_addr;


integer ch,i,ret,fd0;
bit [7:0] data;
int mem_addr;
initial begin:GEN_TEST_FILE 
    mem_addr = DMA0_BASE_ADDRESS;
    fd0=$fopen(SRC_FILE_NAME,"w");
    if (fd0==0) $stop;
    for (ch = 0; ch < CH; ch++) begin 
        for(i = 0; i < DMA_LENGTH; i++) begin 
            mem_addr = ch*DMA_LENGTH + i;
            sdr.mem[mem_addr]=data;
            src_mem[ch][i]=data;
            $fwrite(fd0,"%h\n",data);
            data = RANDOM ? $urandom_range(0,256) : data + 1;
        end 
    end 
    $fclose(fd0);
end 


initial begin:MAIN_BLOCK
    @(posedge rst_n);
    nch = CH - 1;
    config_top(nch);
    irq_process();
    $finish;
end 


initial begin :GEN_DMA_RDY
    integer i;
    forever @(posedge clk)begin 
        for (i=0;i<CH;i++)begin
        automatic int rdn = $urandom_range(100);
        if(rdn <= 20)begin
            dma_rdy_1[i] <= 1'b1;
        end  
        else begin
            dma_rdy_1[i] <= 1'b0;
        end
        end 
    end 
end 

assign dma_rdy_o =  SMOTH_DMA_RDY ? 1'b1 : dma_rdy_1;



genvar idx;
generate 
    for (idx = 0; idx < CH; idx++) begin:W2P
    xlib_stream_w2p #(
        .UNALIGN(0),  
        .DW(DW) 
        ) u_p2w (
        .clk(clk), 
        .rst_n(rst_n), 
        .clr_n(1'b1), 
        .bpp(0),
        .m_val(dma_val[idx]), 
        .m_eof(dma_eof[idx]), 
        .m_dat(dma_d[idx]),
        .m_rdy(dma_rdy[idx]),

        .s_rdy(dma_rdy_o[idx]), 
        .s_val(dma_val_o[idx]), 
        .s_eof(dma_eof_o[idx]), 
        .s_dat(dma_d_o[idx]));
end 
endgenerate 


always@(posedge clk or negedge rst_n)  begin 
    integer i;
    if (!rst_n) begin 
        dst_mem <= '{default: '0};
        dst_addr <= '0;
    end else begin  
        for (i = 0; i < CH; i++) begin:RECEIVE_DMA
            if (dma_val_o[i] && dma_rdy_o[i]) begin 
                    dst_mem[i][dst_addr[i]] <= dma_d_o[i];
                    dst_addr[i] <= dst_addr[i] + 1'b1;
                end 
            end 
        end
    end  

always_ff@(posedge clk or negedge rst_n)begin:PROC_DST_DONE_IS
  integer i;
  if (!rst_n)
    dst_done_is <= '0;
  else begin 
    for (i=0;i<CH;i++)begin:GEN_DST_DMA_DONE
      if (&dst_done_is)
        dst_done_is <= '0;
      else if (dma_done[i]==1'b1)
        dst_done_is[i] <= 1'b1;
    end 
  end 
end 



always @(posedge clk or negedge rst_n)
if (~rst_n) begin
  irq <= 0;
end
else begin
  irq <= ~irq ?  &dst_done_is  : ~sr_we ;
end



task automatic irq_process();
  dma_done_irq_cnt =0 ;
  $timeformat(-9, 2, "ns", 11);
  while(dma_done_irq_cnt!=FN) begin
    integer idx;
    @(posedge clk);
    @(posedge clk);
    $display("Waiting for irq...");
    @(posedge irq);
    dma_done_irq_cnt++;
    sr_we = 1'b1; // clear irq
    @(posedge clk);
    if (irq == 1'b0) sr_we = 1'b0;
    repeat(20000)@(posedge clk);// wait transfer done 
    mem_checker();
    repeat(1000)@(posedge clk);
  end
endtask

task automatic mem_checker();
    int i,j;
    for(i=0;i<CH;i++) begin
        for (j = 0; j < DMA_LENGTH; j++)
        if (src_mem[i][j] !== dst_mem[i][j]) begin 
        $display("at NO.(%0d,%d) src_mem:%0h,dst_mem:%0h",i,j,src_mem[i][j],dst_mem[i][j]);
        $display("mem_checker fail !");
        $stop;
    end
    end
    $display("mem_checker PASS !");
endtask 

task config_top(input int nch);
   integer i;
   repeat(10)@(posedge clk);
   pio_adr_we = {CH{1'b0}};
   pio_len_we = 1'b0;
   pio_d = 0;
   //config dma channel
   //0
   for (i = 0; i <= nch; i++) begin 
        @(posedge clk);
        pio_adr_we[i] = 1;
        pio_d = DMA_ADDRESS[i];
        @(posedge clk);
        pio_adr_we[i] = 0;

        //length
        @(posedge clk);
        pio_len_we[i] = 1;
        pio_d = DMA_LENGTH;
        @(posedge clk);
        pio_len_we[i] = 0;
   end 
endtask 

xlib_avalon_ram #(
.DW(DW),
.AW(AW),
.BL(BL),
.BI(1),
.SZ(SDR_SZ),
.ARDY_RATE(SDR_ARDY_RATE)
) sdr (
.clk    (clk),
.rst_n  (rst_n),
.rrdy   (bus_rrdy),
.rval   (bus_rval),
.rlen   (bus_rlen),
.raddr  (bus_raddr),
.rdata  (bus_rdata),
.rdval  (bus_rdval),
.wrdy   (bus_wrdy),
.wval   (bus_wval),
.wlen   (bus_wlen),
.waddr  (bus_waddr),
.wdata  (bus_wdata));

multi_xyz_dma_r #( 
    .AW(AW), 
    .AL(AL), 
    .BL(SRC_BL), 
    .LW(LW), 
    .CH(CH), 
    .CW(CW)
)multi_dma_r_inst (.*);

endmodule 