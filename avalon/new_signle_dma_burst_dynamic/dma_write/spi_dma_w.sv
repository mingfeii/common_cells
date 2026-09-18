module spi_dma_w #(parameter AW=32, AL=2, BL=3, DW=8*(2**AL))(
    input clk,
    input rst_n,
    input bus_rst_n,
    input pio_adr_we,
    input [31:0] pio_d,
    input [BL:0] burstcount, // 外部输入的burst长度
    output [31:0] pio_adr,
    output dma_done,
    output dma_rdy,
    input dma_val,
    input dma_eof,
    input [DW-1:0] dma_d,
    input bus_wrdy,
    output bus_wval,
    output [BL-0:0] bus_wlen,
    output [AW-1:0] bus_waddr,
    output [DW-1:0] bus_wdata
);

    localparam FW=8; // hardware dependent
    wire dff_eof, dff_pop;
    wire [FW:0] dff_cnt;
    wire dff_rval;
    wire dff_eof_1;
    assign dff_eof = dff_eof_1 & dff_rval; // ensure eof is 0 if fifo empty

    xlib_xyz_fifo #(.DW(DW+1)) u_dff (
        .clk        (clk),
        .rst_n      (rst_n),
        .wrdy       (dma_rdy),
        .wval       (dma_val),
        .wd         ({dma_eof, dma_d}),
        .cnt        (dff_cnt),
        .rrdy       (dff_pop),
        .rval       (dff_rval),
        .rd         ({dff_eof_1, bus_wdata})
    );

    spi_dma_wc #(.AW(AW), .AL(AL), .BL(BL), .FW(FW), .ALWAYS_EN(1)) u_dma (
        .clk        (clk),
        .rst_n      (rst_n),
        .bus_rst_n  (bus_rst_n),
        .pio_adr_we (pio_adr_we),
        .pio_len_we (1'b0),
        .burstcount (burstcount),
        .pio_d      (pio_d),
        .pio_adr    (pio_adr),
        .pio_len    (),
        .pio_cst    (),
        .dff_cnt    (dff_cnt),
        .dff_rval   (dff_rval),
        .dff_eof    (dff_eof),
        .dff_ack    (dff_pop),
        .done       (dma_done),
        .biu_adr    (bus_waddr),
        .biu_len    (bus_wlen),
        .biu_sob    (),
        .biu_eob    (),
        .biu_val    (bus_wval),
        .biu_rdy    (bus_wrdy),
        .rsp_val    (1'bx)
    );

endmodule
