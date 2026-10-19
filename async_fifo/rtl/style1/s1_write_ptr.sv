`default_nettype none

module s1_write_ptr #(
    parameter integer ADDR_WIDTH = 4
) (
    input  wire                        wclk,
    input  wire                        wrst_n,
    input  wire                        winc,
    input  wire [ADDR_WIDTH:0]         synced_rgray,
    output wire [ADDR_WIDTH - 1:0]     waddr,
    output reg  [ADDR_WIDTH:0]         wgray,
    output reg                         wfull
);

    reg  [ADDR_WIDTH:0]         wbin;
    wire [ADDR_WIDTH:0]         wbin_next;
    wire [ADDR_WIDTH:0]         wgray_next;
    wire [ADDR_WIDTH:0]         full_target;

    assign waddr = wbin[ADDR_WIDTH - 1:0];
    assign wbin_next = wbin + {{ADDR_WIDTH{1'b0}}, (winc && !wfull)};
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;

    // Invert the top TWO Gray bits, not just the wrap bit.
    // XOR mask also supports ADDR_WIDTH=1 without a negative part select.
    localparam [ADDR_WIDTH:0] FULL_MASK = ({{ADDR_WIDTH{1'b0}}, 1'b1} << ADDR_WIDTH)
                                       | ({{ADDR_WIDTH{1'b0}}, 1'b1} << (ADDR_WIDTH - 1));

    assign full_target = synced_rgray ^ FULL_MASK;

    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) begin
            wbin <= '0;
            wgray <= '0;
            wfull <= 1'b0;
        end else begin
            wbin <= wbin_next;
            wgray <= wgray_next;
            wfull <= (wgray_next == full_target);
        end

endmodule
`default_nettype wire
