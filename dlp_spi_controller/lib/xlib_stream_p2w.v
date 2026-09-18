
module xlib_stream_p2w #(parameter // primitive to word transform
UNALIGN=0, // 0=bpp must be power of 2, 1=bpp can be any value <=DW
//REGSLICE=0,
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
input   [PW-1:0] m_dat,
input   s_rdy,
output  reg s_val,
output  reg s_eof,
output  [DW-1:0] s_dat
);

//generate if (AL==0) begin
//
//  assign s_val = m_val;
//  assign s_dat = m_dat;
//  assign s_eof = m_eof;
//  assign m_rdy = s_rdy;
//  
//end else begin

  reg [AL-1:0] m_cnt;
  wire [AL:0] m_cnt_1 = m_cnt + bpp + 1;
  wire m_last = m_cnt_1>=2**AL;
  assign m_rdy = ~s_val | s_rdy;
  
  always @(posedge clk or negedge rst_n)
  if (~rst_n) m_cnt <= 0;
  else if (~clr_n) m_cnt <= 0;
  else if (m_val & m_rdy) m_cnt <= m_cnt_1[AL-1:0];

  always @(posedge clk or negedge rst_n)
  if (~rst_n) s_val <= 0;
  else if (~clr_n) s_val <= 0;
  else s_val <= m_rdy ? m_val & m_last : ~s_rdy;
    
  always @(posedge clk) if (m_val & m_rdy) s_eof <= m_eof;

generate if (UNALIGN==0) begin
  reg [DW-1:0] s_buf;
  assign s_dat = s_buf;
  always @(posedge clk) if (m_val & m_rdy) s_buf [BW*m_cnt+:PW] <= m_dat; // insert data
end else begin
  reg [DW+PW-BW-1:0] s_buf;
  assign s_dat = s_buf;
  always @(posedge clk) begin
    if (s_val & s_rdy) s_buf <= {{DW{1'bx}}, s_buf} >> DW; // shift word
    if (m_val & m_rdy) s_buf [BW*m_cnt+:PW] <= m_dat; // insert data
  end
end endgenerate

//end endgenerate

endmodule
