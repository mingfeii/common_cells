`timescale 1ns/1ps

module tb_arbiter;
    localparam int N = 4;
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic [N-1:0] fixed_req, rr_req, wrr_req, matrix_req;
    logic [N-1:0] fixed_grant, rr_grant, wrr_grant, matrix_grant;
    logic wrr_busy;
    int count [N];

    always #5 clk = ~clk;

    fixed_arbiter #(.REQUEST_NUM(N)) u_fixed (
        .req(fixed_req), .grant(fixed_grant)
    );
    rr_arbiter #(.REQUEST_NUM(N)) u_rr (
        .clk(clk), .rst_n(rst_n), .req(rr_req), .grant(rr_grant)
    );
    wrr_arbiter #(
        .REQ_NUM(N), .CREDIT_WIDTH(4), .WEIGHT_CFG({4'd1, 4'd2, 4'd3, 4'd4})
    ) u_wrr (
        .clk(clk), .rst_n(rst_n), .req(wrr_req), .busy(wrr_busy), .grant(wrr_grant)
    );
    matrix_arbiter #(.REQ_NUM(N)) u_matrix (
        .clk(clk), .rst_n(rst_n), .req(matrix_req), .grant(matrix_grant)
    );

    task automatic check_result(input logic condition, input string message);
        if (!condition) begin
            $error("FAIL: %s", message);
            $fatal(1);
        end
    endtask

    task automatic tick;
        @(posedge clk);
        #1;
    endtask

    initial begin
        fixed_req = '0;
        rr_req = '0;
        wrr_req = '0;
        matrix_req = '0;
        wrr_busy = 1'b0;
        repeat (2) tick();
        rst_n = 1'b1;
        #1;

        // Fixed priority: port 0 is highest and output is one-hot-or-zero.
        fixed_req = 4'b0000; #1; check_result(fixed_grant == 4'b0000, "fixed idle");
        fixed_req = 4'b1010; #1; check_result(fixed_grant == 4'b0010, "fixed selects lowest set bit");
        fixed_req = 4'b1111; #1; check_result(fixed_grant == 4'b0001, "fixed port 0 priority");

        // RR must rotate 0,1,2,3 while all requesters remain active.
        rr_req = '1;
        #1; check_result(rr_grant == 4'b0001, "RR first winner");
        tick(); check_result(rr_grant == 4'b0010, "RR second winner");
        tick(); check_result(rr_grant == 4'b0100, "RR third winner");
        tick(); check_result(rr_grant == 4'b1000, "RR fourth winner");
        tick(); check_result(rr_grant == 4'b0001, "RR wraps");
        rr_req = 4'b0101;
        tick(); check_result(rr_grant == 4'b0100, "RR skips inactive ports");
        rr_req = '0;

        // Smooth WRR with weights 4:3:2:1: total grants per epoch match weights.
        wrr_req = '1;
        for (int k = 0; k < N; k++) count[k] = 0;
        for (int k = 0; k < 10; k++) begin
            #1;
            check_result($onehot(wrr_grant), "WRR grant is one-hot");
            for (int p = 0; p < N; p++) count[p] += wrr_grant[p];
            tick();
        end
        check_result(count[0] == 4 && count[1] == 3 && count[2] == 2 && count[3] == 1,
               "WRR 4:3:2:1 distribution");

        // busy freezes state: the visible winner must not advance.
        wrr_busy = 1'b1;
        #1;
        begin
            logic [N-1:0] held_grant;
            held_grant = wrr_grant;
            repeat (3) begin
                tick();
                check_result(wrr_grant == held_grant, "WRR state frozen while busy");
            end
        end
        wrr_busy = 1'b0;
        wrr_req = '0;

        // Matrix arbiter implements the same fair LRU rotation.
        matrix_req = '1;
        #1; check_result(matrix_grant == 4'b0001, "matrix first winner");
        tick(); check_result(matrix_grant == 4'b0010, "matrix second winner");
        tick(); check_result(matrix_grant == 4'b0100, "matrix third winner");
        tick(); check_result(matrix_grant == 4'b1000, "matrix fourth winner");
        tick(); check_result(matrix_grant == 4'b0001, "matrix wraps");
        matrix_req = 4'b1010;
        #1; check_result(matrix_grant == 4'b0010, "matrix skips inactive ports");
        tick(); check_result(matrix_grant == 4'b1000, "matrix rotates among active ports");

        // Common invariants under pseudo-random requests.
        repeat (100) begin
            fixed_req  = $urandom_range(0, 15);
            rr_req     = $urandom_range(0, 15);
            wrr_req    = $urandom_range(0, 15);
            matrix_req = $urandom_range(0, 15);
            #1;
            check_result($onehot0(fixed_grant) && ((fixed_grant & ~fixed_req) == '0), "fixed invariant");
            check_result($onehot0(rr_grant) && ((rr_grant & ~rr_req) == '0), "RR invariant");
            check_result($onehot0(wrr_grant) && ((wrr_grant & ~wrr_req) == '0), "WRR invariant");
            check_result($onehot0(matrix_grant) && ((matrix_grant & ~matrix_req) == '0), "matrix invariant");
            tick();
        end

        $display("PASS: all arbiter tests completed successfully");
        $finish;
    end
endmodule
