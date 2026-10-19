// FIFO Style #2 is an ADVANCED STUDY model, not a portable synthesis recipe.
// Uses Gray addresses for RAM, exactly as in the second paper's topology.
`default_nettype none

module async_fifo_style2 #(
    parameter integer DATA_WIDTH = 8,
    parameter integer ADDR_WIDTH = 4
) (
    input  wire                        wclk,
    input  wire                        wrst_n,
    input  wire                        winc,
    input  wire [DATA_WIDTH - 1:0]     wdata,
    output wire                        wfull,

    input  wire                        rclk,
    input  wire                        rrst_n,
    input  wire                        rinc,
    output wire [DATA_WIDTH - 1:0]     rdata,
    output wire                        rempty
);

    wire [ADDR_WIDTH - 1:0]     wgray;
    wire [ADDR_WIDTH - 1:0]     rgray;
    wire                        aempty_n;
    wire                        afull_n;
    s2_async_cmp #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_cmp (
        .wgray    (wgray),
        .rgray    (rgray),
        .wrst_n   (wrst_n),
        .aempty_n (aempty_n),
        .afull_n  (afull_n)
    );

    s2_write_ptr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_wptr (
        .wclk    (wclk),
        .wrst_n  (wrst_n),
        .winc    (winc),
        .afull_n (afull_n),
        .wgray   (wgray),
        .wfull   (wfull)
    );

    s2_read_ptr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_rptr (
        .rclk     (rclk),
        .rrst_n   (rrst_n),
        .rinc     (rinc),
        .aempty_n (aempty_n),
        .rgray    (rgray),
        .rempty   (rempty)
    );

    // Unlike the paper's original top, block RAM writes while full internally.
    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_mem (
        .wclk     (wclk),
        .write_en (wrst_n && winc && !wfull),
        .wdata    (wdata),
        .waddr    (wgray),
        .raddr    (rgray),
        .rdata    (rdata)
    );

    initial begin
        if (ADDR_WIDTH < 2 || DATA_WIDTH < 1)
            $fatal(1, "Style2 requires ADDR_WIDTH>=2, DATA_WIDTH>=1");
    end

endmodule
`default_nettype wire
