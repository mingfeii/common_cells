// One event per src_valid && src_ready. No destination backpressure.
// Both local resets must originate from the SAME common asynchronous reset.
module cdc_pulse_handshake #(parameter integer STAGES = 2) (
  input wire src_clk, src_rst_n, src_valid,
  output wire src_ready,
  input wire dst_clk, dst_rst_n,
  output reg dst_pulse
);
  reg req, ack;
  wire req_sync, ack_sync;
  cdc_sync_bits #(.WIDTH(1), .STAGES(STAGES)) u_req (
    .dst_clk(dst_clk), .dst_rst_n(dst_rst_n), .async_i(req), .sync_o(req_sync));
  cdc_sync_bits #(.WIDTH(1), .STAGES(STAGES)) u_ack (
    .dst_clk(src_clk), .dst_rst_n(src_rst_n), .async_i(ack), .sync_o(ack_sync));
  assign src_ready = src_rst_n && (req == ack_sync);
  always @(posedge src_clk or negedge src_rst_n)
    if (!src_rst_n) req <= 1'b0;
    else if (src_valid && src_ready) req <= ~req;
  always @(posedge dst_clk or negedge dst_rst_n)
    if (!dst_rst_n) begin
      ack <= 1'b0;
      dst_pulse <= 1'b0;
    end else begin
      dst_pulse <= (req_sync != ack);
      if (req_sync != ack) ack <= req_sync;
    end
endmodule
