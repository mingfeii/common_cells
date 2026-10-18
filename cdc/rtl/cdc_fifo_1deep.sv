// Paper section 5.8.2 / 12.3: TWO storage registers, ONE outstanding word.
// FWFT: rdata is meaningful only when rvalid=1; sample at rvalid && rready.
// Memory intentionally has no reset. This is not a two-word-capacity FIFO.
module cdc_fifo_1deep #(
  parameter integer WIDTH = 8,
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
  reg [WIDTH-1:0] mem [0:1];
  reg wptr, rptr;
  wire wptr_sync, rptr_sync;
  cdc_sync_bits #(.WIDTH(1), .STAGES(STAGES)) u_wptr (
    .dst_clk(rclk), .dst_rst_n(rrst_n), .async_i(wptr), .sync_o(wptr_sync));
  cdc_sync_bits #(.WIDTH(1), .STAGES(STAGES)) u_rptr (
    .dst_clk(wclk), .dst_rst_n(wrst_n), .async_i(rptr), .sync_o(rptr_sync));
  assign wready = wrst_n && (wptr == rptr_sync);
  assign rvalid = rrst_n && (rptr != wptr_sync);
  assign rdata = mem[rptr];
  always @(posedge wclk)
    if (wvalid && wready) mem[wptr] <= wdata;
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) wptr <= 1'b0;
    else if (wvalid && wready) wptr <= ~wptr;
  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n) rptr <= 1'b0;
    else if (rvalid && rready) rptr <= ~rptr;
  // synthesis translate_off
  initial if (WIDTH < 1) $fatal(1, "WIDTH must be >= 1");
  // synthesis translate_on
endmodule
