module matrix_arbiter #(
    parameter int unsigned REQ_NUM = 4
) (
    input  logic               clk,
    input  logic               rst_n,
    input  logic [REQ_NUM-1:0] req,
    output logic [REQ_NUM-1:0] grant
);
    // matrix[i][j] == 1 means i currently has priority over j.
    logic [REQ_NUM-1:0] matrix [REQ_NUM];
    logic [REQ_NUM-1:0] matrix_next [REQ_NUM];

    integer i, j;
    always_comb begin
        grant = '0;
        for (i = 0; i < REQ_NUM; i++) begin
            grant[i] = req[i];
            for (j = 0; j < REQ_NUM; j++) begin
                if ((i != j) && req[j] && matrix[j][i])
                    grant[i] = 1'b0;
            end
        end

        for (i = 0; i < REQ_NUM; i++)
            matrix_next[i] = matrix[i];

        // The winner becomes least-recently-used / lowest priority.
        for (i = 0; i < REQ_NUM; i++) begin
            for (j = 0; j < REQ_NUM; j++) begin
                if (grant[i])
                    matrix_next[i][j] = 1'b0;
                else if (grant[j])
                    matrix_next[i][j] = 1'b1;
            end
        end
    end

    integer r, c;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (r = 0; r < REQ_NUM; r++) begin
                for (c = 0; c < REQ_NUM; c++)
                    matrix[r][c] <= (r < c);
            end
        end else begin
            for (r = 0; r < REQ_NUM; r++)
                matrix[r] <= matrix_next[r];
        end
    end
endmodule
