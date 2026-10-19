`default_nettype none

module s1_read_ptr #(
    parameter integer ADDR_WIDTH = 4
) (

    input  wire                        rclk,
    input  wire                        rrst_n,
    input  wire                        rinc,
    input  wire [ADDR_WIDTH:0]         synced_wgray,
    output wire [ADDR_WIDTH - 1:0]     raddr,
    output reg  [ADDR_WIDTH:0]         rgray,
    output reg                         rempty
);

    reg  [ADDR_WIDTH:0]         rbin;
    wire [ADDR_WIDTH:0]         rbin_next;
    wire [ADDR_WIDTH:0]         rgray_next;

    assign raddr = rbin[ADDR_WIDTH - 1:0];
    assign rbin_next = rbin + {{ADDR_WIDTH{1'b0}}, (rinc && !rempty)};
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) begin
            rbin <= '0;
            rgray <= '0;
            rempty <= 1'b1;
        end else begin
            rbin <= rbin_next;
            rgray <= rgray_next;
            rempty <= (rgray_next == synced_wgray);
        end

endmodule
`default_nettype wire
