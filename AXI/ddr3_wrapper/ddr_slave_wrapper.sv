

module ddr_slave_wrapper #(
    parameter DATA_WIDTH   = 128,
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 8,
    parameter FW = 3
)(
    input                                 aclk,
    input                                 aresetn,

//DDR controler interface
    input  logic                          wr_busy,
    output logic  [DATA_WIDTH-1:0]        wr_data,
    output logic  [DATA_WIDTH / 8 - 1:0]  wr_datamask,
    output logic  [31:0]                  wr_addr,
    output logic                          wr_en,
    output logic                          wr_addr_en,
    input  logic                          wr_ack,
    input  logic                          rd_busy,
    output logic  [31:0]                  rd_addr,
    output logic                          rd_addr_en,
    output logic                          rd_en,
    input  logic  [DATA_WIDTH-1:0]        rd_data,
    input  logic                          rd_valid,
    input  logic                          rd_ack ,
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
    input  logic                          awvalid,
    output logic                          awready,

    input  logic [DATA_WIDTH - 1 : 0]     wdata,
    input  logic [DATA_WIDTH / 8 - 1 : 0] wstrb,
    input  logic                          wlast,
    input  logic                          wvalid,
    output logic                          wready,

    output logic [ID_WIDTH - 1 : 0]       bid,
    output logic [1 : 0]                  bresp,
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
    input  logic                          arvalid,
    output logic                          arready,

    output logic [ID_WIDTH - 1 : 0]       rid,
    output logic [DATA_WIDTH - 1 : 0]     rdata,
    output logic [1 : 0]                  rresp,
    output logic                          rlast,
    output logic                          rvalid,
    input  logic                          rready

);


function reg[7:0] decode_size;
    input [2:0] axsize;

    case (axsize)
        3'b000: decode_size = 8'b00000001;
        3'b001: decode_size = 8'b00000010;
        3'b010: decode_size = 8'b00000100;
        3'b011: decode_size = 8'b00001000;
        3'b100: decode_size = 8'b00010000;
        3'b101: decode_size = 8'b00100000;
        3'b110: decode_size = 8'b01000000;
        3'b111: decode_size = 8'b10000000;
        default:decode_size = 8'b00000001;
    endcase

endfunction

localparam  AXI4_RESP_OKAY    = 2'b00;
localparam STRB_WIDTH = (DATA_WIDTH/8);
localparam VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);
localparam FIFO_DEPTH = 2 ** FW;

//WRITE CHANNEL 
reg         [7:0]		      decode_wsize;
reg         [7:0]		      decode_rsize; 
reg         [ID_WIDTH-1:0]    write_id_reg,write_id_nxt;

logic  [ID_WIDTH-1:0]         bid_nxt;
logic                         bvalid_nxt;
logic                         awready_nxt;
logic                         wready_nxt,wready_pre;
reg [2:0]                     awsize_reg,awsize_reg_nxt;

logic [ADDR_WIDTH-1:0] write_addr,write_addr_nxt;
logic [7:0]            write_count,write_count_nxt; 

enum int unsigned {WR_IDLE,WR_BURST,WRITE_RESP} write_state,write_state_nxt;

always_ff@(posedge aclk or negedge aresetn)
    if (~aresetn) begin
        write_state <= WR_IDLE;
        write_addr  <= 0;
        write_count <= 0;
        awready <= 1'b0;
        wready_pre <= 1'b0;
        bid <= 0;
        bvalid <=1'b0;
        write_id_reg <= 0;
        awsize_reg <= 0;
    end else begin
        awsize_reg <= awsize_reg_nxt;
        write_state <= write_state_nxt;
        write_addr  <= write_addr_nxt;
        write_count <= write_count_nxt;
        awready <= awready_nxt;
        wready_pre <= wready_nxt;
        bid <= bid_nxt;
        bvalid <= bvalid_nxt;
        write_id_reg <= write_id_nxt;
    end

assign bresp = AXI4_RESP_OKAY;
assign decode_wsize = decode_size(awsize_reg);
assign wready = wready_pre & ~wr_busy;
assign wr_data = wdata;
assign wr_datamask = ~wstrb;
assign wr_addr = write_addr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
assign wr_en = wvalid & wready;
assign wr_addr_en = wvalid & wready;

always_comb begin 
    awready_nxt = 1'b0;
    wready_nxt = 1'b0;
    write_id_nxt= write_id_reg;
    bid_nxt = bid;
    bvalid_nxt = 1'b0;
    awsize_reg_nxt = awsize_reg;
    write_state_nxt = write_state;
    write_count_nxt = write_count;
    write_addr_nxt  = write_addr;
    case(write_state)
    WR_IDLE: begin 
        awready_nxt = ~wr_busy;
        if (awvalid && awready) begin
            write_addr_nxt = awaddr;
            awsize_reg_nxt = awsize;
            write_id_nxt = awid;
            write_count_nxt = awlen;
            awready_nxt = 1'b0;
            write_state_nxt = WR_BURST;
        end else  
            write_state_nxt = WR_IDLE;
        end
    WR_BURST:begin 
        wready_nxt = ~wr_busy;
        if (wvalid && wready) begin 
            write_addr_nxt = write_addr  + decode_wsize; 
            write_count_nxt = write_count-1;
            if (write_count > 0) begin 
                write_state_nxt = WR_BURST;
            end else  begin 
                wready_nxt = 1'b0;
                bid_nxt = write_id_reg;
                write_state_nxt = WRITE_RESP;
                end 
        end else begin 
                write_state_nxt = WR_BURST;
            end 
        end 
    WRITE_RESP: begin 
        bvalid_nxt = 1'b1;
        if (bready && bvalid) begin 
            bvalid_nxt = 1'b0;
            write_state_nxt = WR_IDLE;
        end else begin 
            write_state_nxt = WRITE_RESP;
        end 
    end 

    default:write_state_nxt=WR_IDLE;
    endcase 
end 

//READ ADDRESS CHANNEL 
logic [7:0] read_addr_count;
logic [ADDR_WIDTH-1:0] read_addr;
logic [ID_WIDTH-1:0] rid_reg;
logic [3:0] arsize_reg;
wire  [FW-1:0] datacount_o_1,datacount_o_2;
// fifo : save arlen count and rid
localparam AR_DW = 8 + ID_WIDTH;//arlen++arid

logic                       arff_write;
logic  [AR_DW-1:0]          arff_wdata;
logic                       arff_read;
logic  [AR_DW-1:0]          arff_rdata;
logic                       arff_full;
logic                       arff_empty;
logic  [7:0]                i_ar_count  ; 
logic  [ID_WIDTH-1:0]       i_arid   ; 

logic                       ff_rd_write;
logic [DATA_WIDTH-1:0]      ff_rd_wdata;
logic                       ff_rd_read;
logic [DATA_WIDTH-1:0]      ff_rd_rdata;
logic                       ff_rd_full;
logic                       ff_rd_empty;

enum int unsigned {RD_ADDR_IDLE,RD_ADDR_PUSH} rd_addr_state,rd_addr_state_nxt;

assign arready = !rd_busy && rd_addr_state==RD_ADDR_IDLE && !arff_full;
assign rd_addr_en = rd_addr_state==RD_ADDR_PUSH && !rd_busy && !arff_full && rready;
assign rd_en = 1'b1;
assign rd_addr = read_addr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
assign rresp = AXI4_RESP_OKAY;
assign decode_rsize = decode_size(arsize_reg);

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn) begin 
        rid_reg <= 0;
        read_addr_count <= 0;
        arsize_reg <= 0;
    end else if (arready && arvalid) begin 
        read_addr_count <= arlen;
        rid_reg <= arid;
        arsize_reg <= arsize;
    end else if (rd_addr_en) begin 
        read_addr_count <= read_addr_count - 1'b1;
        rid_reg <= rid_reg;
        arsize_reg <= arsize_reg;
    end 

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn)
        read_addr <= 0;
    else if (arready && arvalid)
        read_addr <= araddr;
    else if (rd_addr_en)
        read_addr <= read_addr + decode_rsize;

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn)
        rd_addr_state <= RD_ADDR_IDLE;
    else 
        rd_addr_state <= rd_addr_state_nxt;

always_comb begin 
    rd_addr_state_nxt = rd_addr_state;
    case (rd_addr_state)
        RD_ADDR_IDLE: begin 
            if (arvalid && arready)
                rd_addr_state_nxt = RD_ADDR_PUSH;
        end 
        RD_ADDR_PUSH:begin 
            if (rd_addr_en && read_addr_count==0)
                rd_addr_state_nxt = RD_ADDR_IDLE;
        end 
    endcase 
end 


assign arff_wdata = {read_addr_count,rid_reg};
assign arff_write = rd_addr_en;
assign {i_ar_count,i_arid} = arff_rdata;
assign arff_read = ff_rd_read;

efx_sc_fifo #(
.DEPTH             (FIFO_DEPTH),   
.DATA_WIDTH        (AR_DW     ),   
.FW                (FW        )
) 
ar_fifo_U(
.almost_full_o  (               ),
.full_o         ( arff_full     ),
.overflow_o     (               ),
.wr_ack_o       (               ),
.empty_o        ( arff_empty    ),
.almost_empty_o (               ),
.underflow_o    (               ),
.rd_valid_o     (               ),
.rdata          ( arff_rdata    ),
.clk_i          ( aclk          ),
.wr_en_i        ( arff_write    ),
.rd_en_i        ( arff_read     ),
.a_rst_i        ( ~aresetn      ),
.wdata          ( arff_wdata    ),
.datacount_o    ( datacount_o_1 ),
.rst_busy       (               )
);

efx_sc_fifo #(
.DEPTH             (FIFO_DEPTH   ),   
.DATA_WIDTH        (DATA_WIDTH   ),   
.FW                (FW           )
) 
rdata_fifo(
.almost_full_o  (               ),
.full_o         ( ff_rd_full    ),
.overflow_o     (               ),
.wr_ack_o       (               ),
.empty_o        ( ff_rd_empty   ),
.almost_empty_o (               ),
.underflow_o    (               ),
.rd_valid_o     (               ),
.rdata          ( ff_rd_rdata   ),
.clk_i          ( aclk          ),
.wr_en_i        ( ff_rd_write   ),
.rd_en_i        ( ff_rd_read    ),
.a_rst_i        ( ~aresetn      ),
.wdata          ( ff_rd_wdata   ),
.datacount_o    ( datacount_o_2 ),
.rst_busy       (               )
);

assign ff_rd_write = rd_valid;
assign ff_rd_wdata = rd_data;
assign ff_rd_read = ~ff_rd_empty && ~arff_empty && rready ;
assign rvalid = ~ff_rd_empty && ~arff_empty;
assign rid = i_arid;
assign rlast = i_ar_count==0 && ff_rd_read;
assign rdata = ff_rd_rdata;



endmodule

