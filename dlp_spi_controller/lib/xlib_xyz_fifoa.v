
module xlib_xyz_fifoa #(parameter DW=32, FW=8, SYNC_STAGE=3, RRST_SYNC=0, WRST_SYNC=0)(
input rst_n,
input wclk,
input wreq,
input [DW-1:0] wd,
output wne,
output wnf,
output [FW-0:0] wcnt,
input rclk,
input rreq,
output [DW-1:0] rd,
output rne,
output rnf,
output [FW-0:0] rcnt);

wire wempty;
wire wfull;
wire rempty;
wire rfull;


localparam OPTIONAL_FLAGS = 0;
localparam SYNC_CLK = 0;
localparam DEPTH = 2**FW;
localparam DATA_WIDTH = DW;
localparam ASYM_WIDTH_RATIO = 4;
localparam MODE = "FWFT";
localparam OUTPUT_REG = 1;
localparam BYPASS_RESET_SYNC = 1;
localparam PROG_FULL_ASSERT = 128;
localparam PIPELINE_REG = 1;
localparam PROG_FULL_NEGATE = 128;
localparam EFX_SYNC_STAGE = 2;
localparam PROG_EMPTY_ASSERT = 0;
localparam PROG_EMPTY_NEGATE = 2;
localparam PROGRAMMABLE_FULL = "STATIC_SINGLE";
localparam PROGRAMMABLE_EMPTY = "NONE";
localparam FAMILY = "TITANIUM";



`ifdef EFINIX

wire efx_wempty;
wire efx_wfull;
wire efx_rempty;
reg exf_rfull;

// always@(posedge wclk or negedge rst_n)
//     if (!rst_n)
//         efx_wempty <= 1'b1;
//     else begin 
//         efx_wempty <= (wcnt==0) && (wreq==0);
//     end 

assign efx_wempty = (wcnt==0) && (wreq==0);

// always@(posedge rclk or negedge rst_n)
//     if (!rst_n)
//         exf_rfull <= 1'b0;
//     else begin 
//         exf_rfull <= (rcnt==DEPTH-1) && (rreq==0);
//     end 

assign exf_rfull = (rcnt==DEPTH-1);

assign wne = ~efx_wempty ;
assign wnf = ~efx_wfull;
assign rne = ~efx_rempty;
assign rnf = ~exf_rfull;

efx_dcfifo  #(
    .OPTIONAL_FLAGS(OPTIONAL_FLAGS),
    .SYNC_CLK(SYNC_CLK),
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ASYM_WIDTH_RATIO(ASYM_WIDTH_RATIO),
    .MODE(MODE),
    .OUTPUT_REG(OUTPUT_REG),
    .BYPASS_RESET_SYNC(BYPASS_RESET_SYNC),
    .PROG_FULL_ASSERT(PROG_FULL_ASSERT),
    .PIPELINE_REG(PIPELINE_REG),
    .PROG_FULL_NEGATE(PROG_FULL_NEGATE),
    .SYNC_STAGE(EFX_SYNC_STAGE),
    .PROG_EMPTY_ASSERT(PROG_EMPTY_ASSERT),
    .PROG_EMPTY_NEGATE(PROG_EMPTY_NEGATE),
    .PROGRAMMABLE_FULL(PROGRAMMABLE_FULL),
    .PROGRAMMABLE_EMPTY(PROGRAMMABLE_EMPTY),
    .FAMILY(FAMILY),
    .FW (FW)
)u_efx_dcfifo (
.almost_full_o (  ),
.prog_full_o (  ),
.full_o ( efx_wfull ),
.overflow_o (  ),
.wr_ack_o (  ),
.empty_o ( efx_rempty ),
.almost_empty_o (  ),
.underflow_o (  ),
.rd_valid_o (  ),
.rdata ( rd ),
.wr_clk_i ( wclk ),
.rd_clk_i ( rclk ),
.wr_en_i ( wreq & ~efx_wfull  ),
.rd_en_i ( rreq & ~efx_rempty ),
.wdata ( wd ),
.wr_datacount_o ( wcnt ),
.rd_datacount_o ( rcnt ),
.a_wr_rst_i ( ~rst_n ),
.rst_busy ( rst_busy ),
.a_rd_rst_i ( ~rst_n )
);


`else 


wire alt_wempty;
wire alt_wfull;
wire alt_rempty;
wire alt_rfull;

assign wne = ~alt_wempty ;
assign wnf = ~alt_wfull;
assign rne = ~alt_rempty;
assign rnf = ~alt_rfull;

dcfifo dcfifo_component (
.aclr (~rst_n),
.wrclk (wclk),
.wrreq (wreq & ~alt_wfull),
.data (wd),
.wrempty (alt_wempty),
.wrfull (alt_wfull),
.wrusedw (wcnt),
.rdclk (rclk),
.rdreq (rreq & ~alt_rempty),
.q (rd),
.rdempty (alt_rempty),
.rdfull (alt_rfull),
.rdusedw (rcnt),
.eccstatus ());

defparam
dcfifo_component.add_usedw_msb_bit = "ON",
dcfifo_component.intended_device_family = "Cyclone V",
dcfifo_component.lpm_numwords = 2**FW,
dcfifo_component.lpm_showahead = "ON",
dcfifo_component.lpm_type = "dcfifo",
dcfifo_component.lpm_width = DW,
dcfifo_component.lpm_widthu = FW+1,
dcfifo_component.overflow_checking = "OFF",
dcfifo_component.underflow_checking = "OFF",
dcfifo_component.use_eab = "ON",
dcfifo_component.rdsync_delaypipe = SYNC_STAGE+2,
dcfifo_component.wrsync_delaypipe = SYNC_STAGE+2,
dcfifo_component.read_aclr_synch  = RRST_SYNC ? "ON" : "OFF",
dcfifo_component.write_aclr_synch = WRST_SYNC ? "ON" : "OFF";


`endif 

endmodule
