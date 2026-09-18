
module pipeline_data_delay #(parameter 
	LATENCY=2,
	DW=32

)(
	input clk,
	input rst_n,
	input [DW-1:0] in_data,
	output reg [DW-1:0] o_data
);

generate 

	if(LATENCY==0)begin:NO_DELAY
		
		always@(*) o_data = in_data;
	end 
	else if (LATENCY==1)begin:DELAY1

		reg [DW-1:0] o_data_1r;
		always@(posedge clk or negedge rst_n)begin
			if (!rst_n)
				o_data_1r <= 0;
			else 
				o_data_1r <= in_data;
		end

		always@(*) o_data = o_data_1r;
	end

	else begin:DWLAYN

		reg [DW-1:0] mem [LATENCY-2:0];
		reg [DW-1:0] o_data_1r;

		always@(posedge clk or negedge rst_n) begin:DLY_PIPE_BLK
			integer i;
			if (!rst_n) begin 
				for (i = 0; i <= LATENCY-2; i = i + 1) begin 
					mem[i] <= 0;
				end 
			end else begin 
				for (i = 0; i <= LATENCY-2; i = i + 1) begin 
					mem[i] <= i == 0 ? in_data :  mem[i-1];
				end 
			end 
		end
			
		always@(posedge clk or negedge rst_n)
			if (!rst_n)
				o_data_1r <= 0;
			else 
				o_data_1r <= mem[LATENCY-2];

		always@(*) o_data = o_data_1r;
	end
endgenerate

endmodule 