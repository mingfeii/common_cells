// Asynchronous assertion, local-clock synchronous release. STAGES >= 2.
module cdc_reset_sync #(parameter integer STAGES = 2) (
  input wire clk, arst_n,
  output wire rst_n
);
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [STAGES-1:0] pipe;
  always @(posedge clk or negedge arst_n)
    if (!arst_n) pipe <= '0;
    else pipe <= {pipe[STAGES-2:0], 1'b1};
  assign rst_n = pipe[STAGES-1];
  // synthesis translate_off
  initial if (STAGES < 2) $fatal(1, "STAGES must be >= 2");
  // synthesis translate_on
endmodule
