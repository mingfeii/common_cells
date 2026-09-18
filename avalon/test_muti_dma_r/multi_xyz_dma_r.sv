
module multi_xyz_dma_r #( 
    parameter AW=32,
    parameter AL=2, 
    parameter BL=3, 
    parameter LW=24,
    parameter CH = 5,
    parameter CW=$clog2(CH+1),
    parameter DW=8*(2**AL)
)
(
    input                   clk,
    input                   rst_n,
    input                   bus_rst_n,
    input  [CH-1:0]         pio_adr_we,
    input  [CH-1:0]         pio_len_we,
    //config channel of dma read port
    input [CW-1:0]          nch,
    //cpu interface 
    input [31:0]            pio_d,
    output [CH-1:0][31:0]   pio_adr,
    output [CH-1:0][31:0]   pio_len,
    // handshake to next level
    output  [CH-1:0]        dma_done,
    output  [CH-1:0]        dma_err,
    input   [CH-1:0]        dma_rdy,
    output  [CH-1:0]        dma_val,
    output  [CH-1:0]        dma_eof,
    output  [CH-1:0][DW-1:0]dma_d,
    //dma bus interface 
    input                   bus_rrdy,
    output                  bus_rval,
    output [BL-0:0]         bus_rlen,
    output [AW-1:0]         bus_raddr,
    input [DW-1:0]          bus_rdata,
    input                   bus_rdval
);

localparam FW=8; // hardware dependent



multi_dma_rc_bst #( 
    .AL(AL),
    .AW(AW),
    .DW(DW),
    .BL(BL),
    .FW(FW),
    .LW(LW),
    .CH(CH)
)u_dma(
.clk        (clk),
.rst_n      (rst_n),
.bus_rst_n  (bus_rst_n),
.done       (dma_done),
.err        (dma_err),
.biu_adr    (bus_raddr),
.biu_len    (bus_rlen),
.biu_req    (bus_rval),
.biu_ack    (bus_rval & bus_rrdy),
.nch        (nch),

.pio_len_we (pio_len_we),
.pio_adr_we (pio_adr_we),
.pio_d      (pio_d),
.rsp_val    (bus_rdval),
.bus_rdata  (bus_rdata), 
.pio_adr    (pio_adr),
.pio_len    (pio_len),

.dma_rdy    (dma_rdy ),
.dma_val    (dma_val ),
.dma_eof    (dma_eof ),
.dma_d      (dma_d   )    
);





endmodule
