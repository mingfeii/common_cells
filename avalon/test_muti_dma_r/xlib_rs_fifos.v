
module xlib_rs_fifos #(parameter WIDTH=8, DEPTH=2, FFOUT=1, RSTEN=0, RSTVA=0, CLREN=0, CLRVA=0) (
input   clk,
input   rst_n,
input   clr_n,
input   we,
input   re,
input   [WIDTH-1:0] d,
output  [WIDTH-1:0] q,
output  nf,
output  ne);

function integer log2;
  input integer n;
  begin log2=0; while(n>2**log2) log2=log2+1; end
endfunction


wire    mem_rst_b = RSTEN ? rst_n : 1;
wire    mem_clr_b = CLREN ? clr_n : 1;

generate if (DEPTH==0) begin: D0

  assign nf = 0;
  assign ne = 0;
  assign q = {WIDTH{1'bx}};

end else if (DEPTH==1) begin: D1

  reg     [WIDTH-1:0] rf;
  reg     xf;
  assign  nf = ~xf;
  assign  ne = xf;
  assign  q = rf;
  always @(posedge clk or negedge rst_n)
  if (~rst_n) xf <= 1'b0; else
  if (~clr_n) xf <= 1'b0; else
  if (we^re)  xf <= ~xf;
  always @(posedge clk or negedge mem_rst_b)
  if (~mem_rst_b) rf <= RSTVA; else
  if (~mem_clr_b) rf <= CLRVA; else
  if (we) rf <= d;

end else if (FFOUT==0) begin: MN // muxed data output

  localparam AW = log2(DEPTH);
  integer i;
  reg     [WIDTH-1:0] rf [0:DEPTH-1];
  reg     xf;
  reg     [AW-1:0] wa;
  reg     [AW-1:0] ra;
  wire    [AW-1:0] wa_inc = (DEPTH!=(1<<AW) && wa==(DEPTH-1)) ? 0 : wa+1;
  wire    [AW-1:0] ra_inc = (DEPTH!=(1<<AW) && ra==(DEPTH-1)) ? 0 : ra+1;
  assign  ne = ~(xf==0 && wa==ra);
  assign  nf = ~(xf==1 && wa==ra);
  assign  q = rf [ra];
  always @(posedge clk or negedge rst_n)
  if (~rst_n) begin wa <= {AW{1'b0}}; ra <= {AW{1'b0}}; xf <= 1'b0; end else
  if (~clr_n) begin wa <= {AW{1'b0}}; ra <= {AW{1'b0}}; xf <= 1'b0; end else
  begin
    if (we) wa <= wa_inc;
    if (re) ra <= ra_inc;
    if (we & ~re & wa_inc==ra || re & ~we & ra==wa) xf <= ~xf;
  end
  always @(posedge clk or negedge mem_rst_b)
  if (~mem_rst_b) for (i=0;i<DEPTH;i=i+1) rf[i] <= RSTVA; else
  if (~mem_clr_b) for (i=0;i<DEPTH;i=i+1) rf[i] <= CLRVA; else
  if (we) rf[wa] <= d;

end else if (DEPTH==2) begin: D2

  integer i;
  reg     [WIDTH-1:0] rf [0:DEPTH-1];
  reg     [1:0] xf;
  wire    we_1 = we & xf==(re ? 3 : 1);
  wire    we_0 = we & xf==(re ? 1 : 0);
  assign  nf = ~xf[1];
  assign  ne = xf[0];
  assign  q = rf[0];
  always @(posedge clk or negedge rst_n)
  if (~rst_n) xf <= 2'b0; else
  if (~clr_n) xf <= 2'b0; else
  case ({re,we}) // synopsys parallel_case
    2'b01: xf <= {xf[0],1'b1};
    2'b10: xf <= {1'b0,xf[1]};
  endcase
  always @(posedge clk or negedge mem_rst_b)
  if (~mem_rst_b) for (i=0;i<DEPTH;i=i+1) rf[i] <= RSTVA; else
  if (~mem_clr_b) for (i=0;i<DEPTH;i=i+1) rf[i] <= CLRVA; else
  begin
    if (we_1) rf[1] <= d;
    if (we_0 | re) rf[0] <= we_0 ? d : rf[1];
  end

end else begin: FN // reged data output

  localparam AW = log2(DEPTH+1);
  integer i;
  reg     [WIDTH-1:0] rf [0:DEPTH-1];
  reg     [AW-1:0] wa;
  wire    [AW-1:0] wp = wa - re;
  assign  nf = wa!=DEPTH;
  assign  ne = wa!=0;
  assign  q = rf[0];
  always @(posedge clk or negedge rst_n)
  if (~rst_n) wa <= {AW{1'b0}}; else
  if (~clr_n) wa <= {AW{1'b0}}; else
  wa <= wa - re + we;
  always @(posedge clk or negedge mem_rst_b)
  if (~mem_rst_b) for (i=0;i<DEPTH;i=i+1) rf[i] <= RSTVA; else
  if (~mem_clr_b) for (i=0;i<DEPTH;i=i+1) rf[i] <= CLRVA; else
  for(i=0;i<DEPTH;i=i+1) if (we && wp==i || re && i<DEPTH-1) rf[i] <= we && wp==i ? d : rf[i+1];

end endgenerate

endmodule
