module rr_arbiter #(
    parameter int unsigned REQUEST_NUM = 4
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [REQUEST_NUM-1:0] req,
    output logic [REQUEST_NUM-1:0] grant
);
    logic [REQUEST_NUM-1:0] mask;
    logic [REQUEST_NUM-1:0] masked_req;
    logic [REQUEST_NUM-1:0] unmasked_grant;
    logic [REQUEST_NUM-1:0] masked_grant;

    assign masked_req      = req & mask;
    assign unmasked_grant  = req & (~req + {{(REQUEST_NUM-1){1'b0}}, 1'b1});
    assign masked_grant    = masked_req &
                             (~masked_req + {{(REQUEST_NUM-1){1'b0}}, 1'b1});
    assign grant           = (masked_req == '0) ? unmasked_grant : masked_grant;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mask <= '1;
        else if (|grant)
            // Bits above the winner become the high-priority region.
            mask <= ~((grant << 1) - {{(REQUEST_NUM-1){1'b0}}, 1'b1});
    end
endmodule
