// Only for ONE level bit, independent bits, or REGISTERED Gray code.
// Not a coherent arbitrary-bus synchronizer. Source must remove glitches.
module cdc_sync_bits #(
  parameter integer WIDTH = 1,
  parameter integer STAGES = 2
) (
  input wire dst_clk, dst_rst_n,
  input wire [WIDTH-1:0] async_i,
  output wire [WIDTH-1:0] sync_o
);
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [WIDTH-1:0] pipe [0:STAGES-1];
  integer k;
  always @(posedge dst_clk or negedge dst_rst_n)
    if (!dst_rst_n) begin
      for (k=0; k<STAGES; k=k+1) pipe[k] <= '0;
    end else begin
      pipe[0] <= async_i;
      for (k=1; k<STAGES; k=k+1) pipe[k] <= pipe[k-1];
    end
  assign sync_o = pipe[STAGES-1];
  // synthesis translate_off
  initial if (WIDTH < 1 || STAGES < 2) $fatal(1, "Invalid synchronizer parameters");
  // synthesis translate_on
endmodule
