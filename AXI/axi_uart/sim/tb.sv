`timescale 100ps/10ps
`define den8192Mb
`define x16
`include "ddr3_controller.vh"

`define AXI_FULL_DEPLEX

module tb();

parameter   DATA_WIDTH   = 128;
parameter   ADDR_WIDTH   = 32;
parameter   ID_WIDTH     = 8;
parameter   START_ADDR = 32'h00000000;
parameter   DATA_NUM     = 128;
parameter   FW = 4;   
parameter   CLOCK_FRQ    = 100_000_000;
parameter   BADRATE      = 115_200;
parameter   UART_BIT     =    8;

parameter RAM_IDLE          =   `RAM_IDLE          ;
parameter RAM_ACT           =   `RAM_ACT           ;
parameter RAM_WR            =   `RAM_WR            ;
parameter RAM_RD            =   `RAM_RD            ;
parameter RAM_RD2PREA       =   `RAM_RD2PREA       ;
parameter RAM_WR2PREA       =   `RAM_WR2PREA       ;
parameter RAM_WR2RD         =   `RAM_WR2RD         ;
parameter RAM_RD2WR         =   `RAM_RD2WR         ;
parameter RAM_PREA2REF      =   `RAM_PREA2REF      ;
parameter RAM_REF           =   `RAM_REF           ;
parameter RAM_NOP           =   `RAM_NOP           ;
parameter RAM_WPAW          =   `RAM_WPAW          ;
parameter RAM_WPAR          =   `RAM_WPAR          ;
parameter RAM_RPAW          =   `RAM_RPAW          ;
parameter RAM_RPAR          =   `RAM_RPAR          ;
parameter RAM_SRE           =   `RAM_SRE           ;
parameter RAM_SR            =   `RAM_SR            ;
parameter RAM_SRX           =   `RAM_SRX           ;
parameter RAM_INIT          =   `RAM_INIT          ;
parameter RAM_WAITING       =   `RAM_WAITING       ;
parameter BRAM_LEN          =   `BRAM_LEN          ;
parameter BRAM_I_WIDTH      =   `BRAM_I_WIDTH      ;
parameter BRAM_D_WIDTH      =   `BRAM_D_WIDTH      ;
parameter MICRO_SEC         =   `MICRO_SEC         ;
parameter REF_INTERVAL      =   `REF_INTERVAL      ;
parameter DRAM_WIDTH        =   `DRAM_WIDTH        ;
parameter GROUP_WIDTH       =   `GROUP_WIDTH       ;
parameter DRAM_GROUP        =   `DRAM_GROUP        ;
parameter DM_BIT_WIDTH      =   `DM_BIT_WIDTH      ;
parameter ROW               =   `ROW               ;
parameter COL               =   `COL               ;
parameter BANK              =   `BANK              ;
parameter BA_BIT_WIDTH      =   `BA_BIT_WIDTH      ;
parameter WFIFO_WIDTH       =   `WFIFO_WIDTH       ;
parameter BL                =   `BL                ;
parameter usReset           =   `usReset           ;
parameter usCKE             =   `usCKE             ;
parameter tZQinit           =   `tZQinit           ;
parameter ODTH8             =   `ODTH8             ;
parameter tRL               =   `tRL               ;
parameter tWL               =   `tWL               ;
parameter ARBITER_INIT      =   `ARBITER_INIT      ;
parameter ARBITER_COUNT     =   `ARBITER_COUNT     ;
parameter RAM_FILE          =   `RAM_FILE         ;
reg core_clk;
reg clk;
reg user_clk;
reg twd_clk;
reg tdqss_clk;
reg tac_clk;
reg nrst;



wire w_cal_done;
wire reset;
wire cs;
wire ras;
wire cas;
wire we;
wire cke;
wire [15:0]addr;
wire [2:0]ba;
wire odt;
tri1 [ DRAM_WIDTH-1:0] dq;
tri1 [ DRAM_GROUP-1:0] dm;
tri1 [ DRAM_GROUP-1:0] dqs;
tri1 [ DRAM_GROUP-1:0] dqs_n;
reg read;
reg write;

wire [ DRAM_GROUP-1:0]i_dqs_hi;
wire [ DRAM_GROUP-1:0]i_dqs_lo;

wire [ DRAM_GROUP-1:0]i_dqs_n_hi;
wire [ DRAM_GROUP-1:0]i_dqs_n_lo;


wire [ DRAM_GROUP-1:0]o_dqs_hi;
wire [ DRAM_GROUP-1:0]o_dqs_lo;

wire [ DRAM_GROUP-1:0]o_dqs_n_hi;
wire [ DRAM_GROUP-1:0]o_dqs_n_lo;


wire [ DRAM_GROUP-1:0]o_dqs_oe;
wire [ DRAM_GROUP-1:0]o_dqs_n_oe;

wire [ DRAM_GROUP-1:0]w_dqs;
wire [ DRAM_GROUP-1:0]w_dqs_n;

wire [ DRAM_GROUP-1:0]w_dqs_i;
wire [ DRAM_GROUP-1:0]w_dqs_n_i;

wire [ DRAM_GROUP-1:0]w_dqs_o;
wire [ DRAM_GROUP-1:0]w_dqs_n_o;

wire [ DRAM_WIDTH-1:0] i_dq_hi;
wire [ DRAM_WIDTH-1:0] i_dq_lo;

wire [ DRAM_WIDTH-1:0] o_dq_hi;
wire [ DRAM_WIDTH-1:0] o_dq_lo;

wire [ DRAM_WIDTH-1:0] w_dq_o;

wire [ DRAM_WIDTH-1:0] o_dq_oe;

wire [ DRAM_GROUP-1:0] o_dm_hi;
wire [ DRAM_GROUP-1:0] o_dm_lo;


logic rst_n;

genvar n;

generate
  for (n=0;n< DRAM_GROUP;n=n+1 ) begin

    assign dqs[n] = (o_dqs_oe[n]==1)?w_dqs_o[n]:1'bz;
    assign dqs_n[n] = (o_dqs_n_oe[n]==1)?w_dqs_n_o[n]:1'bz;

    EFX_ODDR ddio_dm_out
    (
    .D0(o_dm_hi[n]), // data 0 input
    .D1(o_dm_lo[n]), // data 1 input
    .CE(1'b1), // clock-enable
    .CLK(twd_clk), // clock
    .SR(1'b0), // asyc/sync set/reset
    .Q(dm[n])    // data output
    );

    EFX_ODDR ddio_dqs_out
    (
    .D0(o_dqs_hi[n]), // data 0 input
    .D1(o_dqs_lo[n]), // data 1 input
    .CE(1'b1), // clock-enable
    .CLK(clk), // clock
    .SR(1'b0), // asyc/sync set/reset
    .Q(w_dqs_o[n])    // data output
    );

    EFX_ODDR ddio_dqs_n_out
    (
    .D0(o_dqs_n_hi[n]), // data 0 input
    .D1(o_dqs_n_lo[n]), // data 1 input
    .CE(1'b1), // clock-enable
    .CLK(clk), // clock
    .SR(1'b0), // asyc/sync set/reset
    .Q(w_dqs_n_o[n])    // data output
    );

    EFX_IDDR ddio_dqs_in
    (
    .D(dqs[n]),   // data input
    .CE(1'b1),  // clock-enable
    .CLK(tac_clk), // clock
    .SR(1'b0),  // asyc/sync set/reset
    .Q0(i_dqs_hi[n]),  // data 0 output
    .Q1(i_dqs_lo[n])   // data 1 output
    );

    EFX_IDDR ddio_dqs_n_in 
    (
    .D(dqs_n[n]),   // data input
    .CE(1'b1),  // clock-enable
    .CLK(tac_clk), // clock
    .SR(1'b0),  // asyc/sync set/reset
    .Q0(i_dqs_n_hi[n]),  // data 0 output
    .Q1(i_dqs_n_lo[n])   // data 1 output
    );


  end	
endgenerate





generate
  for (n =0 ;n< DRAM_WIDTH;n=n+1) begin

    assign dq[n]=o_dq_oe[n]?w_dq_o[n]:1'bz;

    EFX_ODDR ddio_dq_out
    (
    .D0(o_dq_hi[n]), // data 0 input
    .D1(o_dq_lo[n]), // data 1 input
    .CE(1'b1), // clock-enable
    .CLK(twd_clk), // clock
    .SR(1'b0), // asyc/sync set/reset
    .Q(w_dq_o[n])    // data output
    );

    EFX_IDDR ddio_dq_in
    (
    .D(dq[n]),   // data input
    .CE(1'b1),  // clock-enable
    .CLK(tac_clk), // clock
    .SR(1'b0),  // asyc/sync set/reset
    .Q0(i_dq_hi[n]),  // data 0 output
    .Q1(i_dq_lo[n])   // data 1 output
    );

  end	
endgenerate

logic user_rst_n;

//生成复位
initial
begin
	rst_n <=1'b0;
	#1000
	rst_n <=1'b1;	
end


initial begin 
  user_rst_n = 1'b0;
  @(posedge w_cal_done);
  repeat(1000)@(posedge user_clk);
  user_rst_n = 1'b1;
end 


defparam    ddr3md.DEBUG = 0;
ddr3 ddr3md
(
.rst_n(reset),
    .ck(~clk),
    .ck_n(clk),
    .cke(cke),
   .cs_n(cs),
   .ras_n(ras),
    .cas_n(cas),
    .we_n(we),
    .dm_tdqs(dm),
    .ba(ba),
    .addr(addr),
    .dq(dq),
    .dqs(dqs),
   .dqs_n(dqs_n),
    .tdqs_n(),
    .odt(odt)
);


initial begin
  core_clk = 1'b0;
  #1 core_clk = 1'b0;
  forever begin
    #20 core_clk = ~core_clk;
  end
end

initial begin
  tdqss_clk = 1'b0;
  #1 tdqss_clk = 1'b0;
  forever begin
    #10 tdqss_clk = ~tdqss_clk;
  end
end

initial begin
  tac_clk = 1'b1;
  #1 tac_clk = 1'b1;
  forever begin
    #10 tac_clk = ~tac_clk;
  end
end

initial begin
  clk = 1'b0;
  #1 clk = 1'b0;
  forever begin
    #10 clk = ~clk;
  end
end


initial begin
  user_clk = 1'b0;
  #1 user_clk = 1'b0;
  forever begin
    #50 user_clk = ~user_clk;
  end
end


initial begin
  twd_clk = 1'b0;
  #6 twd_clk = 1'b0;
  forever begin
    #10 twd_clk = ~twd_clk;
  end
end

logic          fail;

logic  [7:0]   awid;     
logic  [31:0]  awaddr; 
logic  [7:0]   awlen;  
logic  [2:0]   awsize; 
logic  [1:0]   awburst;
logic  [0:0]   awlock; 
logic  [3:0]   awcache;
logic  [2:0]   awprot; 
logic  [3:0]   awqos;  
logic  [3:0]   awregion;
logic          awvalid;
logic          awready;
logic  [127:0] wdata;  
logic  [15:0]  wstrb;  
logic          wlast;  
logic          wvalid; 
logic          wready; 
logic  [7:0]   bid;    
logic  [1:0]   bresp;  
logic          bvalid; 
logic          bready; 
logic  [7:0]   arid;   
logic  [31:0]  araddr; 
logic  [7:0]   arlen;  
logic  [2:0]   arsize; 
logic  [1:0]   arburst;
logic  [0:0]   arlock; 
logic  [3:0]   arcache;
logic  [2:0]   arprot; 
logic  [3:0]   arqos;  
logic  [3:0]   arregion;
logic          arvalid;
logic          arready;
logic  [7:0]   rid;    
logic  [127:0] rdata;  
logic  [1:0]   rresp;  
logic          rlast;  
logic          rvalid; 
logic          rready; 






//DDR Control Workaround
// wire            			        io_arw_valid;
// wire            			        io_arw_ready;
// wire    [31:0]  			        io_arw_payload_addr;
// wire    [7:0]   			        io_arw_payload_id;
// wire    [7:0]   			        io_arw_payload_len;
// wire    [2:0]   			        io_arw_payload_size;
// wire    [1:0]   			        io_arw_payload_burst;
// wire    [1:0]   			        io_arw_payload_lock;
// wire            			        io_arw_payload_write;
// wire    [7:0]   			        io_w_payload_id;
// wire            			        io_w_valid;
// wire            			        io_w_ready;
// wire    [DATA_WIDTH-1:0]  		io_w_payload_data;
// wire    [DATA_WIDTH/8-1:0]    io_w_payload_strb;
// wire            			        io_w_payload_last;
// wire            			        io_b_valid;
// wire            			        io_b_ready;
// wire    [7:0]   			        io_b_payload_id;
// wire            			        io_r_valid;
// wire            			        io_r_ready;
// wire    [DATA_WIDTH-1:0]  	  io_r_payload_data;
// wire    [7:0]   			        io_r_payload_id;
// wire    [1:0]   			        io_r_payload_resp;
// wire            			        io_r_payload_last;
// wire	[1:0]				            io_b_payload_resp;


localparam WIDTH = $clog2(DATA_NUM+1);

logic [31:0] awcnt_record;
logic [31:0] bcnt_record;
logic [31:0] wcnt_record;
logic [WIDTH-1:0] awcnt;
logic [WIDTH-1:0] bcnt;
logic [WIDTH-1:0] wcnt;
logic aw_lock;
logic w_lock;
logic b_lock;




//axi write 
// assign wdata = {(DATA_WIDTH/WIDTH){wcnt}};
assign wdata = wcnt_record;
always_ff@(posedge user_clk or negedge user_rst_n)
    if (!user_rst_n) begin 
        //fixed signal 
        awsize <= 3'b100; 
        awburst <= 2'b01;
        awid <= 0;
        awlen <= 0; //set burst length = 0
        wstrb <= 16'hffff;
        //aw
        awaddr <= START_ADDR;
        awvalid <= 1'b0;
        //b
        bready <= 1'b0;
        //w
        wvalid <= 1'b0;
        wlast <= 1'b0;
        // other signals 
        awcnt <= 0;
        bcnt <= 0;
        wcnt <= 0;
        awcnt_record <= 0;
        bcnt_record <= 0;
        wcnt_record <= 0;
        aw_lock <= 1'b0;
        w_lock <= 1'b0;
        b_lock <= 1'b0;
    end else begin 
        //AW 
        if (!aw_lock) awvalid <= 1'b1;
        else awvalid <= 1'b0;

        if (awvalid && awready) begin 
            awaddr <= awaddr + (DATA_WIDTH / 8);
            awcnt <= awcnt + 1'b1;
            awcnt_record <= awcnt_record + 1'b1;
            if (awcnt==DATA_NUM-1)begin 
                awvalid <= 1'b0;
                awaddr <= START_ADDR;
                aw_lock <= 1'b1;
                awcnt <= 0;
            end 
        end 
        //W
        if (!w_lock) begin 
            wvalid <= 1'b1;
            wlast <= 1'b1;
        end else begin 
            wvalid <= 1'b0;
            wlast <= 1'b0;
        end 

        if (wvalid && wready) begin 
            wcnt_record <= wcnt_record + 1'b1;
            wcnt <= wcnt + 1'b1;
            if (wcnt==DATA_NUM-1) begin 
                wvalid <= 1'b0;
                w_lock <= 1'b1;
                wlast <= 1'b0;
                wcnt <= 0;
         
            end 
        end 
        //B
        if (!b_lock) 
            bready <= 1'b1;
        else 
            bready <= 1'b0;

        if (bvalid && bready) begin 
            bcnt <= bcnt + 1'b1;
            bcnt_record <= bcnt_record + 1'b1;
            if (bcnt==DATA_NUM-1) begin 
                bready <= 1'b0;
                bcnt <= 0;
                b_lock <= 1'b1;
       
            end 
        end 
        
    end 







bit uart_rx;
bit uart_tx;


axi_uart_read #(
    .DATA_WIDTH(DATA_WIDTH), 
    .ADDR_WIDTH(ADDR_WIDTH), 
    .ID_WIDTH  (ID_WIDTH  ), 
    .ID        (0        ), 
    .CLOCK_FRQ (CLOCK_FRQ ), 
    .BADRATE   (BADRATE   ), 
    .UART_BIT  (UART_BIT  ), 
    .FW        (FW        )

)axi_uart_read_U(
   .clk        ( user_clk         ),                                
   .rst_n      ( user_rst_n       ),                                
   .uart_rx    ( uart_tx     ),                                
   .uart_tx    ( uart_rx     ),                                
   .arid       ( arid        ),                                
   .araddr     ( araddr      ),                                
   .arlen      ( arlen       ),                                
   .arsize     ( arsize      ),                                
   .arburst    ( arburst     ),                                
   .arvalid    ( arvalid     ),                                
   .arready    ( arready     ),                                
   .rid        ( rid         ),                                
   .rdata      ( rdata       ),                                
   .rresp      ( rresp       ),                                
   .rlast      ( rlast       ),                                
   .rvalid     ( rvalid      ),                                
   .rready     ( rready      )     

);



localparam UART_READ = 8'h52;


//test 

logic [7:0] tx_data_1;
logic tx_data_valid_1;
logic tx_data_ready_1;
bit [3:0] tx_cnt;

 usart_tx #(
	.CLK_FRE(CLOCK_FRQ),      //clock frequency(Mhz)
	.BAUD_RATE(BADRATE)//serial baud rate
 )usart_tx_1  (
	.clk(user_clk),              //clock input
	.rst_n(user_rst_n),            //asynchronous reset input, low active 
	.tx_data( tx_data_1   ),          //data to send
	.tx_data_valid(  tx_data_valid_1),    //data to be sent is valid
	.tx_data_ready( tx_data_ready_1 ),    //send ready
	.tx_pin   (uart_tx)         //serial data output
);


reg [7:0] tx_mem [5:0] = '{
    8'h00,//arlen
    8'h10,
    8'h00,
    8'h00,
    8'h00,
    8'h52 //start
};


always_ff@(posedge user_clk or negedge user_rst_n)
  if (!user_rst_n)
    tx_cnt <= 0;
  else if (tx_cnt < 6 && tx_data_valid_1 && tx_data_ready_1)
    tx_cnt <= tx_cnt + 1'b1;

always_ff@(posedge user_clk or negedge user_rst_n)
  if (!user_rst_n)
    tx_data_valid_1 <= 0;
  else if (tx_cnt == 5 && tx_data_valid_1 && tx_data_ready_1)
    tx_data_valid_1 <= 1'b0;
  else 
    tx_data_valid_1 <= 1'b1;





assign tx_data_1 = tx_mem[tx_cnt];



//rx side 
logic [7:0] rx_data_byte_1;
logic rx_valid_1;


usart_rx #(
  .CLOCK_FRQ(CLOCK_FRQ),
  .BADRATE(BADRATE),
  .UART_BIT(UART_BIT)

)uart_rx_1 (
	.clock(user_clk),
	.rxd(uart_rx),
	.rst_n(user_rst_n),
	.rx_data_byte(rx_data_byte_1),
	.rx_valid_wire(rx_valid_1)
);









  Ddr_Controller_Axi   #(
    .AXI_ID_WIDTH(8)
  )U3_Ddr_Controller_Axi  (
    .Sys_Clk                ( user_clk   ) , //System Clock 
    .Sys_Rst_N              ( rst_n ) , //System Reset (Low Active)
    .Ddr_Main_Clk           ( core_clk  ) , //DDR Controller Main Controller Clock        (core_clk )
    .Ddr_DataOut_Clk        ( twd_clk   ) , //DDR Controller DQ/DM Output Clock           (twd_clk  )
    .Ddr_CtrlOut_Clk        ( tdqss_clk ) , //DDR Controller Addr/Ctrl/Dqss Output Clock  (tdqss_clk)  
    .Ddr_DataIn_Clk         ( tac_clk   ) , //DDR Controller DQ/DQS input Clock           (tac_clk  )  
    //Axi Interfac Signal
//&&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  AXI_FULL_DEPLEX
//&&&&&&&&&&&&&&&&&&&&&&&&&&&
    .I_AWID       ( awid          ) , //(I)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
    .I_AWADDR     ( awaddr        ) , //(I)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
    .I_AWLEN      ( awlen         ) , //(I)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
    .I_AWSIZE     ( awsize        ) , //(I)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
    .I_AWBURST    ( awburst       ) , //(I)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
    .I_AWLOCK     ( awlock        ) , //(I)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
    .I_AWVALID    ( awvalid       ) , //(I)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
    .O_AWREADY    ( awready       ) , //(O)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    /////////////   
    .I_ARID       ( arid          ) , //(I)[RdAddr]Read address ID. This signal is the identification tag for the read address group of signals.
    .I_ARADDR     ( araddr        ) , //(I)[RdAddr]Read address. The read address gives the address of the first transfer in a read burst transaction.
    .I_ARLEN      ( arlen         ) , //(I)[RdAddr]Burst length. This signal indicates the exact number of transfers in a burst.
    .I_ARSIZE     ( arsize        ) , //(I)[RdAddr]Burst size. This signal indicates the size of each transfer in the burst.
    .I_ARBURST    ( arburst       ) , //(I)[RdAddr]Burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
    .I_ARLOCK     ( arlock        ) , //(I)[RdAddr]Lock type. This signal provides additional information about the atomic characteristics of the transfer.
    .I_ARVALID    ( arvalid       ) , //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.
    .O_ARREADY    ( arready       ) , //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    /////////////
    .I_WID        (wid           ) , //(I)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
    .I_WSTRB      (wstrb         ) , //(I)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    .I_WLAST      (wlast         ) , //(I)[WrData]Write last. This signal indicates the last transfer in a write burst.
    .I_WVALID     (wvalid        ) , //(I)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
    .I_WDATA      (wdata         ) , //(O)[WrData]Write data.
    .O_WREADY     (wready        ) , //(I)[WrData]Write ready. This signal indicates that the slave can accept the write data.
    /////////////
    .O_BID        ( bid           ) , //(O)[WrResp]Response ID tag. This signal is the ID tag of the write response.
    .O_BVALID     ( bvalid        ) , //(O)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
    .I_BREADY     ( bready        ) , //(I)[WrResp]Response ready. This signal indicates that the master can accept a write response.
    /////////////
    .O_RID        ( rid           ) , //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
    .O_RRESP      ( rresp         ) , //(O)[RdData]Read response. This signal indicates the status of the read transfer.
    .O_RLAST      ( rlast         ) , //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
    .O_RVALID     ( rvalid        ) , //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
    .I_RREADY     ( rready        ) , //(I)[RdData]Read ready. This signal indicates that the master can accept the read data and response information.
    .O_RDATA      ( rdata         ) , //(O)[RdData]Read data.
//&&&&&&&&&&&&&&&&&&&&&&&&&&&
`else
//&&&&&&&&&&&&&&&&&&&&&&&&&&&
    .I_arw_valid            ( io_arw_valid  ) , //(I)[Addres] Address Valid
    .O_arw_ready            ( io_arw_ready  ) , //(O)[Addres] Address Ready
    .I_arw_payload_addr     ( io_arw_payload_addr   ) , //(I)[Addres] Address
    .I_arw_payload_id       ( io_arw_payload_id     ) , //(I)[Addres] Address ID
    .I_arw_payload_len      ( io_arw_payload_len    ) , //(I)[Addres] Address Brust Length
    .I_arw_payload_size     ( io_arw_payload_size   ) , //(I)[Addres] Address Burst size
    .I_arw_payload_burst    ( io_arw_payload_burst  ) , //(I)[Addres] Address Burst type
    .I_arw_payload_lock     ( io_arw_payload_lock   ) , //(I)[Addres] Address Lock type
    .I_arw_payload_write    ( io_arw_payload_write   ) , //(I)[Addres] Operate Type 0=Read, 1=Write
    /////////////
    .I_w_payload_id         ( io_w_payload_id     ) , //(I)[Write]  ID
    .I_w_valid              ( io_w_valid  ) , //(I)[Write]  Data Valid
    .O_w_ready              ( io_w_ready  ) , //(O)[Write]  Data Ready
    .I_w_payload_data       ( io_w_payload_data   ) , //(I)[Write]  Data
    .I_w_payload_strb       ( io_w_payload_strb   ) , //(I)[Write]  Data Strobes(Byte valid)
    .I_w_payload_last       ( io_w_payload_last   ) , //(I)[Write]  Data Last
    /////////////
    .O_b_valid              ( io_b_valid  ) , //(O)[Answer] Response Ready
    .I_b_ready              ( io_b_ready  ) , //(I)[Answer] Response Write ID
    .O_b_payload_id         ( io_b_payload_id     ) , //(O)[Answer] Response valid
    /////////////
    .O_r_valid              ( io_r_valid  ) , //(O)[Read]   Data Valid
    .I_r_ready              ( io_r_ready  ) , //(I)[Read]   Data Ready
    .O_r_payload_data       ( io_r_payload_data   ) , //(O)[Read]   Data
    .O_r_payload_id         ( io_r_payload_id     ) , //(O)[Read]   ID
    .O_r_payload_resp       ( io_r_payload_resp   ) , //(O)[Read]   Response
    .O_r_payload_last       ( io_r_payload_last   ) , //(O)[Read]   Data Last
//&&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif 
//&&&&&&&&&&&&&&&&&&&&&&&&&&&
    //calibration/Monitor Interface
    .O_Pll_Shift            ( shift       ) , //Pll Shift Value
    .O_Pll_Shift_Sel        ( shift_sel   ) , //Pll Shift Channel Select
    .O_Pll_Shift_Ena        ( shift_ena   ) , //Pll Shift Enable  
    /////////////   
    .I_Cal_Enable           ( 1'b1      ) , //Calibration Enable
    .O_Cal_Done             ( w_cal_done        ) , //Calibration Done
    .O_Cal_Pass             ( cal_pass        ) , //Calibration Pass
    .O_Cal_Fail_Log         ( Cal_Fail_Log    ) , //Calibration Fail Log
    .O_Cal_Shift_Val        ( Cal_Shift_Val   ) , //Calibration Shift Value
    //Hyper Bus Ram Interface
    .Ddr_reset              ( reset           ) , //(O)DDR Reset
    .Ddr_cs                 ( cs              ) , //(O)DDR Chip Select
    .Ddr_ras                ( ras             ) , //(O)DDR Row Address Select
    .Ddr_cas                ( cas             ) , //(O)DDR Column aAddress Select
    .Ddr_we                 ( we              ) , //(O)DDR Write
    .Ddr_cke                ( cke             ) , //(O)DDR Clock Enable
    .Ddr_addr               ( addr            ) , //(O)DDR Address
    .Ddr_ba                 ( ba              ) , //(O)DDR Bank Address
    .Ddr_odt                ( odt             ) , //(O)DDR ODT
    .Ddr_o_dm_hi            ( o_dm_hi         ) , //(O)DDR Data Mask Output (HI)
    .Ddr_o_dm_lo            ( o_dm_lo         ) , //(O)DDR Data Mask Output (LO)
    .Ddr_i_dqs_hi           ( i_dqs_hi        ) , //(I)DDR DQS Input (HI) 
    .Ddr_i_dqs_lo           ( i_dqs_lo        ) , //(I)DDR DQS Input (LO) 
    .Ddr_i_dqs_n_hi         ( i_dqs_n_hi      ) , //(I)DDR DQS Input (HI)
    .Ddr_i_dqs_n_lo         ( i_dqs_n_lo      ) , //(I)DDR DQS Input (LO)
    .Ddr_o_dqs_hi           ( o_dqs_hi        ) , //(O)DDR DQS output 
    .Ddr_o_dqs_lo           ( o_dqs_lo        ) , //(O)DDR DQS output 
    .Ddr_o_dqs_n_hi         ( o_dqs_n_hi      ) , //(O)DDR DQS output 
    .Ddr_o_dqs_n_lo         ( o_dqs_n_lo      ) , //(O)DDR DQS output 
    .Ddr_o_dqs_oe           ( o_dqs_oe        ) , //(O)DDR DQS 
    .Ddr_o_dqs_n_oe         ( o_dqs_n_oe      ) , //(O)DDR DQS 
    .Ddr_i_dq_hi            ( i_dq_hi         ) , //(I)DDR DQ Input (HI)
    .Ddr_i_dq_lo            ( i_dq_lo         ) , //(I)DDR DQ Input (LO)
    .Ddr_o_dq_hi            ( o_dq_hi         ) , //(O)DDR DQ Data Input (HI)
    .Ddr_o_dq_lo            ( o_dq_lo         ) , //(O)DDR DQ Data Input (LO)
    .Ddr_o_dq_oe            ( o_dq_oe         )   //(O)DDR DQ Data Output Enable
  );









endmodule