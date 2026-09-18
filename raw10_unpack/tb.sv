`timescale 1ns / 1ns 
module tb();

localparam PW   = 10;
localparam LANE = 4;
localparam DW   = LANE * 8;  // 32-bit input bus
localparam OW   = PW * LANE; // 40-bit output (4 pixels per beat)

localparam USE_RAMDOM_ORDY = 1'b0;

typedef byte byte_s[$];
typedef bit [9:0] raw10_s[$];

typedef bit [DW-1:0] bus_s[$];
bus_s bus_data;
raw10_s raw10_pix;

byte_s byte_pix;
localparam HEIGHT = 2, WIDTH = 512;
bit clk, rst_n;
logic i_rdy;
logic i_val;
logic [DW-1:0]  i_data;
logic o_val;
logic o_rdy;
logic [OW-1:0]  o_data;
int pix_cnt;
initial pix_cnt = 0;
event done;
localparam RANDOM = 0;

reg [PW-1:0] src_mem [HEIGHT*WIDTH];
reg [PW-1:0] out_mem [HEIGHT*WIDTH];

localparam BUS_SZ = HEIGHT * WIDTH * 5 / (DW / 8);  // RAW10: 5 bytes per 4 pixels, DW/8 bytes per bus beat
int bus_cnt;

// ----------------------------------------------------------------
// Clock & Reset
// ----------------------------------------------------------------

initial begin 
    rst_n = 0;
    repeat(100) @(posedge clk);
    rst_n = 1;
end 

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end 

// ----------------------------------------------------------------
// Generate source data -> pack to byte stream -> pack to bus beats
// ----------------------------------------------------------------

initial begin 
    integer i, j;
    bit [PW-1:0] data;
    for (i = 0; i < HEIGHT; i++)
    for (j = 0; j < WIDTH; j++) begin 
        data = RANDOM ? $urandom_range(600, 1000) : data + 1'b1;
        raw10_pix.push_back(data);
        src_mem[i * WIDTH + j] = data;
        $display("src_mem[%0d] = %h", i * WIDTH + j, data);
    end 
    byte_pix = pack_raw10(raw10_pix);
    bus_data  = pack_bus(byte_pix);
    foreach (bus_data[i])
        $display("bus_data[%0d] is %h", i, bus_data[i]);
end 

// ----------------------------------------------------------------
// Wait for all pixels, then check
// ----------------------------------------------------------------

initial begin 
    @done;
    check_data();
    #1000;
    $finish;
end 

// ----------------------------------------------------------------
// Back-pressure: o_rdy generation
// ----------------------------------------------------------------


generate if (USE_RAMDOM_ORDY )


initial begin : GEN_RDY
    o_rdy = 1'b1;
    forever @(posedge clk) begin 
        automatic int rdn = $urandom_range(100);
        if (rdn <= 80 && pix_cnt < WIDTH * HEIGHT)
            o_rdy <= 1'b1;
        else
            o_rdy <= 1'b0;
    end 
end 


else  
    assign o_rdy = 1'b1;

endgenerate 

// ----------------------------------------------------------------
// Capture output: 4 pixels per beat
// ----------------------------------------------------------------

initial begin : GEN_OUT_MEM
    forever @(posedge clk) begin 
        if (o_rdy && o_val) begin 
            for (int k = 0; k < LANE; k++) begin
                out_mem[pix_cnt + k] <= o_data[k*PW +: PW];
            end
            pix_cnt <= pix_cnt + LANE;
        end
        if (pix_cnt >= WIDTH * HEIGHT)
            -> done;
    end
end 

// ----------------------------------------------------------------
// Drive input: pop bus_data queue
// ----------------------------------------------------------------

initial begin : GEN_VAL
    i_val   = 1'b0;
    i_data  = '0;
    bus_cnt = 0;
    @(posedge rst_n);
    // pre-load the first data word
    @(posedge clk);
    i_data = bus_data.pop_front();
    i_val  = 1'b1;
    bus_cnt = 1;
    forever @(posedge clk) begin 
        if (i_val && i_rdy) begin 
            if (bus_cnt < BUS_SZ) begin
                i_data <= bus_data.pop_front();
                i_val  <= 1'b1;
                bus_cnt++;
            end
            else begin
                i_val <= 1'b0;
            end
        end 
    end
end 

// ----------------------------------------------------------------
// Pack functions
// ----------------------------------------------------------------

function automatic bus_s pack_bus(input byte_s d);
    bit [7:0]    byte_data;
    bit [DW-1:0] bus_word;
    localparam IN_BYTES = DW / 8;  // 4 bytes per beat for DW=32
    assert(d.size() % IN_BYTES == 0) else begin 
        $display("total pixel byte number must be multiple of %0d", IN_BYTES);
    end 
    while (d.size() > 0) begin 
        bus_word = '0;
        for (int i = 0; i < IN_BYTES; i++) begin 
            byte_data = d.pop_front();
            bus_word[i*8 +: 8] = byte_data;
        end
        pack_bus.push_back(bus_word); 
    end 
    $display("pack bus done, %0d beats", pack_bus.size());
endfunction 

function automatic byte_s pack_raw10(raw10_s d);
    bit [9:0] pix4[4];
    bit [7:0] msb4[4];
    bit [1:0] lsb4[4];
    assert(d.size() % 4 == 0) else begin
        $display("10-bit pixel number must be multiple of 4");
    end
    while (d.size() >= 4) begin
        for (int i = 0; i < 4; i++) begin
            pix4[i] = d.pop_front();
            msb4[i] = pix4[i][9:2];
            lsb4[i] = pix4[i][1:0];
            pack_raw10.push_back(msb4[i]);
        end
        pack_raw10.push_back({lsb4[3], lsb4[2], lsb4[1], lsb4[0]});
    end
    assert(d.size() == 0);
    $display("pack_raw10 done, %0d bytes", pack_raw10.size());
endfunction

// ----------------------------------------------------------------
// Check result
// ----------------------------------------------------------------

task check_data();
    integer i;
    automatic integer err_cnt = 0;
    for (i = 0; i < WIDTH * HEIGHT; i++) begin 
        if (src_mem[i] !== out_mem[i]) begin 
            $display("MISMATCH: out_mem[%0d]=%h  src_mem[%0d]=%h", i, out_mem[i], i, src_mem[i]);
            err_cnt++;
            if (err_cnt > 20) begin
                $display("Too many errors, stopping...");
                $stop;
            end
        end 
    end 
    if (err_cnt == 0)
        $display("===== DATA CHECK PASS ! =====");
    else
        $display("===== DATA CHECK FAIL: %0d errors =====", err_cnt);
endtask

// ----------------------------------------------------------------
// DUT instantiation
// ----------------------------------------------------------------

unpack_raw #(
    .PW   (PW),
    .LANE (LANE),
    .DW   (DW)
) dut (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_rdy  (i_rdy),
    .i_val  (i_val),
    .i_data (i_data),
    .o_val  (o_val),
    .o_rdy  (o_rdy),
    .o_data (o_data)
);

endmodule 
