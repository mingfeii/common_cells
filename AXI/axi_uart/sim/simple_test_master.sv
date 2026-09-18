//set ID = 0
//set BURST_LENGTH = 0;

module simple_test_master #(

    parameter DATA_WIDTH   = 128,
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 8,
    parameter START_ADDR = 32'h00000000,
    parameter DATA_NUM     = 128


)(
input                                   clk,
input                                   rst_n,

output logic                            fail,

output  logic [ID_WIDTH - 1 : 0]        awid,
output  logic [ADDR_WIDTH - 1 : 0]      awaddr,
output  logic [7 : 0]                   awlen,
output  logic [2 : 0]                   awsize,
output  logic [1 : 0]                   awburst,
output  logic                           awlock,
output  logic [3 : 0]                   awcache,
output  logic [2 : 0]                   awprot,
output  logic [3 : 0]                   awqos,
output  logic [3 : 0]                   awregion,
output  logic                           awvalid,
input   logic                           awready,

output  logic [DATA_WIDTH - 1 : 0]      wdata,
output  logic [DATA_WIDTH / 8 - 1 : 0]  wstrb,
output  logic                           wlast,
output  logic                           wvalid,
input  logic                            wready,

input  logic [ID_WIDTH - 1 : 0]         bid,
input  logic [1 : 0]                    bresp,
input  logic                            bvalid,
output  logic                           bready,

output   logic [ID_WIDTH - 1 : 0]       arid,
output   logic [ADDR_WIDTH - 1 : 0]     araddr,
output   logic [7 : 0]                  arlen,
output   logic [2 : 0]                  arsize,
output   logic [1 : 0]                  arburst,
output   logic                          arlock,
output   logic [3 : 0]                  arcache,
output   logic [2 : 0]                  arprot,
output   logic [3 : 0]                  arqos,
output   logic [3 : 0]                  arregion,
output   logic                          arvalid,
input  logic                            arready,

input  logic [ID_WIDTH - 1 : 0]         rid,
input  logic [DATA_WIDTH - 1 : 0]       rdata,
input  logic [1 : 0]                    rresp,
input  logic                            rlast,
input  logic                            rvalid,
output  logic                           rready

);




localparam WIDTH = $clog2(DATA_NUM+1);

logic [31:0] awcnt_record;
logic [31:0] bcnt_record;
logic [31:0] wcnt_record;
logic [31:0] rcnt_record;


logic [WIDTH-1:0] awcnt;
logic [WIDTH-1:0] bcnt;
logic [WIDTH-1:0] wcnt;
logic [WIDTH-1:0] arcnt;
logic [WIDTH-1:0] rcnt;
logic aw_lock;
logic w_lock;
logic b_lock;
logic ar_lock;
logic r_lock;


// assign wdata = {(DATA_WIDTH/WIDTH){wcnt}};
assign wdata = wcnt;

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n) begin 
        //fixed signal 
        awsize <= 3'b100; 
        awburst <= 2'b01;
        awid <= 0;
        awlen <= 0; //set burst length = 0
        wstrb <= 16'hffff;
        arid <= 0;
        arsize <= 3'b100;
        arburst <= 2'b01;
        arlen <= 0;

        //aw
        awaddr <= START_ADDR;
        awvalid <= 1'b0;
        //b
        bready <= 1'b0;
        //w
        wvalid <= 1'b0;
        wlast <= 1'b0;
        //ar
        araddr <= START_ADDR;
        arvalid <= 1'b0;
        //r
        rready <= 1'b0;
        // other signals 
        awcnt <= 0;
        bcnt <= 0;
        wcnt <= 0;
        awcnt_record <= 0;
        bcnt_record <= 0;
        wcnt_record <= 0;
        rcnt_record <= 0;
        arcnt <= 0;
        rcnt <= 0;
        aw_lock <= 1'b0;
        w_lock <= 1'b0;
        b_lock <= 1'b0;
        ar_lock <= 1'b0;
        r_lock <= 1'b0;
        fail <= 1'b0;
    end else begin 
        //AW 
        if (!aw_lock) awvalid <= 1'b1;
        else awvalid <= 1'b0;

        if (awvalid && awready) begin 
            awaddr <= awaddr + (DATA_WIDTH / 8);
            awcnt <= awcnt + 1'b1;
            awcnt_record <= awcnt_record + 1'b1;
            if (awcnt==DATA_NUM-1)begin 
                awvalid <= 1'b0;
                awaddr <= START_ADDR;
                aw_lock <= 1'b1;
                awcnt <= 0;
            end 
        end 
        //W
        if (!w_lock) begin 
            wvalid <= 1'b1;
            wlast <= 1'b1;
        end else begin 
            wvalid <= 1'b0;
            wlast <= 1'b0;
        end 

        if (wvalid && wready) begin 
            wcnt_record <= wcnt_record + 1'b1;
            wcnt <= wcnt + 1'b1;
            if (wcnt==DATA_NUM-1) begin 
                wvalid <= 1'b0;
                w_lock <= 1'b1;
                wlast <= 1'b0;
                wcnt <= 0;
         
            end 
        end 
        //B
        if (!b_lock) 
            bready <= 1'b1;
        else 
            bready <= 1'b0;

        if (bvalid && bready) begin 
            bcnt <= bcnt + 1'b1;
            bcnt_record <= bcnt_record + 1'b1;
            if (bcnt==DATA_NUM-1) begin 
                bready <= 1'b0;
                bcnt <= 0;
                b_lock <= 1'b1;
                ar_lock <= 1'b0;
                r_lock <= 1'b0;
            end 
        end 
        //AR
        if (aw_lock && w_lock && b_lock && !ar_lock) 
            arvalid <= 1'b1;
        else 
            arvalid <= 1'b0;

        if (arvalid && arready) begin 
            arcnt <= arcnt + 1'b1;
            araddr <= araddr + (DATA_WIDTH / 8);
            if (arcnt==DATA_NUM-1) begin 
                arvalid <= 1'b0;
                ar_lock <= 1'b1;
                arcnt <= 0;
                araddr <= START_ADDR;
            end 
        end 
        //data must come after the address
        if (!r_lock)
            rready <= 1'b1;
        else 
            rready <= 1'b0;

        if (rvalid && rready) begin 
            rcnt <= rcnt + 1'b1;
            rcnt_record <= rcnt_record + 1'b1;
            if (rdata !== rcnt) fail <= 1'b1;
            if (rcnt==DATA_NUM-1) begin 
                rready <= 1'b0;
                r_lock <= 1'b1;
                rcnt <= 0;
                aw_lock <= 1'b0;
                w_lock <= 1'b0;
                b_lock <= 1'b0;
            end 
        end 

    end 


endmodule 