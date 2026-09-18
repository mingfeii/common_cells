

module ddr_slave_wrapper #(
    parameter DATA_WIDTH   = 128,
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 8,
    parameter AWUSER_WIDTH = 1,
    parameter WUSER_WIDTH  = 1,
    parameter BUSER_WIDTH  = 1,
    parameter ARUSER_WIDTH = 1,
    parameter RUSER_WIDTH  = 1,
    parameter WR_FW = 3,
    parameter RD_FW = 4
)(
    input                                 aclk,
    input                                 aresetn,

//DDR controler interface
    input  logic  						  wr_busy,
    output logic  [DATA_WIDTH-1:0]	      wr_data,
    output logic  [DATA_WIDTH / 8 - 1:0]  wr_datamask,
    output logic  [31:0]				  wr_addr,
    output logic  						  wr_en,
    output logic 						  wr_addr_en,
    input  logic 						  wr_ack,
    input  logic 						  rd_busy,
    output logic   [31:0] 				  rd_addr,
    output logic   						  rd_addr_en,
    output logic  						  rd_en,
    input  logic  [DATA_WIDTH-1:0]	      rd_data,
    input  logic  						  rd_valid,
    input  logic  					      rd_ack ,
//AXI SLAVE interface 
    input  logic [ID_WIDTH - 1 : 0]       awid,
    input  logic [ADDR_WIDTH - 1 : 0]     awaddr,
    input  logic [7 : 0]                  awlen,
    input  logic [2 : 0]                  awsize,
    input  logic [1 : 0]                  awburst,
    input  logic                          awlock,
    input  logic [3 : 0]                  awcache,
    input  logic [2 : 0]                  awprot,
    input  logic [3 : 0]                  awqos,
    input  logic [3 : 0]                  awregion,
    input  logic [AWUSER_WIDTH - 1 : 0]   awuser,
    input  logic                          awvalid,
    output logic                          awready,

    input  logic [DATA_WIDTH - 1 : 0]     wdata,
    input  logic [DATA_WIDTH / 8 - 1 : 0] wstrb,
    input  logic                          wlast,
    input  logic [WUSER_WIDTH - 1 : 0]    wuser,
    input  logic                          wvalid,
    output logic                          wready,

    output logic [ID_WIDTH - 1 : 0]       bid,
    output logic [1 : 0]                  bresp,
    output logic [BUSER_WIDTH - 1 : 0]    buser,
    output logic                          bvalid,
    input  logic                          bready,

    input  logic [ID_WIDTH - 1 : 0]       arid,
    input  logic [ADDR_WIDTH - 1 : 0]     araddr,
    input  logic [7 : 0]                  arlen,
    input  logic [2 : 0]                  arsize,
    input  logic [1 : 0]                  arburst,
    input  logic                          arlock,
    input  logic [3 : 0]                  arcache,
    input  logic [2 : 0]                  arprot,
    input  logic [3 : 0]                  arqos,
    input  logic [3 : 0]                  arregion,
    input  logic [ARUSER_WIDTH - 1 : 0]   aruser,
    input  logic                          arvalid,
    output logic                          arready,

    output logic [ID_WIDTH - 1 : 0]       rid,
    output logic [DATA_WIDTH - 1 : 0]     rdata,
    output logic [1 : 0]                  rresp,
    output logic                          rlast,
    output logic [RUSER_WIDTH - 1 : 0]    ruser,
    output logic                          rvalid,
    input  logic                          rready

);


localparam  AXI4_RESP_OKAY    = 2'b00;
localparam  AXI4_RESP_EXOKAY  = 2'b01;
localparam  AXI4_RESP_SLVERR  = 2'b10;
localparam  AXI4_RESP_DECERR  = 2'b11;
localparam  WR_FIFO_DEPTH = 2**WR_FW;
localparam  RD_FIFO_DEPTH = 2**RD_FW;



localparam STRB_WIDTH = (DATA_WIDTH/8);
localparam VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);


logic     wr_en_nxt;
logic     wr_addr_en_nxt;
reg         [7:0]		      decode_wsize;
reg  [7:0]		              decode_rsize; 

logic     rd_addr_en_nxt;
logic     rd_en_nxt;
// logic [ADDR_WIDTH-1:0] rd_addr_nxt;
logic [ID_WIDTH-1:0] rid_nxt; 
logic     rlast_nxt; 
logic [DATA_WIDTH-1:0] rdata_nxt;     
logic rvalid_nxt;
//写地址通道:awaddr+awlen+awsize+aw_incr+awid+awburst
localparam AW_FIFO_DW = ADDR_WIDTH + 8 + 3  + ID_WIDTH + 2;

logic                         awff_write;
logic [AW_FIFO_DW-1:0]        awff_wdata;
logic                         awff_read;
logic [AW_FIFO_DW-1:0]        awff_rdata;
logic                         awff_full;
logic                         awff_empty;
logic     [ADDR_WIDTH-1:0]    i_awadrs ; 
logic     [7:0]               i_awlen  ; 
logic     [ 2:0]              i_awsize ;
logic     [7:0]               i_aw_incr;         
logic     [ID_WIDTH-1:0]      i_awid   ; 
logic             [ 1:0]      i_awburst; 

assign awff_wdata = {awaddr,awlen,awsize,awid,awburst};
assign awff_write = awvalid & awready;
assign awready  = !awff_full;
assign {i_awadrs,i_awlen,i_awsize,i_awid,i_awburst} = awff_rdata;

//  sc_fifo #(
//   .DATA_WIDTH(AW_FIFO_DW),
//   .WORDS_AMOUNT(FIFO_DEPWORD)
// )aw_fifo_U (
//   .clk_i       (aclk                ),
//   .rst_i       (~aresetn            ),
//   .wr_i        (awff_write          ),
//   .wr_data_i   (awff_wdata          ),
//   .rd_i        (awff_read           ),
//   .rd_data_o   (awff_rdata          ),
//   .used_words_o(                    ),
//   .full_o      (awff_full           ),
//   .empty_o     (awff_empty          )    
// );

efx_sc_fifo #(
    .DEPTH             (WR_FIFO_DEPTH     ),   
    .DATA_WIDTH        (AW_FIFO_DW        ),   
    .FW                (WR_FW                )
) 

aw_fifo_U(
.almost_full_o (  ),
.full_o ( awff_full ),
.overflow_o (  ),
.wr_ack_o (  ),
.empty_o ( awff_empty ),
.almost_empty_o (  ),
.underflow_o (  ),
.rd_valid_o (  ),
.rdata ( awff_rdata ),
.clk_i ( aclk ),
.wr_en_i (  awff_write  ),
.rd_en_i (awff_read ),
.a_rst_i (  ~aresetn   ),
.wdata ( awff_wdata ),
.datacount_o (  ),
.rst_busy (  )
);





//写数据通道:wdata+wstrb+wlast
localparam W_FIFO_DW = DATA_WIDTH + DATA_WIDTH/8 + 1;

logic                    wff_write;
logic [W_FIFO_DW-1:0]    wff_wdata;
logic                    wff_read;
logic [W_FIFO_DW-1:0]    wff_rdata;
logic                    wff_full;
logic                    wff_empty;
logic     [DATA_WIDTH-1:0]  i_wdata; 
logic   [DATA_WIDTH/8-1:0]  i_wstrb; 
logic                       i_wlast; 
assign wff_wdata = {wdata,wstrb,wlast};
assign wff_write = wvalid & wready;
assign wready = ~wff_full;
assign {i_wdata,i_wstrb,i_wlast} = wff_rdata;

//  sc_fifo #(
//   .DATA_WIDTH(W_FIFO_DW),
//   .WORDS_AMOUNT(FIFO_DEPWORD)
// )w_fifo_U (
//   .clk_i       (aclk                ),
//   .rst_i       (~aresetn            ),
//   .wr_i        (wff_write           ),
//   .wr_data_i   (wff_wdata           ),
//   .rd_i        (wff_read            ),
//   .rd_data_o   (wff_rdata           ),
//   .used_words_o(                    ),
//   .full_o      (wff_full           ),
//   .empty_o     (wff_empty            )    
// );


efx_sc_fifo #(
    .DEPTH             (WR_FIFO_DEPTH     ),   
    .DATA_WIDTH        (W_FIFO_DW        ),   
    .FW                (WR_FW                )
) 

w_fifo_U(
.almost_full_o (  ),
.full_o ( wff_full ),
.overflow_o (  ),
.wr_ack_o (  ),
.empty_o ( wff_empty ),
.almost_empty_o (  ),
.underflow_o (  ),
.rd_valid_o (  ),
.rdata ( wff_rdata ),
.clk_i ( aclk ),
.wr_en_i (  wff_write  ),
.rd_en_i (wff_read ),
.a_rst_i (  ~aresetn   ),
.wdata ( wff_wdata ),
.datacount_o (  ),
.rst_busy (  )
);



//写响应通道：
localparam B_DW = ID_WIDTH + 2;
logic                 bff_write;
logic  [B_DW-1:0]     bff_wdata;
logic                 bff_read;
logic  [B_DW-1:0]     bff_rdata;
logic                 bff_full;
logic                 bff_empty;

assign bff_write = wff_read & i_wlast; //Give respsonse when we read last data burst from FIFO  
assign bff_read = bvalid & bready;
assign bff_wdata = {AXI4_RESP_OKAY,i_awid}; //always return B OKAY
assign bvalid  = !bff_empty;
assign {bresp,bid} = bff_rdata;

//  sc_fifo #(
//   .DATA_WIDTH(B_DW),
//   .WORDS_AMOUNT(FIFO_DEPWORD)
//  )b_fifo_U (
//   .clk_i       (aclk                ),
//   .rst_i       (~aresetn            ),
//   .wr_i        (bff_write           ),
//   .wr_data_i   (bff_wdata           ),
//   .rd_i        (bff_read            ),
//   .rd_data_o   (bff_rdata           ),
//   .used_words_o(                    ),
//   .full_o      (bff_full            ),
//   .empty_o     (bff_empty           )    
// );


efx_sc_fifo #(
    .DEPTH             (WR_FIFO_DEPTH     ),   
    .DATA_WIDTH        (B_DW              ),   
    .FW                (WR_FW                )
) 

b_fifo_U(
.almost_full_o (  ),
.full_o ( bff_full ),
.overflow_o (  ),
.wr_ack_o (  ),
.empty_o ( bff_empty ),
.almost_empty_o (  ),
.underflow_o (  ),
.rd_valid_o (  ),
.rdata ( bff_rdata ),
.clk_i ( aclk ),
.wr_en_i (  bff_write  ),
.rd_en_i (bff_read ),
.a_rst_i (  ~aresetn   ),
.wdata ( bff_wdata ),
.datacount_o (  ),
.rst_busy (  )
);



logic [ADDR_WIDTH-1:0] write_adrs,nxt_write_adrs;
logic [7:0]            write_count,nxt_write_count; 


enum int unsigned {WR_IDLE,WR_BURST} write_state,nxt_write_state;


assign wr_addr = write_adrs >> (ADDR_WIDTH - VALID_ADDR_WIDTH);


reg [2:0] awsize_reg,awsize_reg_nxt;

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn)
        awsize_reg <= 0;
    else if (write_state==WR_IDLE)
        awsize_reg <= awsize_reg_nxt;

always_comb 
begin
    case(awsize_reg)
    3'h0:decode_wsize    = 8'd1;
    3'h1:decode_wsize    = 8'd2;
    3'h2:decode_wsize    = 8'd4;
    3'h3:decode_wsize    = 8'd8;
    3'h4:decode_wsize    = 8'd16;
    3'h5:decode_wsize    = 8'd32;
    3'h6:decode_wsize    = 8'd64;
    3'h7:decode_wsize    = 8'd128;
    default:decode_wsize = 8'd1;
    endcase
end

always_ff@(posedge aclk or negedge aresetn)
    if (~aresetn) begin
        write_state <= WR_IDLE;
        write_adrs  <= 0;
        write_count <= 0;
        wr_en <= 1'b0;
        wr_addr_en <= 1'b0;
        wr_data <= '0;
        wr_datamask <= '0;
    end else begin
        write_state <= nxt_write_state;
        write_adrs  <= nxt_write_adrs;
        write_count <= nxt_write_count;
        wr_en <= wr_en_nxt;
        wr_addr_en <= wr_addr_en_nxt;
        wr_data <= i_wdata;
        wr_datamask <= ~i_wstrb;
    end

always_comb begin 
    awff_read = 1'b0;
    wff_read  = 1'b0;
    wr_en_nxt = 1'b0;
    wr_addr_en_nxt = 1'b0;
    awsize_reg_nxt = awsize_reg;
    nxt_write_state = write_state;
    nxt_write_count = write_count;
    nxt_write_adrs  = write_adrs;
    case(write_state)
    WR_IDLE: begin 
        if (!awff_empty & !wff_empty & !wr_busy) begin
            wr_addr_en_nxt = 1'b1;
            wr_en_nxt = 1'b1;
            wff_read = 1'b1;
            nxt_write_adrs = i_awadrs;
            awsize_reg_nxt = i_awsize;
            if (i_awlen==0) begin 
                awff_read = 1'b1;
                nxt_write_state = WR_IDLE;
            end else begin 
                nxt_write_count = i_awlen-1;
                nxt_write_state = WR_BURST;
                // nxt_write_adrs = i_awadrs  + (1 << i_awsize); 
            end 
            end 
        end
    WR_BURST:begin 
        if (!wff_empty & !wr_busy) begin 
            wr_addr_en_nxt = 1'b1;
            wff_read = 1'b1;
            wr_en_nxt = 1'b1;
            nxt_write_count = write_count-1;
            nxt_write_adrs = write_adrs  + decode_wsize; 
            if (write_count==0) begin
                awff_read = 1'b1;
                nxt_write_state = WR_IDLE;
            end 
        end
    end 
    default:nxt_write_state=WR_IDLE;
endcase   
end



//通道:araddr+arlen+arsize+ar_incr+arid+arburst
localparam AR_DW = ADDR_WIDTH + 8 + 3 + ID_WIDTH + 2;

logic                       arff_write;
logic  [AR_DW-1:0]          arff_wdata;
logic                       arff_read;
logic  [AR_DW-1:0]          arff_rdata;
logic                       arff_full;
logic                       arff_empty;
logic  [ADDR_WIDTH-1:0]     i_aradrs ; 
logic     [7:0]             i_arlen  ; 
logic             [ 2:0]    i_arsize ;
logic   [7:0]               i_ar_incr; 
logic      [ID_WIDTH-1:0]   i_arid   ; 
logic             [ 1:0]    i_arburst; 



assign arff_wdata = {araddr,arlen,arsize,arid,arburst};
assign arff_write = arvalid & arready;
assign arready  = !arff_full;
assign {i_aradrs,i_arlen,i_arsize,i_arid,i_arburst} = arff_rdata;


//  sc_fifo #(
//   .DATA_WIDTH(AR_DW),
//   .WORDS_AMOUNT(FIFO_DEPWORD)
//  )ar_fifo_U (
//   .clk_i       (aclk                 ),
//   .rst_i       (~aresetn             ),
//   .wr_i        (arff_write           ),
//   .wr_data_i   (arff_wdata           ),
//   .rd_i        (arff_read            ),
//   .rd_data_o   (arff_rdata           ),
//   .used_words_o(                     ),
//   .full_o      (arff_full            ),
//   .empty_o     (arff_empty           )    
// );


efx_sc_fifo #(
    .DEPTH             (RD_FIFO_DEPTH     ),   
    .DATA_WIDTH        (AR_DW              ),   
    .FW                (RD_FW                )
) 

ar_fifo_U(
.almost_full_o (  ),
.full_o ( arff_full ),
.overflow_o (  ),
.wr_ack_o (  ),
.empty_o ( arff_empty ),
.almost_empty_o (  ),
.underflow_o (  ),
.rd_valid_o (  ),
.rdata ( arff_rdata ),
.clk_i ( aclk ),
.wr_en_i (  arff_write  ),
.rd_en_i (arff_read ),
.a_rst_i (  ~aresetn   ),
.wdata ( arff_wdata ),
.datacount_o (  ),
.rst_busy (  )
);



logic   [ADDR_WIDTH-1:0] read_adrs,nxt_read_adrs;
logic   [7:0]            read_count,nxt_read_count; //addr count
logic   [7:0]            read_data_count,nxt_read_data_count;
logic                    addr_rd_lock,addr_rd_lock_nxt;

enum int unsigned {RD_IDLE,RD_SINGLE,RD_BURST} read_state,nxt_read_state;

assign rd_addr = read_adrs >> (ADDR_WIDTH - VALID_ADDR_WIDTH);


reg [2:0] arsize_reg,arsize_reg_nxt;

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn)
        arsize_reg <= 0;
    else if (read_state==RD_IDLE)
        arsize_reg <= arsize_reg_nxt;

always_comb 
begin
    case(arsize_reg)
    3'h0:decode_rsize     = 8'd1;
    3'h1:decode_rsize     = 8'd2;
    3'h2:decode_rsize     = 8'd4;
    3'h3:decode_rsize     = 8'd8;
    3'h4:decode_rsize     = 8'd16;
    3'h5:decode_rsize     = 8'd32;
    3'h6:decode_rsize     = 8'd64;
    3'h7:decode_rsize     = 8'd128;
    default:decode_rsize  = 8'd1;
    endcase
end


always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn) begin
        read_state <= RD_IDLE;
        read_adrs  <= 0;
        read_count <= 0;         
        read_data_count <= 0;
        rd_addr_en <= 1'b0;
        rid <= 0;
        rlast <= 1'b0;
        rdata <= 0;
        rvalid <= 1'b0;
    end else begin    
        read_state <= nxt_read_state;
        read_adrs  <= nxt_read_adrs;
        read_count <= nxt_read_count;
        read_data_count <= nxt_read_data_count;
        rd_addr_en <= rd_addr_en_nxt;
        rid <= rid_nxt;
        rlast <= rlast_nxt;
        rdata <= rd_data;
        rvalid <= rvalid_nxt;
    end

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn)
        addr_rd_lock <= 1'b0;
    else if (read_state==RD_IDLE)   
        addr_rd_lock <= 1'b0;
    else if (addr_rd_lock_nxt==1'b1)
        addr_rd_lock <= 1'b1;


assign rd_en = 1'b1;


always_comb begin 
    rd_addr_en_nxt = 1'b0;
    arff_read = 1'b0;
    rid_nxt = rid;
    rlast_nxt = '0;
    rresp = 0;
    rvalid_nxt = 1'b0;
    addr_rd_lock_nxt = 1'b0;
    arsize_reg_nxt = arsize_reg;
    nxt_read_data_count = read_data_count;
    nxt_read_state = read_state;
    nxt_read_count = read_count;
    nxt_read_adrs  = read_adrs;
    case (read_state)
        RD_IDLE:begin 
            if (!arff_empty) begin 
                nxt_read_adrs = i_aradrs;
                arsize_reg_nxt = i_arsize;
                rid_nxt = i_arid;
                if (i_arlen==0)
                    nxt_read_state = RD_SINGLE;
                else begin 
                    nxt_read_count = i_arlen;
                    nxt_read_data_count = i_arlen;
                    nxt_read_state = RD_BURST;    
                end
            end  
        end
        RD_SINGLE:begin 
            if (!rd_busy && rready) rd_addr_en_nxt = 1'b1;
            if (rd_valid)begin 
                rvalid_nxt = 1'b1;
                rlast_nxt  = 1'b1;
                arff_read = 1'b1;
                nxt_read_state = RD_IDLE; 
            end  
        end
        RD_BURST:begin
            if (!rd_busy && rready && !addr_rd_lock) begin 
                rd_addr_en_nxt = 1'b1;
                nxt_read_count = read_count-1;
                if (read_count==0) begin
                    addr_rd_lock_nxt = 1'b1;
                end

            end

            if (rd_addr_en) nxt_read_adrs = read_adrs + decode_rsize;

            if (rd_valid) begin 
                rvalid_nxt = 1'b1;
                nxt_read_data_count = read_data_count - 1;
                if (read_data_count==0) begin 
                    rlast_nxt = 1'b1;
                    arff_read = 1'b1;
                    nxt_read_state =RD_IDLE;
            end 
            end  
            end
    
        default:begin 
            nxt_read_state = RD_IDLE;
        end 


    endcase
end



endmodule

