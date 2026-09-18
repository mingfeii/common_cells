
module xlib_stream_w2p #(parameter // word to primitive transform
UNALIGN=1'b0, // 0=bpp must be power of 2, 1=bpp can be any value <=DW
REGSLICE=1'b0,
BW=8, 
PW=BW, // maximum primitive width, <=DW
DW=32, // word width, must power of 2 byte
AL=$clog2(DW/BW)
)(
input   clk,
input   rst_n,
input   clr_n,
input   [AL-1:0] bpp, // byte per primitive: 0=1B, 1=2B, 2=3B, 3=4B ...
output  m_rdy,
input   m_val,
input   m_eof,
input   [DW-1:0] m_dat,
input   s_rdy,
output  s_val,
output  s_eof,
output  [PW-1:0] s_dat
);

wire x_rdy;
wire x_val;
wire x_eof;
wire [DW-1:0] x_dat;

localparam DEPTH = UNALIGN || REGSLICE ? 1 : 0;

xlib_regslice #(.WIDTH(DW+1), .DEPTH(DEPTH), .TMODE(DEPTH)) rs (
.clk(clk),.rst_n(rst_n),.clr_n(clr_n), 
.m_ready(m_rdy),.m_valid(m_val),.m_data({m_eof, m_dat}),
.s_ready(x_rdy),.s_valid(x_val),.s_data({x_eof, x_dat}));

//generate if (AL==0) begin
//
//  assign s_val = x_val;
//  assign s_dat = x_dat;
//  assign s_eof = x_eof;
//  assign x_rdy = s_rdy;
//  
//end else begin

  reg [AL-1:0] s_cnt;
  wire [AL:0] s_cnt_1 = s_cnt + bpp + 1;
  wire s_last = s_cnt_1>=2**AL;
  wire s_wait = UNALIGN && (s_cnt_1>2**AL) && !m_val;

  assign x_rdy = s_rdy && s_last && !s_wait;
  assign s_val = x_val && !s_wait;
  assign s_eof = x_eof && s_last;
  assign s_dat = {UNALIGN ? m_dat : x_dat, x_dat} >> (BW*s_cnt);
  
  always @(posedge clk or negedge rst_n)
  if (!rst_n) 
    s_cnt <= 0;
  else if (!clr_n) 
    s_cnt <= 0;
  else if (s_val && s_rdy) 
    s_cnt <= s_cnt_1[AL-1:0];
  
//end endgenerate

endmodule
