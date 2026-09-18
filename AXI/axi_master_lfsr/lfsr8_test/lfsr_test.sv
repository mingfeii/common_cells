module lfsr_test #(
    parameter N = 4,
    parameter SEED = {N{1'b1}}
)(
    input clk,
    input rst_n,

    output logic [N-1:0] q

);


wire lfsr_feedback;
logic [N-1:0] r_reg;
logic [N-1:0] r_reg_nxt;


always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        r_reg <= SEED;
    else 
        r_reg <= r_reg_nxt;

//N=4
assign lfsr_feedback = r_reg[98] ^~ r_reg[100] ^~ r_reg[125] ^~ r_reg[127];	//XNOR LSFR 128 
// assign lfsr_feedback = r_reg[3] ^ r_reg[2] ^ r_reg[0];
// assign r_reg_nxt = {r_reg[N-2:0],lfsr_feedback};
assign r_reg_nxt = {lfsr_feedback,r_reg[N-1:1]};

assign q = r_reg;






endmodule 