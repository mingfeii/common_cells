///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//   Part         : Synchronous FIFO                                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
//   Revision History:                                                       //
//   0.1 : Original for RTL Library                                          //
///////////////////////////////////////////////////////////////////////////////

module XC_SYNC_FIFO_REC (
                clk_i,       // Clock
                rst_i,       // Asynchronous reset
                clr_i,       // reset r/w pointers and clear all fifo contents
                wr_i,        // Write Data to FIFO
                data_i,      // FIFO Data In
                rd_i,        // Advance FIFO Read Pointer
                data_o,      // FIFO Data Out
                full_o,      // Full
                ne_o,        // Not Empty
                af_count_i,  // Almost full count
                ae_count_i,  // Almost empty count
                af_o,        // Almost Full
                ae_o         // Almost empty
);

parameter   WIDTH       = 32;
parameter   DEPTH       = 8;
parameter   LOG2_DEPTH  = 3;

input                       clk_i;
input                       rst_i;
input                       clr_i;
input                       wr_i;
input   [WIDTH-1:0]         data_i;
input                       rd_i;
output  [WIDTH-1:0]         data_o;
output                      full_o;
output                      ne_o;
input   [LOG2_DEPTH-1:0]    af_count_i;
input   [LOG2_DEPTH-1:0]    ae_count_i;
output                      af_o;
output                      ae_o;

reg     [LOG2_DEPTH:0]      r_rd_ptr;
reg     [LOG2_DEPTH:0]      r_wr_ptr;

// Manage the rd/wr pointers
always @(posedge clk_i or posedge rst_i)
begin
    if (rst_i)
    begin
        r_rd_ptr    <= {(LOG2_DEPTH+1){1'b0}};
        r_wr_ptr    <= {(LOG2_DEPTH+1){1'b0}};
    end
    else if (clr_i)
    begin
        r_rd_ptr    <= {(LOG2_DEPTH+1){1'b0}};
        r_wr_ptr    <= {(LOG2_DEPTH+1){1'b0}};
    end
    else
    begin
        if (rd_i)
        begin
            if (r_rd_ptr[LOG2_DEPTH-1:0] == DEPTH-1)
            begin
                r_rd_ptr[LOG2_DEPTH]    <= ~r_rd_ptr[LOG2_DEPTH];
                r_rd_ptr[LOG2_DEPTH-1:0]<= 0;
            end
            else
            begin
                r_rd_ptr[LOG2_DEPTH-1:0]<= r_rd_ptr[LOG2_DEPTH-1:0] + 1'b1;
            end
        end

        if (wr_i)
        begin
            if (r_wr_ptr[LOG2_DEPTH-1:0] == DEPTH-1)
            begin
                r_wr_ptr[LOG2_DEPTH]    <= ~r_wr_ptr[LOG2_DEPTH];
                r_wr_ptr[LOG2_DEPTH-1:0]<= 0;
            end
            else
            begin
                r_wr_ptr[LOG2_DEPTH-1:0]<= r_wr_ptr[LOG2_DEPTH-1:0] + 1'b1;
            end
        end
    end
end

// FIFO Status
wire    full_o;
assign  full_o = (r_wr_ptr[LOG2_DEPTH]      ^ r_rd_ptr[LOG2_DEPTH]    ) &&
                 (r_wr_ptr[LOG2_DEPTH-1:0] == r_rd_ptr[LOG2_DEPTH-1:0]);
wire    ne_o;
assign  ne_o   = (r_wr_ptr != r_rd_ptr);

wire    [LOG2_DEPTH:0]  abs_diff_wr_rd_ptr;
assign  abs_diff_wr_rd_ptr = (r_wr_ptr[LOG2_DEPTH] ^ r_rd_ptr[LOG2_DEPTH]) ? 
                              DEPTH + r_wr_ptr[LOG2_DEPTH-1:0] - r_rd_ptr[LOG2_DEPTH-1:0] :
                                      r_wr_ptr[LOG2_DEPTH-1:0] - r_rd_ptr[LOG2_DEPTH-1:0] ;

wire    af_o;
assign  af_o = abs_diff_wr_rd_ptr >= af_count_i;

wire    ae_o;
assign  ae_o = abs_diff_wr_rd_ptr <= ae_count_i;

// Input is selected by current r_wr_ptr
integer i;
reg     [WIDTH-1:0]   r_fifo_data       [0:DEPTH-1];
always @(posedge clk_i or posedge rst_i)
begin
    if (rst_i)
        for (i=0; i<DEPTH; i=i+1)
            r_fifo_data[i] <= {WIDTH{1'b0}};
    else if (clr_i)
        for (i=0; i<DEPTH; i=i+1)
            r_fifo_data[i] <= {WIDTH{1'b0}};
    else if (wr_i)
         r_fifo_data[r_wr_ptr[LOG2_DEPTH-1:0]] <= data_i;
end

// Output is selected by current r_rd_ptr
reg     [WIDTH-1:0] data_o;
always @(r_rd_ptr or r_fifo_data[r_rd_ptr[LOG2_DEPTH-1:0]])
begin
    data_o = r_fifo_data[r_rd_ptr[LOG2_DEPTH-1:0]];
end

endmodule
