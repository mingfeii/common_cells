
module xlib_xyz_fifo #(parameter DW=32, FW=8, SYNC_RST=0)(
input clk,
input rst_n,
output wrdy,
input wval,
input [DW-1:0] wd,
input rrdy,
output rval,
output [DW-1:0] rd,
output [FW-0:0] cnt

);

wire full;
wire empty;


wire [FW-1:0] usedw;
assign wrdy = ~full;
assign rval = ~empty;
assign cnt = {full, usedw};


localparam   OPTIONAL_FLAGS                 = 0;
localparam   SYNC_CLK                       = 1;
localparam   DEPTH                          = 2**FW;
localparam   DATA_WIDTH                     = DW;
localparam   ASYM_WIDTH_RATIO               = 4;
localparam   MODE                           = "FWFT";
localparam   OUTPUT_REG                     = 1;
localparam   BYPASS_RESET_SYNC              = 0;
localparam   PROG_FULL_ASSERT               = 128;
localparam   PIPELINE_REG                   = 1;
localparam   PROG_FULL_NEGATE               = 128;
localparam   SYNC_STAGE                     = 2;
localparam   PROG_EMPTY_ASSERT              = 0;
localparam   PROG_EMPTY_NEGATE              = 2;
localparam   PROGRAMMABLE_FULL              = "NONE";
localparam   PROGRAMMABLE_EMPTY             = "NONE";
localparam   FAMILY                         = "TITANIUM";



`ifdef EFINIX 



efx_sc_fifo #(
    .OPTIONAL_FLAGS    (OPTIONAL_FLAGS    ),   
    .SYNC_CLK          (SYNC_CLK          ),   
    .DEPTH             (DEPTH             ),   
    .DATA_WIDTH        (DATA_WIDTH        ),   
    .ASYM_WIDTH_RATIO  (ASYM_WIDTH_RATIO  ),   
    .MODE              (MODE              ),   
    .OUTPUT_REG        (OUTPUT_REG        ),   
    .BYPASS_RESET_SYNC (BYPASS_RESET_SYNC ),   
    .PROG_FULL_ASSERT  (PROG_FULL_ASSERT  ),   
    .PIPELINE_REG      (PIPELINE_REG      ),   
    .PROG_FULL_NEGATE  (PROG_FULL_NEGATE  ),   
    .SYNC_STAGE        (SYNC_STAGE        ),   
    .PROG_EMPTY_ASSERT (PROG_EMPTY_ASSERT ),   
    .PROG_EMPTY_NEGATE (PROG_EMPTY_NEGATE ),   
    .PROGRAMMABLE_FULL (PROGRAMMABLE_FULL ),   
    .PROGRAMMABLE_EMPTY(PROGRAMMABLE_EMPTY),   
    .FAMILY            (FAMILY            ),
    .FW                (FW                )
) 

u_efx_sc_fifo(
.almost_full_o (  ),
.full_o ( full ),
.overflow_o (  ),
.wr_ack_o (  ),
.empty_o ( empty ),
.almost_empty_o (  ),
.underflow_o (  ),
.rd_valid_o (  ),
.rdata ( rd ),
.clk_i ( clk ),
.wr_en_i (  wval & ~full  ),
.rd_en_i ( rrdy & ~empty ),
.a_rst_i (  ~rst_n  ),
.wdata ( wd ),
.datacount_o ( usedw ),
.rst_busy (  )
);





`else  


scfifo scfifo_component (
.clock (clk),
.aclr (SYNC_RST ? 1'b0 : ~rst_n),
.sclr (SYNC_RST ? ~rst_n : 1'b0),
.usedw (usedw),
.full (full),
.empty (empty),
.wrreq (wval & ~full),
.rdreq (rrdy & ~empty),
.data (wd),
.q (rd),
.almost_empty (),
.almost_full ()
//.eccstatus ()
);

defparam
scfifo_component.add_ram_output_register = "ON",
scfifo_component.intended_device_family = "Cyclone V",
scfifo_component.lpm_numwords = 2**FW,
scfifo_component.lpm_showahead = "ON",
scfifo_component.lpm_type = "scfifo",
scfifo_component.lpm_width = DW,
scfifo_component.lpm_widthu = FW,
scfifo_component.overflow_checking = "OFF",
scfifo_component.underflow_checking = "OFF",
scfifo_component.use_eab = "ON";


`endif 



endmodule
