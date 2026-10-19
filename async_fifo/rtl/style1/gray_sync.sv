`default_nettype none

module gray_sync #(
    parameter integer WIDTH = 5
) (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire [WIDTH - 1:0]          gray_async,
    output wire [WIDTH - 1:0]          gray_sync
);

    (* ASYNC_REG = "TRUE" *) reg [WIDTH - 1:0] stage1;

    // Attribute on both stages; actual placement and constraints are still needed.
    (* ASYNC_REG = "TRUE" *) reg [WIDTH - 1:0] stage2;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            stage1 <= '0;
            stage2 <= '0;
        end else begin
            stage1 <= gray_async;
            stage2 <= stage1;
        end

    assign gray_sync = stage2;

endmodule
`default_nettype wire
