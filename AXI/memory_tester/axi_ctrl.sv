
module axi_ctrl #(
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
	parameter ARUSER_WIDTH = 1,
    parameter ADDR_OFFSET = (ALEN + 1)*(WIDTH/8)
) (
input                       axi_clk,
input                       rstn,
input                       start,

output  reg                    pass ,
output reg 	[63:0] 	o_total_len,
output reg 	[63:0] 	o_time_counter,

output 					test_done ,



output logic  [ID_WIDTH - 1 : 0]       awid,
output logic  [ADDR_WIDTH - 1 : 0]     awaddr,
output logic  [7 : 0]                  awlen,
output logic  [2 : 0]                  awsize,
output logic  [1 : 0]                  awburst,
output logic                           awlock,
output logic  [3 : 0]                  awcache,
output logic  [2 : 0]                  awprot,
output logic  [3 : 0]                  awqos,
output logic  [3 : 0]                  awregion,
output logic  [AWUSER_WIDTH - 1 : 0]   awuser,
output logic                           awvalid,
input  logic                           awready,
output logic  [WIDTH - 1 : 0]     wdata,
output logic  [WIDTH / 8 - 1 : 0] wstrb,
output logic                           wlast,
output logic  [WUSER_WIDTH - 1 : 0]    wuser,
output logic                           wvalid,
input  logic                           wready,
input  logic  [ID_WIDTH - 1 : 0]       bid,
input  logic  [1 : 0]                  bresp,
input  logic  [BUSER_WIDTH - 1 : 0]    buser,
input  logic                           bvalid,
output logic                           bready,
output logic  [ID_WIDTH - 1 : 0]       arid,
output logic  [ADDR_WIDTH - 1 : 0]     araddr,
output logic  [7 : 0]                  arlen,
output logic  [2 : 0]                  arsize,
output logic  [1 : 0]                  arburst,
output logic                           arlock,
output logic  [3 : 0]                  arcache,
output logic  [2 : 0]                  arprot,
output logic  [3 : 0]                  arqos,
output logic  [3 : 0]                  arregion,
output logic  [ARUSER_WIDTH - 1 : 0]   aruser,
output logic                           arvalid,
input  logic                           arready,
input  logic  [ID_WIDTH - 1 : 0]       rid,
input  logic  [WIDTH - 1 : 0]     rdata,
input  logic  [1 : 0]                  rresp,
input  logic                           rlast,
input  logic  [RUSER_WIDTH - 1 : 0]    ruser,
input  logic                           rvalid,
output logic                           rready



);


logic [7:0]    alen;
logic  [31:0]   aaddr;
logic 			aready;
logic 			avalid;
logic [2:0]     asize;
logic [1:0]     aburst;
logic  [1:0]    alock;

assign awaddr = aaddr;
assign araddr = aaddr;
assign arlen = alen;
assign awlen = alen;
assign arsize = asize;
assign awsize = asize;
assign awburst = aburst;
assign arburst = aburst;
assign awlock = alock;
assign arlock = alock;
reg atype;

assign aready = (atype & awready ) | (!atype & arready);
assign awvalid= avalid & atype;
assign arvalid= avalid & ~atype;

///////////////////////////////////////////////////////////////////////////////
localparam  ASIZE = (WIDTH == 256)? 5 :
                    (WIDTH == 128)? 4 :
                    (WIDTH == 64)?  3 : 2;

//Main states
localparam  COMPARE_WIDTH = WIDTH;
enum int unsigned {
			IDLE , 
	        WRITE_ADDR ,
	        PRE_WRITE ,
	        WRITE ,
	        POST_WRITE,
	        READ_ADDR ,
	        PRE_READ ,
	        READ_COMPARE ,
	        POST_READ ,
	        DONE,
			FINISH
}states,nstates;



assign test_done = states == DONE;


//reg [3:0] states, nstates;
reg             fail;
reg             done;
// reg [3:0]       states;
// reg [3:0]       nstates;
reg             bvalid_done;
reg [1:0]       start_sync;
reg [8:0]       write_cnt, read_cnt;
reg [WIDTH-1:0] rdata_store;
reg             wburst_done, 
                rburst_done, 
                write_done, 
                read_done;

///////////////////////////////////////////////////////////////////////////////
    assign awid   = 8'h00;
	assign arid   = 8'h00;
    assign wstrb = 16'hffff;


    // assign pass  = done & ~fail;

	always_ff@(posedge axi_clk or negedge rstn)
		if (~rstn)
			pass <= 1'b0;
		else 
			pass <= ~fail;
		// else if (done)
		// 	pass <= ~fail;
    
    always @(posedge axi_clk or negedge rstn) 
    begin
    	if (!rstn) begin
    		start_sync <= 2'b00;
    	end else begin
    		start_sync[0] <= start;
    		start_sync[1] <= start_sync[0];
    	end
    end
    

always @ (posedge axi_clk or negedge rstn)
begin
    if(~rstn)
    begin
        o_time_counter         <=  64'b0;
    end
    else
    begin
        if(states !== IDLE)
		begin
				o_time_counter 	<=  o_time_counter +1'b1;
		end
            
    end
end




    always @(posedge axi_clk or negedge rstn) 
    begin
     	if (!rstn) begin
    	    states <= IDLE;
    	end else begin
    	    states <= nstates;
    	end
    end
    
always_comb    
begin
    	case(states) 
    	IDLE 	   : 
        if (start_sync[1] || done==1) 			
            nstates = PRE_WRITE;
    	else					
            nstates = IDLE;
    	PRE_WRITE : 
        if (aready && avalid)				
            nstates = WRITE;
    	else					
            nstates = PRE_WRITE;

    	WRITE	   : 
        if (write_cnt == 9'd0)			
            nstates = POST_WRITE;
    	else		 			
            nstates = WRITE;
    	POST_WRITE : 
        if (write_done & bvalid_done) 		
            nstates = READ_ADDR;
    	else if (bvalid_done)			
            nstates = WRITE_ADDR;
    	else					
            nstates = POST_WRITE;
    	READ_ADDR  : 
        if (aready) 				
            nstates = PRE_READ;
    	else					
            nstates = READ_ADDR;
    	PRE_READ   :						
        nstates = READ_COMPARE;
    	READ_COMPARE  : 
        if (rburst_done) 			
            nstates = POST_READ;
    	else					
            nstates = READ_COMPARE;
    	POST_READ  :	
        if (read_done) 				
            nstates = DONE;
    	else					
            nstates = READ_ADDR;
    	DONE	   : 						
        // nstates = FINISH;
        nstates = IDLE;
		// FINISH: nstates = FINISH;
    	default	   :
        nstates = IDLE;
    	endcase
    end



	always@(posedge axi_clk or negedge rstn)
		if(~rstn)
			o_total_len <= 0;
		else if ((bvalid && bready) || (rvalid && rready && rlast))
			o_total_len <= o_total_len + (alen + 1'b1);
    
    always @(posedge axi_clk or negedge rstn) 
    begin
    	if (!rstn) begin
    		aaddr       <= START_ADDR;
    		avalid      <= 1'b0;
    		atype       <= 1'b0;
    		aburst      <= 2'b00;
    		asize       <= 3'b000;
    		alen        <= 8'd0;
    		alock       <= 2'b00;
    		wvalid      <= 1'b0;
    		write_cnt   <= ALEN + 1;
    		write_done  <= 1'b0;
    		wdata       <= {WIDTH{1'b0}};
    		wburst_done <= 1'b0;
    		wlast       <= 1'b0;
    		bready      <= 1'b0;
    		fail        <= 1'b0;
    		done        <= 1'b0;
    		rready      <= 1'b0;
    		bvalid_done <=1'b0;
    	end 
        else 
        begin
    		if (states == IDLE) 
            begin
    	        aaddr       <= START_ADDR;
    	        avalid      <= 1'b0;
                atype       <= 1'b0;
                aburst      <= 2'b00;
                asize       <= 3'b000;
                alen        <= 8'd0;
                alock       <= 2'b00;
                wvalid      <= 1'b0;
                write_cnt   <= ALEN + 1;
                wdata       <= {WIDTH{1'b0}};
                wburst_done <= 1'b0;
                wlast       <= 1'b0;
                bready      <= 1'b0;
    		    rready      <= 1'b0;
    		    bvalid_done <= 1'b0;
    		    // fail        <= 1'b0;
    		    done        <= 1'b0;
    		end

    		if (states == PRE_WRITE) 
            begin
				if (avalid && aready)
					atype      <= 1'b0;
				else 
					atype      <= 1'b1;
				avalid      <= 1'b1;
    			asize       <= ASIZE;
    			alen        <= ALEN;
    			aburst      <= 2'b01;
    			alock       <= 2'b00;
    			write_cnt   <= ALEN + 1;
    			wburst_done <= 1'b0;
    			bvalid_done <= 1'b0;
    			rready      <= 1'b0;
    			done        <= 1'b0;
				
    			wvalid      <= 1'b1;
    			wdata       <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~write_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{write_cnt[7:0]}}};
    			bready      <= 1'b1;
                if(alen == 'd0)
                begin
                    wlast <= 1'b1;
                end
    		end
    		if (states == WRITE) 
            begin
    			if (wready == 1'b1) 
                begin
    			    wdata   <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~write_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{write_cnt[7:0]}}};
    				if (write_cnt == 9'd0) 
                    begin
    				    wburst_done <= 1'b1;
    				    wlast       <= 1'b0;
    				    wvalid      <= 1'b0;
    					if (aaddr >= STOP_ADDR) 
                        begin
    					    write_done <= 1'b1;
    					end else 
                        begin
    					    write_done <= 1'b0;
    					end
    				end if (write_cnt == 9'd1) 
                    begin
    					wlast     <= 1'b1;
    					write_cnt <= write_cnt - 1;
    				end 
                    else 
                    begin
    				    write_cnt <= write_cnt - 1;
    				end
    			end
    		end
    		if (states == POST_WRITE) 
            begin
    			if (write_done) 
                begin
    				    aaddr <= START_ADDR;
    			end 
                else 
                begin
    				if (bvalid) begin
    				    aaddr <= aaddr + ADDR_OFFSET;
    				end
    			end
    			if (wready == 1'b1) 
                begin
    				wlast   <= 1'b0;	
    				wvalid  <= 1'b0;	
    			end
    			if (bvalid) 
                begin
    				bvalid_done <= 1'b1;
    				bready      <= 1'b0;
    			end
    		end
    		if (states == READ_ADDR) 
            begin
    			avalid   <= 1'b1;
    			read_cnt <= ALEN + 1;
    				
    		end
    		if (states == PRE_READ) 
            begin
    			avalid      <= 1'b0;
    			rburst_done <= 1'b0;
                rdata_store <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~read_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{read_cnt[7:0]}}};
    			read_cnt    <= read_cnt - 1'b1;
    		end
    		if (states == READ_COMPARE) 
            begin
    			rready <= 1'b1;
    			if (read_cnt != 9'd0) 
                begin
    			    if (rvalid == 1'b1) 
                    begin
                        rdata_store <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~read_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{read_cnt[7:0]}}};
    			        read_cnt <= read_cnt - 1'b1;
    				    if (rdata[COMPARE_WIDTH-1:0] != rdata_store[COMPARE_WIDTH-1:0]) 
    					    fail <= 1'b1;
    				    // else 
                            // fail <= 1'b0;
    				end
    	
    			end
    		end
    		if (read_cnt == 9'd0) 
            begin
    	        if (rvalid == 1'b1) 
                begin
                    if (rdata[COMPARE_WIDTH-1:0] != rdata_store[COMPARE_WIDTH-1:0]) 
                    begin
                        fail <= 1'b1;
                    end 
                    // else 
                    // begin
                    //     // fail <= 1'b0;
                    // end
    				if (aaddr >= STOP_ADDR) 
                    begin
    					read_done <= 1'b1;
    				end 
                    else 
                    begin
    					read_done <= 1'b0;
    				end
    				rburst_done <= 1'b1;
    			end
    		end
    		if (states == POST_READ) 
            begin
    			aaddr <= aaddr + ADDR_OFFSET;
    			rready <= 1'b1;
    		end
    		if (states == DONE)
            begin
    			done <= 1'b1;
    		end
    	end
    end
endmodule
