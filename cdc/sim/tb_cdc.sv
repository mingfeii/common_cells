`timescale 1ns/1ps

// A queue scoreboard observes ONLY accepted transfers at each local edge.
module stream_check #(
  parameter integer KIND=0, WIDTH=8, ADDR_WIDTH=3, STAGES=2
) (
  input wire wclk, rclk, arst_n, wrst_n, rrst_n,
  input integer phase,
  output wire drained
);
  localparam integer CAPACITY = KIND==2 ? (1<<ADDR_WIDTH) : 1;
  reg [WIDTH-1:0] wdata;
  reg wvalid=0, rready=0;
  wire wready, rvalid;
  wire [WIDTH-1:0] rdata;
  generate
    if (KIND==0) begin : g_mcp
      cdc_mailbox_example #(.WIDTH(WIDTH),.STAGES(STAGES)) dut (
        .arst_n(arst_n),
        .src_clk(wclk),.src_data(wdata),.src_valid(wvalid),.src_ready(wready),
        .dst_clk(rclk),.dst_data(rdata),.dst_valid(rvalid),.dst_ready(rready));
    end else if (KIND==1) begin : g_one
      cdc_fifo_1deep #(.WIDTH(WIDTH),.STAGES(STAGES)) dut (.*);
    end else begin : g_fifo
      cdc_async_fifo #(.WIDTH(WIDTH),.ADDR_WIDTH(ADDR_WIDTH),.STAGES(STAGES)) dut (.*);
    end
  endgenerate
  reg [WIDTH-1:0] expected [0:32767];
  integer sent=0, received=0, stalls=0;
  integer fill_checked=0;
  reg last_write=0, stalled=0;
  reg [WIDTH-1:0] held;
  reg [31:0] rng_w=32'h12345678+KIND, rng_r=32'habcdef01+KIND;
  function automatic [31:0] advance(input [31:0] x);
    reg [31:0] y;
    begin y=x^(x<<13); y=y^(y>>17); advance=y^(y<<5); end
  endfunction
  function automatic [WIDTH-1:0] pattern(input integer n);
    integer j;
    begin
      for (j=0;j<WIDTH;j=j+1) pattern[j]=((n*32'h45d9f3b) >> (j%31)) ^ (j+n);
    end
  endfunction
  assign drained = (sent==received) && !wvalid && !rvalid;
  always @(posedge wclk or negedge arst_n)
    if (!arst_n) begin sent=0; last_write=0; stalls=0; end
    else if (wrst_n) begin
      last_write = wvalid && wready;
      if (wvalid && !wready) stalls=stalls+1;
      if (last_write) begin
        if (sent>=32768) $fatal(1,"scoreboard overflow");
        expected[sent]=wdata;
        sent=sent+1;
        if (sent-received>CAPACITY) $fatal(1,"KIND %0d overflow",KIND);
      end
    end
  always @(negedge wclk)
    if (!wrst_n) begin wvalid=0; wdata='0; end
    else begin
      rng_w=advance(rng_w);
      // Hold valid/data until a transfer actually happened.
      if (!wvalid || last_write) begin
        wvalid=(phase==1) || ((phase==3) && (rng_w[3:0]<12));
        wdata=pattern(sent);
      end
      if (phase==1 && sent==CAPACITY && !fill_checked) begin
        fill_checked=1;
      end
    end
  always @(negedge rclk)
    if (!rrst_n) rready=0;
    else begin
      rng_r=advance(rng_r);
      rready=(phase==2 || phase==4) || (phase==3 && rng_r[3:0]<9);
    end
  always @(posedge rclk or negedge arst_n)
    if (!arst_n) begin received=0; stalled=0; held='0; end
    else if (rrst_n) begin
      if (stalled && (!rvalid || rdata !== held))
        $fatal(1,"KIND %0d output changed while stalled",KIND);
      stalled=rvalid && !rready;
      held=rdata;
      if (rvalid && rready) begin
        if (received>=sent) $fatal(1,"KIND %0d phantom read",KIND);
        if (rdata !== expected[received])
          $fatal(1,"KIND %0d index %0d got %h expected %h",KIND,received,rdata,expected[received]);
        received=received+1;
      end
    end
  always @(phase) begin
    if (phase==2 && arst_n) begin
      if (sent-received != CAPACITY || wready !== 1'b0)
        $fatal(1,"KIND %0d fill capacity mismatch occupancy=%0d",KIND,sent-received);
    end
    if (phase==5 && arst_n) begin
      if (!drained || received<10*CAPACITY || stalls==0)
        $fatal(1,"KIND %0d inadequate traffic/drain",KIND);
      $display("PASS stream KIND=%0d WIDTH=%0d capacity=%0d words=%0d stalls=%0d",KIND,WIDTH,CAPACITY,received,stalls);
    end
  end
endmodule

module tb_cdc;
  parameter integer WIDTH=8, ADDR_WIDTH=3, STAGES=2;
  parameter integer W_HALF=5, R_HALF=7, R_PHASE=2;
  reg wclk=0, rclk=0, arst_n=0;
  wire wrst_n, rrst_n;
  integer phase=0, epoch;
  wire [2:0] drained;
  always #(W_HALF) wclk=~wclk;
  initial begin #(R_PHASE); forever #(R_HALF) rclk=~rclk; end
  cdc_reset_sync #(.STAGES(STAGES)) u_wr (.clk(wclk),.arst_n(arst_n),.rst_n(wrst_n));
  cdc_reset_sync #(.STAGES(STAGES)) u_rr (.clk(rclk),.arst_n(arst_n),.rst_n(rrst_n));
  reset_check #(.STAGES(STAGES)) check_wr (.clk(wclk),.arst_n(arst_n),.rst_n(wrst_n));
  reset_check #(.STAGES(STAGES)) check_rr (.clk(rclk),.arst_n(arst_n),.rst_n(rrst_n));
  stream_check #(.KIND(0),.WIDTH(WIDTH),.STAGES(STAGES)) a (
    .wclk(wclk),.rclk(rclk),.arst_n(arst_n),.wrst_n(wrst_n),.rrst_n(rrst_n),.phase(phase),.drained(drained[0]));
  stream_check #(.KIND(1),.WIDTH(WIDTH),.STAGES(STAGES)) b (
    .wclk(wclk),.rclk(rclk),.arst_n(arst_n),.wrst_n(wrst_n),.rrst_n(rrst_n),.phase(phase),.drained(drained[1]));
  stream_check #(.KIND(2),.WIDTH(WIDTH),.ADDR_WIDTH(ADDR_WIDTH),.STAGES(STAGES)) c (
    .wclk(wclk),.rclk(rclk),.arst_n(arst_n),.wrst_n(wrst_n),.rrst_n(rrst_n),.phase(phase),.drained(drained[2]));

  reg event_valid=0;
  wire event_ready, event_pulse;
  integer events_sent=0, events_received=0;
  reg event_last=0, prev_pulse=0;
  cdc_pulse_handshake #(.STAGES(STAGES)) u_event (
    .src_clk(wclk),.src_rst_n(wrst_n),.src_valid(event_valid),.src_ready(event_ready),
    .dst_clk(rclk),.dst_rst_n(rrst_n),.dst_pulse(event_pulse));
  always @(posedge wclk or negedge arst_n)
    if (!arst_n) begin events_sent=0; event_last=0; end
    else if (wrst_n) begin
      event_last=event_valid && event_ready;
      if (event_last) events_sent=events_sent+1;
    end
  always @(negedge wclk)
    if (!wrst_n) event_valid=0;
    else if (!event_valid || event_last) event_valid=(phase==1 || phase==3);
  always @(posedge rclk or negedge arst_n)
    if (!arst_n) begin events_received=0; prev_pulse=0; end
    else if (rrst_n) begin
      if (event_pulse && prev_pulse) $fatal(1,"event pulse longer than one cycle");
      prev_pulse=event_pulse;
      if (event_pulse) begin
        events_received=events_received+1;
        if (events_received>events_sent) $fatal(1,"phantom event");
      end
    end

  reg inc=0, level_src=0;
  wire level_dst;
  wire [3:0] src_bin, src_gray, dst_bin, dst_gray;
  reg [3:0] prev_gray=0, delta;
  reg [3:0] bin_ref=0;
  reg [3:0] gray_history [0:STAGES-1];
  reg level_history [0:STAGES-1];
  integer k;
  cdc_gray_counter #(.WIDTH(4),.STAGES(STAGES)) u_count (
    .src_clk(wclk),.src_rst_n(wrst_n),.src_inc(inc),.src_bin(src_bin),.src_gray(src_gray),
    .dst_clk(rclk),.dst_rst_n(rrst_n),.dst_gray(dst_gray),.dst_bin(dst_bin));
  cdc_sync_bits #(.WIDTH(1),.STAGES(STAGES)) u_level (
    .dst_clk(rclk),.dst_rst_n(rrst_n),.async_i(level_src),.sync_o(level_dst));
  always @(negedge wclk) begin
    inc <= wrst_n && phase==3;
    level_src <= wrst_n && (phase==1 || phase==3);
  end
  always @(posedge wclk) begin
    if (!wrst_n) begin bin_ref=0; prev_gray=0; end
    else begin
      if (inc) bin_ref=bin_ref+1'b1;
      #0.001;
      if (src_bin !== bin_ref || src_gray !== (bin_ref^(bin_ref>>1))) $fatal(1,"source Gray count");
      delta=src_gray^prev_gray;
      if ((delta & (delta-1'b1)) != 0) $fatal(1,"source Gray not one-bit transition");
      prev_gray=src_gray;
    end
  end
  // Check exact RTL pipeline behavior, NOT physical metastability resolution.
  always @(posedge rclk) begin
    if (!rrst_n) begin
      for(k=0;k<STAGES;k=k+1) begin gray_history[k]=0; level_history[k]=0; end
    end else begin
      for(k=STAGES-1;k>0;k=k-1) begin
        gray_history[k]=gray_history[k-1]; level_history[k]=level_history[k-1];
      end
      gray_history[0]=src_gray; level_history[0]=level_src;
      #0.001;
      if (rrst_n && (dst_gray !== gray_history[STAGES-1] || level_dst !== level_history[STAGES-1]))
        $fatal(1,"synchronizer latency/value gray=%h exp=%h level=%b exp=%b reset=%b phase=%0d",dst_gray,gray_history[STAGES-1],level_dst,level_history[STAGES-1],rrst_n,phase);
      for(k=0;k<4;k=k+1)
        if (rrst_n && dst_bin[k] !== ^(dst_gray>>k)) $fatal(1,"Gray decoder");
    end
  end
  initial begin
    if ($test$plusargs("VCD")) begin $dumpfile("cdc.vcd"); $dumpvars(0,tb_cdc); end
    // Two complete epochs. Mid-traffic common reset deliberately flushes pending words.
    #1; arst_n=0;
    for(epoch=0;epoch<2;epoch=epoch+1) begin
      #(11+epoch); arst_n=1;
      wait(wrst_n && rrst_n);
      @(negedge wclk); #0.002; phase=1;
      repeat(300) @(negedge wclk);
      #0.002; phase=2;
      wait(&drained);
      repeat(20) @(negedge rclk);
      #0.002; phase=3;
      repeat(2500) @(negedge wclk);
      #0.002; phase=4;
      wait(&drained);
      repeat(30) @(negedge rclk);
      if (events_sent!=events_received || events_sent<10) $fatal(1,"event lost/duplicated");
      if (dst_bin !== src_bin) $fatal(1,"counter failed to converge");
      #0.002; phase=5;
      $display("PASS event sent=%0d received=%0d; Gray and level; epoch=%0d",events_sent,events_received,epoch);
      repeat(5) @(negedge wclk);
      #0.002; phase=3;
      repeat(47) @(negedge wclk);
      #0.003; arst_n=0; phase=0;
      #0.001;
      if (wrst_n !== 0 || rrst_n !== 0) $fatal(1,"reset failed asynchronous assertion");
    end
    $display("ALL PASS WIDTH=%0d ADDR_WIDTH=%0d STAGES=%0d W_HALF=%0d R_HALF=%0d",WIDTH,ADDR_WIDTH,STAGES,W_HALF,R_HALF);
    $finish;
  end
  initial begin #2000000; $fatal(1,"watchdog timeout"); end
endmodule

module reset_check #(parameter integer STAGES=2) (
  input wire clk, arst_n, rst_n
);
  integer edges=0;
  always @(posedge clk or negedge arst_n) begin
    if (!arst_n) edges=0;
    else if (edges<STAGES) edges=edges+1;
    #0.001;
    if (rst_n !== (arst_n && edges==STAGES)) $fatal(1,"reset release edge count");
  end
endmodule
