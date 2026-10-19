// Cummings/Alfke FIFO Style #2, section 5.3.
// Intentional asynchronous SR latch: mapping requires a suitable target cell.
`default_nettype none

module s2_async_cmp #(
    parameter integer ADDR_WIDTH = 4
) (
    input  wire [ADDR_WIDTH - 1:0]     wgray,
    input  wire [ADDR_WIDTH - 1:0]     rgray,
    input  wire                        wrst_n,
    output wire                  aempty_n, afull_n
);

    localparam integer N = ADDR_WIDTH - 1;
    reg                         direction;
    wire                        going_full = (wgray[N] ^ rgray[N - 1]) && !(wgray[N - 1] ^ rgray[N]);
    wire                        going_empty = !(wgray[N] ^ rgray[N - 1]) && (wgray[N - 1] ^ rgray[N]);

    // Clear on reset, set when write pointer trails read pointer by a quadrant,
    // clear when write pointer leads read pointer by a quadrant; otherwise HOLD.
    // This replaces the paper's technology-specific constant-clock FF trick.
    always @* begin
        if (!wrst_n || going_empty)
            direction <= 1'b0;
        else if (going_full)
            direction <= 1'b1;
    end

    assign aempty_n = !((wgray == rgray) && !direction);
    assign afull_n = !((wgray == rgray) && direction);

endmodule
`default_nettype wire
