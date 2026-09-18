
module xlib_regslice
#(parameter
WIDTH = 8, // data width
DEPTH = 1, // fifo depth
FFOUT = 0, // 0/1; registered data output
RSTEN = 0, // 0/1; fifo mem reset enable (async reset)
RSTVA = 0,
CLREN = 0, // 0/1; fifo mem clear enable (sync reset)
CLRVA = 0,
TMODE = 1  // 0/1/2/3; isolate mode
// 0: pass through mode, DEPTH>=0
// 1: forward isolate mode, DEPTH>=1
// 2: backward isolate mode, DEPTH>=1
// 3: bi-direct isolate mode, DEPTH>=1 (DEPTH>=2 for maximum throughput)
)(
input   clk,
input   rst_n, // async reset
input   clr_n, // sync reset
input   [WIDTH-1:0] m_data,
input   m_valid,
output  m_ready,
output  [WIDTH-1:0] s_data,
output  s_valid,
input   s_ready);

wire    fifo_nf;
wire    fifo_ne;
wire    [WIDTH-1:0] fifo_q;
wire    fifo_we = m_valid & m_ready;
wire    fifo_re = s_valid & s_ready;
wire    [WIDTH-1:0] fifo_d = m_data;

assign  m_ready = TMODE[1] ? fifo_nf : fifo_nf | s_ready;
assign  s_valid = TMODE[0] ? fifo_ne : fifo_ne | m_valid;
assign  s_data  = TMODE[0] ? fifo_q : fifo_ne ? fifo_q : m_data;

xlib_rs_fifos #(.WIDTH(WIDTH), .DEPTH(DEPTH), .FFOUT(FFOUT), .RSTEN(RSTEN), .RSTVA(RSTVA), .CLREN(CLREN), .CLRVA(CLRVA)) u (
.clk    (clk),
.rst_n  (rst_n),
.clr_n  (clr_n),
.we     (fifo_we),
.re     (fifo_re),
.d      (fifo_d),
.q      (fifo_q),
.nf     (fifo_nf),
.ne     (fifo_ne));

endmodule

`ifdef  TEST_REGSLICE

`define WIDTH 16
`define DEPTH 2
`define FFOUT 1
`define RSTEN 1
`define CLREN 0
`define TMODE 1

module tb;
parameter
CLK_PERIOD=10,
AW=16,
SZ=1<<AW;

reg clk, rst_n, start;
always #(CLK_PERIOD/2) clk=~clk;
initial begin
`ifdef VCD
  $vcdpluson();
`endif
  clk=1'b0;
  rst_n=1'b0;
  start=1'b0;
  repeat(5) @(negedge clk);
  rst_n=1'b1;
  repeat(2) @(negedge clk);
  start=1'b1;
end

reg   [`WIDTH-1:0] m_data;
reg   m_valid;
wire  m_ready;
wire  [`WIDTH-1:0] s_data;
wire  s_valid;
reg   s_ready;

integer m_addr;
integer s_addr;
reg   [`WIDTH-1:0] mem [0:SZ-1];

xlib_regslice #(.WIDTH(`WIDTH), .DEPTH(`DEPTH), .FFOUT(`FFOUT), .RSTEN(`RSTEN), .CLREN(`CLREN), .TMODE(`TMODE)) dut (
.clk      (clk),
.rst_n    (rst_n),
.clr_n    (1'b1),
.m_data   (m_data),
.m_valid  (m_valid),
.m_ready  (m_ready),
.s_data   (s_data),
.s_valid  (s_valid),
.s_ready  (s_ready));

integer i, fd, m_wait, s_wait;
initial begin
  fd=$fopen("run_rs.log", "a+");
  $fwrite(fd, "TMODE=%-d, DEPTH=%-d, FFOUT=%-d, RSTEN=%-d", `TMODE, `DEPTH, `FFOUT, `RSTEN);
  $display("TMODE=%-d, DEPTH=%-d, FFOUT=%-d, RSTEN=%-d", `TMODE, `DEPTH, `FFOUT, `RSTEN);
  for (i=0;i<SZ;i=i+1) mem[i] = $random;
  m_valid=0;
  wait (start);
  @(posedge clk);
  for (m_addr=0;m_addr<SZ;m_addr=m_addr+1) begin
    m_wait=$random;
    m_wait=m_wait[2:0]>3 ? 0 : m_wait[1:0]+1;
    m_data <= mem[m_addr];
    m_valid <= 1;
    @(posedge clk);
    while(!m_ready) @(posedge clk);
    repeat(m_wait) begin
      m_data <= 'bx;
      m_valid <= 0;
      @(posedge clk);
    end
  end
end

initial begin
  s_addr<=0;
  s_ready<=0;
  wait (start);
  @(posedge clk);
  forever begin
    s_wait=$random;
    s_wait=s_wait[1:0];
    @(posedge clk);
    s_ready<=0;
    repeat(s_wait) @(posedge clk);
    s_ready<=1;
  end
end

reg   full_log;
always @(posedge clk or negedge rst_n)
  if (~rst_n) full_log <= 1'b0; else
  if (dut.u.nf==0) full_log <= 1'b1;

always @(posedge clk)
if (s_valid & s_ready) begin
  if (s_data==mem[s_addr]) begin
  end
  else begin
    $fdisplay(fd, $time,,,": Compare Error: %-h, %-h!", s_data, mem[s_addr]);
    $display($time,,,": Compare Error: %-h, %-h!", s_data, mem[s_addr]);
    $fclose(fd);
    $stop;
  end
  if (s_addr==SZ-1) begin
    $fdisplay(fd, " -- Simulation Success! FIFO fulled: %-d", full_log);
    $display(" -- Simulation Success! FIFO fulled: %-d", full_log);
    $fclose(fd);
    $finish;
  end
  s_addr<=s_addr+1;
end

endmodule
`endif
