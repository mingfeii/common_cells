`timescale 1ns/1ps
`default_nettype none

module tb_async_fifo;
    parameter integer STYLE = 1;
    parameter integer DATA_WIDTH = 8;
    parameter integer ADDR_WIDTH = 4;
    parameter integer W_HALF = 3;
    parameter integer R_HALF = 5;
    parameter integer R_PHASE = 1;
    localparam integer DEPTH = 1 << ADDR_WIDTH;

    reg                         wclk = 0;
    reg                         rclk = 0;
    reg                         arst_n = 0;
    reg                         w_run = 1;
    reg                         r_run = 1;
    wire                        wrst_n;
    wire                        rrst_n;
    reg                         winc = 0;
    reg                         rinc = 0;
    reg  [DATA_WIDTH - 1:0]     wdata = '0;
    wire [DATA_WIDTH - 1:0]     rdata;
    wire                        wfull;
    wire                        rempty;
    reset_sync u_wreset (
        .clk    (wclk),
        .arst_n (arst_n),
        .srst_n (wrst_n)
    );

    reset_sync u_rreset (
        .clk    (rclk),
        .arst_n (arst_n),
        .srst_n (rrst_n)
    );

    generate
        if (STYLE == 1) begin : g_s1
            async_fifo_style1 #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH)
            ) dut (
                .wclk   (wclk),
                .wrst_n (wrst_n),
                .winc   (winc),
                .wdata  (wdata),
                .wfull  (wfull),
                .rclk   (rclk),
                .rrst_n (rrst_n),
                .rinc   (rinc),
                .rdata  (rdata),
                .rempty (rempty)
            );
        end else begin : g_s2
            async_fifo_style2 #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH)
            ) dut (
                .wclk   (wclk),
                .wrst_n (wrst_n),
                .winc   (winc),
                .wdata  (wdata),
                .wfull  (wfull),
                .rclk   (rclk),
                .rrst_n (rrst_n),
                .rinc   (rinc),
                .rdata  (rdata),
                .rempty (rempty)
            );
        end
    endgenerate

    // Debug aliases: same waveform names for both implementations.
    wire [ADDR_WIDTH:0]         debug_wgray;
    wire [ADDR_WIDTH:0]         debug_rgray;
    wire                        debug_direction;
    wire                        debug_aempty_n;
    wire                        debug_afull_n;

    generate
        if (STYLE == 1) begin : g_debug1
            assign debug_wgray = g_s1.dut.wgray;
            assign debug_rgray = g_s1.dut.rgray;
            assign debug_direction = 0;
            assign debug_aempty_n = 1;
            assign debug_afull_n = 1;
        end else begin : g_debug2
            assign debug_wgray = {1'b0, g_s2.dut.wgray};
            assign debug_rgray = {1'b0, g_s2.dut.rgray};
            assign debug_direction = g_s2.dut.u_cmp.direction;
            assign debug_aempty_n = g_s2.dut.aempty_n;
            assign debug_afull_n = g_s2.dut.afull_n;
        end
    endgenerate

    initial forever begin
        #(W_HALF);
        if (w_run)
            wclk = ~wclk;
        else
            wclk = 0;
    end

    initial begin
        #(R_PHASE);
        forever begin
            #(R_HALF);
            if (r_run)
                rclk = ~rclk;
            else
                rclk = 0;
        end
    end

    integer mode = 0; // 0 idle; 1 write; 2 read; 3 random; 4 both always request
    integer seed = 1;
    reg  [31:0]                 wrng;
    reg  [31:0]                 rrng;

    function automatic [31:0] next_rng(input [31:0] x);
        reg  [31:0]                 t;
        begin
            t = x ^ (x << 13);
            t = t ^ (t >> 17);
            next_rng = t ^ (t << 5);
        end
    endfunction

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        wrng = 32'hc0ffee01 ^ seed;
        rrng = 32'h12345678 ^ seed;
        if ($test$plusargs("VCD")) begin
            $dumpfile("wave.vcd");
            $dumpvars(0, tb_async_fifo);
        end
    end

    // Drive at falling edges: requests/data are stable before the DUT samples.
    always @(negedge wclk) begin
        wrng = next_rng(wrng);
        winc = wrst_n && (
            (mode == 1) ||
            (mode == 4) ||
            ((mode == 3) && wrng[1:0] != 0)
        );
        wdata = wrng;
    end

    always @(negedge rclk) begin
        rrng = next_rng(rrng);
        rinc = rrst_n && (
            (mode == 2) ||
            (mode == 4) ||
            ((mode == 3) && rrng[1:0] != 0)
        );
    end

    // ONE scoreboard owns head/tail. #0 coalesces coincident edges, but remains
    // before DUT nonblocking updates: rdata is sampled at the correct FWFT edge.
    // Model is a transaction log, not a copy of either pointer algorithm.
    reg  [DATA_WIDTH - 1:0]     expected [0:199999];
    integer head = 0;
    integer tail = 0;
    integer occupancy = 0;
    integer writes = 0;
    integer reads = 0;
    integer blocked_writes = 0;
    integer blocked_reads = 0;
    integer full_hits = 0;
    integer empty_hits = 0;
    integer simultaneous = 0;
    integer max_occupancy = 0;
    reg                         old_wclk = 0;
    reg                         old_rclk = 0;
    reg                         wedge;
    reg                         redge;
    reg                         take_w;
    reg                         take_r;
    reg  [ADDR_WIDTH:0]         prev_wgray;
    reg  [ADDR_WIDTH:0]         prev_rgray;
    reg  [ADDR_WIDTH:0]         delta_w;
    reg  [ADDR_WIDTH:0]         delta_r;

    always @(wclk or rclk or arst_n) begin
        #0;
        wedge = wclk && !old_wclk;
        redge = rclk && !old_rclk;
        old_wclk = wclk;
        old_rclk = rclk;
        if (!arst_n) begin
            head = 0;
            tail = 0;
            occupancy = 0;
        end else if (wrst_n && rrst_n) begin
            if ((wedge && $isunknown(wfull)) || (redge && $isunknown(rempty)))
                $fatal(1, "Unknown status flag");
            take_w = wedge && winc && !wfull;
            take_r = redge && rinc && !rempty;
            if (take_w && occupancy >= DEPTH)
                $fatal(1, "Overflow at %t", $time);
            if (take_r && occupancy <= 0)
                $fatal(1, "Underflow at %t", $time);
            if (take_r) begin
                if (rdata !== expected[head])
                    $fatal(
                        1,
                        "Data mismatch t=%t index=%0d got=%h expected=%h",
                        $time,
                        head,
                        rdata,
                        expected[head]
                    );
                head = head + 1;
                reads = reads + 1;
            end
            if (take_w) begin
                if (tail >= 200000)
                    $fatal(1, "Test model capacity exceeded");
                expected[tail] = wdata;
                tail = tail + 1;
                writes = writes + 1;
            end
            occupancy = tail - head;
            if (occupancy > max_occupancy)
                max_occupancy = occupancy;
            if (wedge && winc && wfull)
                blocked_writes = blocked_writes + 1;
            if (redge && rinc && rempty)
                blocked_reads = blocked_reads + 1;
            if (wedge && wfull)
                full_hits = full_hits + 1;
            if (redge && rempty)
                empty_hits = empty_hits + 1;
            if (take_w && take_r)
                simultaneous = simultaneous + 1;
            prev_wgray = debug_wgray;
            prev_rgray = debug_rgray;
            // Check after all DUT NBA + asynchronous flag updates settle.
            #0.001;
            delta_w = prev_wgray ^ debug_wgray;
            delta_r = prev_rgray ^ debug_rgray;
            if (wedge) begin
                if (take_w && (delta_w == 0 || ((delta_w & (delta_w - 1)) != 0)))
                    $fatal(1, "Write source Gray transition is not one bit");
                if (!take_w && delta_w != 0)
                    $fatal(1, "Write pointer moved without acceptance");
            end
            if (redge) begin
                if (take_r && (delta_r == 0 || ((delta_r & (delta_r - 1)) != 0)))
                    $fatal(1, "Read source Gray transition is not one bit");
                if (!take_r && delta_r != 0)
                    $fatal(1, "Read pointer moved without acceptance");
            end
        end
    end

    task automatic set_mode(input integer m);
        begin
            @(negedge wclk);
            #0.01;
            mode = m;
        end
    endtask

    task automatic fill_fifo;
        begin
            set_mode(1);
            repeat (DEPTH + 12) @(negedge wclk);
            #0.02;
            if (!wfull || occupancy != DEPTH)
                $fatal(1, "Fill/full failed occ=%0d", occupancy);
            // Already includes multiple illegal write attempts while full.
        end
    endtask

    task automatic drain_fifo;
        begin
            set_mode(2);
            // Stop writes, allow CDC flags to settle and drain all accepted data.
            repeat ((DEPTH + 12) * 3) @(negedge rclk);
            #0.02;
            if (!rempty || occupancy != 0)
                $fatal(1, "Drain/empty failed occ=%0d", occupancy);
            set_mode(0);
        end
    endtask

    task automatic reset_fifo;
        begin
            mode = 0;
            arst_n = 0;
            repeat (5) @(negedge wclk);
            repeat (5) @(negedge rclk);
            #0.25;
            arst_n = 1;
            wait (wrst_n && rrst_n);
            repeat (4) @(negedge rclk);
            #0.02;
            if (!rempty || wfull || occupancy != 0)
                $fatal(1, "Reset state failed");
        end
    endtask

    task automatic single_word;
        integer before_writes;
        begin
            before_writes = writes;
            set_mode(1);
            wait (writes == before_writes + 1);
            #0.02;
            mode = 0;
            repeat (6) @(negedge rclk);
            #0.02;
            if (occupancy != 1 || rempty)
                $fatal(1, "Single word visibility failed");
            drain_fifo();
        end
    endtask

    initial begin
        reset_fifo();
        $display(
            "CASE reset/empty, style=%0d depth=%0d width=%0d seed=%0d",
            STYLE,
            DEPTH,
            DATA_WIDTH,
            seed
        );

        set_mode(2);
        repeat (12) @(negedge rclk); // Empty reads ignored.
        single_word();
        repeat (3) begin
            fill_fifo();
            drain_fifo();
        end
        $display("CASE repeated fill/drain and blocked requests passed");

        set_mode(3);
        repeat (4000) @(negedge wclk);
        drain_fifo();
        set_mode(4);
        repeat (1000) @(negedge wclk);
        drain_fifo();
        $display("CASE random and continuous traffic passed");

        set_mode(0);
        repeat (4) @(negedge rclk);
        // Stop reader clock, fill, restart, drain.
        @(negedge rclk);
        #0.02;
        r_run = 0;
        fill_fifo();
        r_run = 1;
        drain_fifo();
        // Fill, stop writer clock, drain, restart.
        fill_fifo();
        set_mode(2);
        repeat (3) @(negedge wclk);
        #0.02;
        w_run = 0;
        repeat ((DEPTH + 12) * 3) @(negedge rclk);
        #0.02;
        if (occupancy != 0 || !rempty)
            $fatal(1, "Drain with stopped writer failed");
        w_run = 1;
        drain_fifo();
        $display("CASE stopped clocks passed");

        fill_fifo();
        reset_fifo(); // Flush live data, discard model contents.
        fill_fifo();
        drain_fifo();
        if (max_occupancy != DEPTH || blocked_writes == 0 || blocked_reads == 0 ||
            full_hits == 0 || empty_hits == 0 || writes < DEPTH * 8 || reads < DEPTH * 7)
            $fatal(1, "Required coverage missing");
        if (W_HALF == R_HALF && R_PHASE == 0 && simultaneous == 0)
            $fatal(1, "Coincident accepted read/write coverage missing");
        $display(
            "PASS style=%0d depth=%0d width=%0d seed=%0d writes=%0d reads=%0d blocked_w=%0d blocked_r=%0d simultaneous=%0d max_occ=%0d",
            STYLE,
            DEPTH,
            DATA_WIDTH,
            seed,
            writes,
            reads,
            blocked_writes,
            blocked_reads,
            simultaneous,
            max_occupancy
        );
        $finish;
    end

    initial begin
        #20000000;
        $fatal(1, "WATCHDOG timeout");
    end

endmodule
`default_nettype wire
