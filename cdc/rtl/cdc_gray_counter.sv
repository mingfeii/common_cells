// Each source edge advances by ZERO or ONE, including modulo wrap.
// Registered Gray output is the only bus crossing the boundary.
module cdc_gray_counter #(
  parameter integer WIDTH = 8,
  parameter integer STAGES = 2
) (
  input wire src_clk, src_rst_n, src_inc,
  output reg [WIDTH-1:0] src_bin,
  output reg [WIDTH-1:0] src_gray,
  input wire dst_clk, dst_rst_n,
  output wire [WIDTH-1:0] dst_gray,
  output wire [WIDTH-1:0] dst_bin
);
  wire [WIDTH-1:0] next_bin = src_bin + {{(WIDTH-1){1'b0}}, src_inc};
  always @(posedge src_clk or negedge src_rst_n)
    if (!src_rst_n) begin
      src_bin <= '0;
      src_gray <= '0;
    end else begin
      src_bin <= next_bin;
      src_gray <= next_bin ^ (next_bin >> 1);
    end
  cdc_sync_bits #(.WIDTH(WIDTH), .STAGES(STAGES)) u_gray (
    .dst_clk(dst_clk), .dst_rst_n(dst_rst_n), .async_i(src_gray), .sync_o(dst_gray));
  genvar b;
  generate for (b=0; b<WIDTH; b=b+1) begin : g_decode
    assign dst_bin[b] = ^(dst_gray >> b);
  end endgenerate
  // synthesis translate_off
  initial if (WIDTH < 1) $fatal(1, "WIDTH must be >= 1");
  // synthesis translate_on
endmodule
