// Minimal integration example. Select the ordinary synchronized-pointer design.
// arst_n flushes BOTH domains; upstream and downstream must discard old traffic.
`default_nettype none

module async_fifo_example #(
    parameter integer DATA_WIDTH = 8,
    parameter integer ADDR_WIDTH = 4
) (
    input  wire                        arst_n,
    input  wire                        wclk,

    input  wire                        rclk,
    input  wire                        write_request,
    input  wire                        read_request,
    input  wire [DATA_WIDTH - 1:0]     data_in,
    output wire [DATA_WIDTH - 1:0]     data_out,
    output wire                        full,
    output wire                        empty,
    output wire                  write_accepted, read_accepted
);

    wire                        wrst_n;
    wire                        rrst_n;
    reset_sync u_wr (
        .clk    (wclk),
        .arst_n (arst_n),
        .srst_n (wrst_n)
    );

    reset_sync u_rr (
        .clk    (rclk),
        .arst_n (arst_n),
        .srst_n (rrst_n)
    );

    assign write_accepted = wrst_n && write_request && !full;
    assign read_accepted = rrst_n && read_request && !empty;
    async_fifo_style1 #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_fifo (
        .wclk   (wclk),
        .wrst_n (wrst_n),
        .winc   (write_request),
        .wdata  (data_in),
        .wfull  (full),
        .rclk   (rclk),
        .rrst_n (rrst_n),
        .rinc   (read_request),
        .rdata  (data_out),
        .rempty (empty)
    );

endmodule
`default_nettype wire
