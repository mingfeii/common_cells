module memory_tester # 
(
    parameter WIDTH       = 128,
    parameter ALEN        = 31,
    parameter START_ADDR  = 32'h00000000,
    parameter STOP_ADDR   = 32'h00100000,
    parameter ID_WIDTH      = 8,
    parameter ADDR_WIDTH = 32,
    parameter WUSER_WIDTH = 1,
    parameter AWUSER_WIDTH = 1,
    parameter RUSER_WIDTH = 1,
	parameter BUSER_WIDTH = 1,
	parameter ARUSER_WIDTH = 1
)
(
    input clk,
    input rst_n,


    output  reg                    pass ,





    output logic [ID_WIDTH - 1 : 0]       awid,
    output logic [ADDR_WIDTH - 1 : 0]     awaddr,
    output logic [7 : 0]                  awlen,
    output logic [2 : 0]                  awsize,
    output logic [1 : 0]                  awburst,
    output logic                          awlock,
    output logic [3 : 0]                  awcache,
    output logic [2 : 0]                  awprot,
    output logic [3 : 0]                  awqos,
    output logic [3 : 0]                  awregion,
    output logic [AWUSER_WIDTH - 1 : 0]   awuser,
    output logic                          awvalid,
    input  logic                          awready,
    output logic [WIDTH - 1 : 0]     wdata,
    output logic [WIDTH / 8 - 1 : 0] wstrb,
    output logic                          wlast,
    output logic [WUSER_WIDTH - 1 : 0]    wuser,
    output logic                          wvalid,
    input  logic                          wready,
    input  logic [ID_WIDTH - 1 : 0]       bid,
    input  logic [1 : 0]                  bresp,
    input  logic [BUSER_WIDTH - 1 : 0]    buser,
    input  logic                          bvalid,
    output logic                          bready,
    output logic [ID_WIDTH - 1 : 0]       arid,
    output logic [ADDR_WIDTH - 1 : 0]     araddr,
    output logic [7 : 0]                  arlen,
    output logic [2 : 0]                  arsize,
    output logic [1 : 0]                  arburst,
    output logic                          arlock,
    output logic [3 : 0]                  arcache,
    output logic [2 : 0]                  arprot,
    output logic [3 : 0]                  arqos,
    output logic [3 : 0]                  arregion,
    output logic [ARUSER_WIDTH - 1 : 0]   aruser,
    output logic                          arvalid,
    input  logic                          arready,
    input  logic [ID_WIDTH - 1 : 0]       rid,
    input  logic [WIDTH - 1 : 0]     rdata,
    input  logic [1 : 0]                  rresp,
    input  logic                          rlast,
    input  logic [RUSER_WIDTH - 1 : 0]    ruser,
    input  logic                          rvalid,
    output logic                          rready


    
);
 wire  	[63:0] 	o_total_len;
 wire  	[63:0] 	o_time_counter;
 wire done ;

 axi_ctrl #(
    .WIDTH        (WIDTH       ),   
    .ALEN         (ALEN        ),   
    .START_ADDR   (START_ADDR  ),   
    .STOP_ADDR    (STOP_ADDR   ),   
    .ID_WIDTH     (ID_WIDTH    ),   
    .ADDR_WIDTH   (ADDR_WIDTH  ),   
    .WUSER_WIDTH  (WUSER_WIDTH ),   
    .AWUSER_WIDTH (AWUSER_WIDTH),   
    .RUSER_WIDTH  (RUSER_WIDTH ),   
	.BUSER_WIDTH  (BUSER_WIDTH ),   
	.ARUSER_WIDTH (ARUSER_WIDTH)   
)axi_ctrl_U (
.axi_clk  (clk )         ,
.rstn     (rst_n    )     ,
.start    (rst_n   )     ,
.pass     (pass    )     ,
.o_total_len(o_total_len)             ,
.o_time_counter(o_time_counter)             ,
.test_done     (done    )     ,
.awid     (awid    )     ,
.awaddr   (awaddr  )     ,
.awlen    (awlen   )     ,
.awsize   (awsize  )     ,
.awburst  (awburst )         ,
.awlock   (awlock  )     ,
.awcache  (awcache )         ,
.awprot   (awprot  )     ,
.awqos    (awqos   )     ,
.awregion (awregion)         ,
.awuser   (awuser  )     ,
.awvalid  (awvalid )         ,
.awready  (awready )         ,
.wdata    (wdata   )     ,
.wstrb    (wstrb   )     ,
.wlast    (wlast   )     ,
.wuser    (wuser   )     ,
.wvalid   (wvalid  )     ,
.wready   (wready  )     ,
.bid      (bid     )     ,
.bresp    (bresp   )     ,
.buser    (buser   )     ,
.bvalid   (bvalid  )     ,
.bready   (bready  )     ,
.arid     (arid    )     ,
.araddr   (araddr  )     ,
.arlen    (arlen   )     ,
.arsize   (arsize  )     ,
.arburst  (arburst )         ,
.arlock   (arlock  )     ,
.arcache  (arcache )         ,
.arprot   (arprot  )     ,
.arqos    (arqos   )     ,
.arregion (arregion)         ,
.aruser   (aruser  )     ,
.arvalid  (arvalid )         ,
.arready  (arready )         ,
.rid      (rid     )     ,
.rdata    (rdata   )     ,
.rresp    (rresp   )     ,
.rlast    (rlast   )     ,
.ruser    (ruser   )     ,
.rvalid   (rvalid  )     ,
.rready   (rready  )         



);




reg r_divide_start;
wire [63:0] w_divide_out;

always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
    begin
		r_divide_start <=1'b0;
	end
	else
	begin
		if(done)
			r_divide_start <=1'b1;
		// else
		// 	r_divide_start <=1'b0;
	end
end








Divide
#(
    .WIDTH(64)
)
division0
(
	.clk    (clk),
	.rstn   (rst_n),
	.start  (r_divide_start),
	.N      ((o_total_len*(WIDTH>>3))*100),  //mutiple 256 bit/8 =32byte*100Mhz
	.D      (o_time_counter),
	.Q      (w_divide_out),
    .R      ()
);






endmodule 