module wrr_arbiter #(
    parameter int unsigned REQ_NUM      = 4,
    parameter int unsigned CREDIT_WIDTH = 4,
    // Slice i*CREDIT_WIDTH +: CREDIT_WIDTH is the weight of port i.
    parameter logic [REQ_NUM*CREDIT_WIDTH-1:0] WEIGHT_CFG = {4'd1, 4'd2, 4'd3, 4'd4}
) (
    input  logic               clk,
    input  logic               rst_n,
    input  logic [REQ_NUM-1:0] req,
    input  logic               busy,
    output logic [REQ_NUM-1:0] grant
);
    logic [CREDIT_WIDTH-1:0] weight [REQ_NUM];
    logic [CREDIT_WIDTH-1:0] credit [REQ_NUM];
    logic [REQ_NUM-1:0] mask;
    logic [REQ_NUM-1:0] qualified_req;
    logic [REQ_NUM-1:0] arb_req;
    logic [REQ_NUM-1:0] masked_req;
    logic [REQ_NUM-1:0] unmasked_grant;
    logic [REQ_NUM-1:0] masked_grant;
    logic reload;

    genvar g;
    generate
        for (g = 0; g < REQ_NUM; g++) begin : gen_weight_and_qualification
            assign weight[g]        = WEIGHT_CFG[g*CREDIT_WIDTH +: CREDIT_WIDTH];
            assign qualified_req[g] = req[g] && (credit[g] != '0);
        end
    endgenerate

    assign reload          = (qualified_req == '0) && (req != '0);
    assign arb_req         = reload ? req : qualified_req;
    assign masked_req      = arb_req & mask;
    assign unmasked_grant  = arb_req & (~arb_req + {{(REQ_NUM-1){1'b0}}, 1'b1});
    assign masked_grant    = masked_req &
                             (~masked_req + {{(REQ_NUM-1){1'b0}}, 1'b1});
    assign grant           = (masked_req == '0) ? unmasked_grant : masked_grant;

    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mask <= '1;
            for (i = 0; i < REQ_NUM; i++)
                credit[i] <= weight[i];
        end else if ((|grant) && !busy) begin
            mask <= ~((grant << 1) - {{(REQ_NUM-1){1'b0}}, 1'b1});
            for (i = 0; i < REQ_NUM; i++) begin
                if (reload)
                    credit[i] <= grant[i] ? (weight[i] - 1'b1) : weight[i];
                else if (grant[i])
                    credit[i] <= credit[i] - 1'b1;
            end
        end
    end
endmodule
