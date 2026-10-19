`default_nettype none

module s2_read_ptr #(
    parameter integer ADDR_WIDTH = 4
) (

    input  wire                        rclk,
    input  wire                        rrst_n,
    input  wire                        rinc,
    input  wire                        aempty_n,
    output reg  [ADDR_WIDTH - 1:0]     rgray,
    output reg                         rempty
);

    reg  [ADDR_WIDTH - 1:0]     rbin;
    reg                         empty_stage1;
    wire [ADDR_WIDTH - 1:0]     rbin_next = rbin + {{(ADDR_WIDTH - 1){1'b0}}, (rinc && !rempty)};
    wire [ADDR_WIDTH - 1:0]     rgray_next = (rbin_next >> 1) ^ rbin_next;

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) begin
            rbin <= '0;
            rgray <= '0;
        end else begin
            rbin <= rbin_next;
            rgray <= rgray_next;
        end

    // Explicit rrst_n preset added so reset deterministically reports empty.
    always @(posedge rclk or negedge rrst_n or negedge aempty_n)
        if (!rrst_n || !aempty_n)
            {rempty, empty_stage1} <= 2'b11;
        else
            {rempty, empty_stage1} <= {empty_stage1, 1'b0};

endmodule
`default_nettype wire
