// Shared storage: synchronous write, asynchronous read (FWFT).
// The consumer samples rdata on an accepted read edge, BEFORE raddr advances.
`default_nettype none

module fifo_mem #(
    parameter integer DATA_WIDTH = 8,
    parameter integer ADDR_WIDTH = 4
) (
    input  wire                        wclk,
    input  wire                        write_en,
    input  wire [DATA_WIDTH - 1:0]     wdata,
    input  wire [ADDR_WIDTH - 1:0]     waddr,
    input  wire [ADDR_WIDTH - 1:0]     raddr,
    output wire [DATA_WIDTH - 1:0]     rdata
);

    localparam integer DEPTH = 1 << ADDR_WIDTH;

    reg  [DATA_WIDTH - 1:0]     mem [0:DEPTH - 1];

    always @(posedge wclk)
        if (write_en)
            mem[waddr] <= wdata;

    assign rdata = mem[raddr];

endmodule
`default_nettype wire
