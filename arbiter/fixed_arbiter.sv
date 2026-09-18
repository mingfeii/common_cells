module fixed_arbiter #(
    parameter int unsigned REQUEST_NUM = 4
) (
    input  logic [REQUEST_NUM-1:0] req,
    output logic [REQUEST_NUM-1:0] grant
);
    // Isolate the least-significant set bit; port 0 has highest priority.
    assign grant = req & (~req + {{(REQUEST_NUM-1){1'b0}}, 1'b1});
endmodule
