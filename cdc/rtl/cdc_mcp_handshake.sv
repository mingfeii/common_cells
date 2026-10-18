// Bundled-data MCP mailbox, one outstanding word. WIDTH >= 1.
// Bound the physical hold_data -> dst_data path; see docs/CDC教程.md.
// ACK means destination CONSUMED the word, not merely observed the request.
module cdc_mcp_handshake #(
  parameter integer WIDTH = 8,
  parameter integer STAGES = 2
) (
  input wire src_clk, src_rst_n,
  input wire [WIDTH-1:0] src_data,
  input wire src_valid,
  output wire src_ready,
  input wire dst_clk, dst_rst_n,
  output reg [WIDTH-1:0] dst_data,
  output reg dst_valid,
  input wire dst_ready
);
  reg [WIDTH-1:0] hold_data;
  reg req, ack;
  wire req_sync, ack_sync;
  cdc_sync_bits #(.WIDTH(1), .STAGES(STAGES)) u_req (
    .dst_clk(dst_clk), .dst_rst_n(dst_rst_n), .async_i(req), .sync_o(req_sync));
  cdc_sync_bits #(.WIDTH(1), .STAGES(STAGES)) u_ack (
    .dst_clk(src_clk), .dst_rst_n(src_rst_n), .async_i(ack), .sync_o(ack_sync));
  assign src_ready = src_rst_n && (req == ack_sync);
  always @(posedge src_clk or negedge src_rst_n)
    if (!src_rst_n) begin
      hold_data <= '0;
      req <= 1'b0;
    end else if (src_valid && src_ready) begin
      hold_data <= src_data;
      req <= ~req;
    end
  always @(posedge dst_clk or negedge dst_rst_n)
    if (!dst_rst_n) begin
      dst_data <= '0;
      dst_valid <= 1'b0;
      ack <= 1'b0;
    end else if (dst_valid) begin
      if (dst_ready) begin
        dst_valid <= 1'b0;
        ack <= req_sync;
      end
    end else if (req_sync != ack) begin
      dst_data <= hold_data;
      dst_valid <= 1'b1;
    end
  // synthesis translate_off
  initial if (WIDTH < 1) $fatal(1, "WIDTH must be >= 1");
  // synthesis translate_on
endmodule
