// Asynchronous assertion, local-clock synchronous release. STAGES >= 2.
module cdc_reset_sync #(
  parameter integer STAGES = 2
) (
  input wire clk,
  input wire arst_n,
  output wire rst_n
);

  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [STAGES-1:0] pipe;

  always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      pipe <= '0;
    end else begin
      pipe <= {pipe[STAGES-2:0], 1'b1};
    end
  end

  assign rst_n = pipe[STAGES-1];

  // synthesis translate_off
  initial begin
    if (STAGES < 2) begin
      $fatal(1, "STAGES must be >= 2");
    end
  end

  // synthesis translate_on
endmodule
