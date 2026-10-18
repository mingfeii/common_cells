// Gray-pointer asynchronous FIFO, DEPTH = 2**ADDR_WIDTH, ADDR_WIDTH >= 1.
// Small register/distributed-RAM implementation with ASYNCHRONOUS read (FWFT).
// Do not substitute a synchronous-read block RAM without adapting the interface.
module cdc_async_fifo #(
  parameter integer WIDTH = 8,
  parameter integer ADDR_WIDTH = 3,
  parameter integer STAGES = 2
) (
  input wire wclk, wrst_n,
  input wire [WIDTH-1:0] wdata,
  input wire wvalid,
  output wire wready,
  input wire rclk, rrst_n,
  output wire [WIDTH-1:0] rdata,
  output wire rvalid,
  input wire rready
);
  localparam integer PTR_WIDTH = ADDR_WIDTH + 1;
  localparam [PTR_WIDTH-1:0] FULL_MASK = {2'b11, {(ADDR_WIDTH-1){1'b0}}};
  reg [WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
  reg [PTR_WIDTH-1:0] wbin, rbin, wgray, rgray;
  wire [PTR_WIDTH-1:0] wgray_sync, rgray_sync;
  wire [PTR_WIDTH-1:0] wnext = wbin + {{(PTR_WIDTH-1){1'b0}}, (wvalid && wready)};
  wire [PTR_WIDTH-1:0] rnext = rbin + {{(PTR_WIDTH-1){1'b0}}, (rvalid && rready)};
  cdc_sync_bits #(.WIDTH(PTR_WIDTH), .STAGES(STAGES)) u_wptr (
    .dst_clk(rclk), .dst_rst_n(rrst_n), .async_i(wgray), .sync_o(wgray_sync));
  cdc_sync_bits #(.WIDTH(PTR_WIDTH), .STAGES(STAGES)) u_rptr (
    .dst_clk(wclk), .dst_rst_n(wrst_n), .async_i(rgray), .sync_o(rgray_sync));
  assign wready = wrst_n && (wgray != (rgray_sync ^ FULL_MASK));
  assign rvalid = rrst_n && (rgray != wgray_sync);
  assign rdata = mem[rbin[ADDR_WIDTH-1:0]];
  always @(posedge wclk)
    if (wvalid && wready) mem[wbin[ADDR_WIDTH-1:0]] <= wdata;
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) begin wbin <= '0; wgray <= '0; end
    else begin wbin <= wnext; wgray <= wnext ^ (wnext >> 1); end
  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n) begin rbin <= '0; rgray <= '0; end
    else begin rbin <= rnext; rgray <= rnext ^ (rnext >> 1); end
  // synthesis translate_off
  initial if (WIDTH < 1 || ADDR_WIDTH < 1) $fatal(1, "Invalid FIFO parameters");
  // synthesis translate_on
endmodule
