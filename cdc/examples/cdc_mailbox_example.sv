// Complete synthesizable integration: one common reset, two local releases.
module cdc_mailbox_example #(
  parameter integer WIDTH = 32,
  parameter integer STAGES = 2
) (
  input wire arst_n,
  input wire src_clk,
  input wire [WIDTH-1:0] src_data,
  input wire src_valid,
  output wire src_ready,
  input wire dst_clk,
  output wire [WIDTH-1:0] dst_data,
  output wire dst_valid,
  input wire dst_ready
);
  wire src_rst_n, dst_rst_n;
  cdc_reset_sync #(.STAGES(STAGES)) u_src_reset (
    .clk(src_clk), .arst_n(arst_n), .rst_n(src_rst_n));
  cdc_reset_sync #(.STAGES(STAGES)) u_dst_reset (
    .clk(dst_clk), .arst_n(arst_n), .rst_n(dst_rst_n));
  cdc_mcp_handshake #(.WIDTH(WIDTH), .STAGES(STAGES)) u_mailbox (
    .src_clk(src_clk), .src_rst_n(src_rst_n), .src_data(src_data),
    .src_valid(src_valid), .src_ready(src_ready),
    .dst_clk(dst_clk), .dst_rst_n(dst_rst_n), .dst_data(dst_data),
    .dst_valid(dst_valid), .dst_ready(dst_ready));
endmodule
