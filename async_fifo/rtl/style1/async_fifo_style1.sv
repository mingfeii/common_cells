// Cummings FIFO Style #1: synchronize Gray pointers, compare locally.
// Based on FIFO1 Rev 1.2, section 6. Educational rewrite, not a verbatim copy.
`default_nettype none

module async_fifo_style1 #(
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

    wire [ADDR_WIDTH - 1:0]     waddr;
    wire [ADDR_WIDTH - 1:0]     raddr;
    wire [ADDR_WIDTH:0]         wgray;
    wire [ADDR_WIDTH:0]         rgray;
    wire [ADDR_WIDTH:0]         synced_rgray;
    wire [ADDR_WIDTH:0]         synced_wgray;

    // wrst_n and rrst_n must come from the SAME flush/reset request,
    // released synchronously in their respective domains. See reset_sync.
    gray_sync #(
        .WIDTH(ADDR_WIDTH + 1)
    ) u_r2w (
        .clk        (wclk),
        .rst_n      (wrst_n),
        .gray_async (rgray),
        .gray_sync  (synced_rgray)
    );

    gray_sync #(
        .WIDTH(ADDR_WIDTH + 1)
    ) u_w2r (
        .clk        (rclk),
        .rst_n      (rrst_n),
        .gray_async (wgray),
        .gray_sync  (synced_wgray)
    );

    s1_write_ptr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_wptr (
        .wclk         (wclk),
        .wrst_n       (wrst_n),
        .winc         (winc),
        .synced_rgray (synced_rgray),
        .waddr        (waddr),
        .wgray        (wgray),
        .wfull        (wfull)
    );

    s1_read_ptr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_rptr (
        .rclk         (rclk),
        .rrst_n       (rrst_n),
        .rinc         (rinc),
        .synced_wgray (synced_wgray),
        .raddr        (raddr),
        .rgray        (rgray),
        .rempty       (rempty)
    );

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_mem (
        .wclk     (wclk),
        .write_en (wrst_n && winc && !wfull),
        .wdata    (wdata),
        .waddr    (waddr),
        .raddr    (raddr),
        .rdata    (rdata)
    );

    initial begin
        if (ADDR_WIDTH < 1 || DATA_WIDTH < 1)
            $fatal(1, "Style1 requires ADDR_WIDTH>=1, DATA_WIDTH>=1");
    end

endmodule
`default_nettype wire
