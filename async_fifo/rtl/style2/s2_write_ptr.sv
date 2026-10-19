`default_nettype none

module s2_write_ptr #(
    parameter integer ADDR_WIDTH = 4
) (
    input  wire                        wclk,
    input  wire                        wrst_n,
    input  wire                        winc,
    input  wire                        afull_n,
    output reg  [ADDR_WIDTH - 1:0]     wgray,
    output reg                         wfull
);

    reg  [ADDR_WIDTH - 1:0]     wbin;
    reg                         full_stage1;
    wire [ADDR_WIDTH - 1:0]     wbin_next = wbin + {{(ADDR_WIDTH - 1){1'b0}}, (winc && !wfull)};
    wire [ADDR_WIDTH - 1:0]     wgray_next = (wbin_next >> 1) ^ wbin_next;

    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) begin
            wbin <= '0;
            wgray <= '0;
        end else begin
            wbin <= wbin_next;
            wgray <= wgray_next;
        end

    // Full assertion through asynchronous preset; release through two wclk edges.
    // Mixed asynchronous reset/preset: NOT a portable FPGA register template.
    always @(posedge wclk or negedge wrst_n or negedge afull_n)
        if (!wrst_n)
            {wfull, full_stage1} <= 2'b00;
        else if (!afull_n)
            {wfull, full_stage1} <= 2'b11;
        else
            {wfull, full_stage1} <= {full_stage1, 1'b0};

endmodule
`default_nettype wire
