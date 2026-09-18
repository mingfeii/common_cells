module sc_fifo #(
  parameter int DATA_WIDTH   = 8,
  parameter int WORDS_AMOUNT = 8,
  parameter int ADDR_WIDTH   = $clog2( WORDS_AMOUNT)
  )(
  input                       clk_i,
  input                       rst_i,
  input                       wr_i,
  input  [DATA_WIDTH - 1 : 0] wr_data_i,
  input                       rd_i,
  output [DATA_WIDTH - 1 : 0] rd_data_o,
  output [ADDR_WIDTH : 0]     used_words_o,
  output                      full_o,
  output                      empty_o
);

logic [ADDR_WIDTH - 1 : 0] wr_addr;
logic                      wr_req;
logic                      full;
logic [ADDR_WIDTH - 1 : 0] rd_addr;
logic                      rd_req;
logic                      empty;
logic [ADDR_WIDTH : 0]     used_words;
// Moving data from RAM to output reg
logic                      rd_en;
// There is unread data in RAM
logic                      data_in_ram;
// There is unread data in output reg
logic                      data_in_o_reg;
// More than one word in RAM
logic                      svrl_w_in_mem;
// First word in FIFO datapath after empty
logic                      first_word;

assign full_o       = full;
assign empty_o      = empty;
assign used_words_o = used_words;
// Protection from write into full FIFO.
assign wr_req       = wr_i && !full;
// Protection from read from empty FIFO.
assign rd_req       = rd_i && !empty;

always_ff @( posedge clk_i or posedge rst_i )
  if( rst_i )
    used_words <= '0;
  else
    if( wr_req && !rd_req )
      used_words <= used_words + 1'b1;
    else
      if( !wr_req && rd_req )
        used_words <= used_words - 1'b1;

assign svrl_w_in_mem = used_words > 'd2;
assign first_word    = data_in_ram && !data_in_o_reg;

always_ff @( posedge clk_i or posedge rst_i )
  if( rst_i )
    data_in_o_reg <= '0;
  else
    if( rd_req || first_word )
      data_in_o_reg <= data_in_ram;

// Pulling data from ram to output register
assign rd_en = ( first_word || rd_req ) && data_in_ram;
assign empty = !data_in_o_reg;


always_ff @( posedge clk_i or posedge rst_i )
  if( rst_i )
    data_in_ram <= '0;
  else
    if( rd_req )
      data_in_ram <= wr_req || svrl_w_in_mem;
    else
      if( first_word || !data_in_ram )
        data_in_ram <= wr_req;


always_ff @( posedge clk_i or posedge rst_i )
  if( rst_i )
    wr_addr <= '0;
  else
    if( wr_req )
      wr_addr <= wr_addr + 1'b1;

always_ff @( posedge clk_i or posedge rst_i )
  if( rst_i )
    rd_addr <= '0;
  else
    if( rd_en )
      rd_addr <= rd_addr + 1'b1;

always_ff @( posedge clk_i or posedge rst_i )
  if( rst_i )
    full <= '0;
  else
    // One word more than in the memory, due to output register
    if( !rd_req && wr_req )
      full <= used_words == ( ADDR_WIDTH + 1 )'( 2**ADDR_WIDTH - 1 );
    else
      if( rd_req && !wr_req )
        full <= 1'b0;

dual_port_ram_sync_fifo #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .ADDR_WIDTH ( ADDR_WIDTH )
) ram_sfifo (
  .wr_clk_i   ( clk_i      ),
  .wr_addr_i  ( wr_addr    ),
  .wr_data_i  ( wr_data_i  ),
  .wr_i       ( wr_req     ),
  .rst_i      (rst_i        ),
  .rd_clk_i   ( clk_i      ),
  .rd_addr_i  ( rd_addr    ),
  .rd_data_o  ( rd_data_o  ),
  .rd_i       ( rd_en      )
);

endmodule


module dual_port_ram_sync_fifo #(
  parameter int DATA_WIDTH        = 8,
  parameter int ADDR_WIDTH        = 5
)(
  input                       wr_clk_i,
  input                       rst_i,
  input [ADDR_WIDTH - 1 : 0]  wr_addr_i,
  input [DATA_WIDTH - 1 : 0]  wr_data_i,
  input                       wr_i,
  input                       rd_clk_i,
  input  [ADDR_WIDTH - 1 : 0] rd_addr_i,
  output [DATA_WIDTH - 1 : 0] rd_data_o,
  input                       rd_i
);

localparam DEPTH = 2 ** ADDR_WIDTH;

reg [DATA_WIDTH - 1 : 0] ram_block [DEPTH - 1 : 0];

logic [DATA_WIDTH - 1 : 0] rd_data;

integer i;

always_ff @( posedge wr_clk_i)
  if( wr_i ) 
      ram_block[wr_addr_i] <= wr_data_i;
      
always_ff @( posedge rd_clk_i)
  if( rd_i )
    rd_data <= ram_block[rd_addr_i];

assign rd_data_o = rd_data;

endmodule

