`timescale 1ns / 1ns 

module tb;

// Clock & Reset
logic sys_clk = 0;
logic sys_rst_n = 0;
always #5 sys_clk = ~sys_clk; // 100MHz sys_clk

// SPI Interface
logic miso;
logic mosi;
logic sclk;
logic cs_n;

// Control Interface (Master)
logic [31:0] control;
logic        tx_data_valid;
logic        tx_data_ready;
logic [31:0] tx_data;
logic [31:0] rx_data;
logic        rx_data_valid;
logic        tx_error;
logic        tx_done_pulse;

// Slave Interface
logic tx_data_valid_s;
logic tx_data_ready_s;
logic [31:0] tx_data_s;
logic [31:0] rx_data_s;
logic rx_data_valid_s;

logic [31:0] pkt_tx_data_master,pkt_tx_data_slave;
logic pkt_tx_data_valid_master, pkt_tx_data_ready_master;
logic pkt_tx_data_valid_slave, pkt_tx_data_ready_slave;

logic [31:0] pkt_data_in_master, pkt_data_in_slave;
logic pkt_data_in_valid_master, pkt_data_in_ready_master;   
logic pkt_data_in_valid_slave, pkt_data_in_ready_slave;


reg cpol, cpha;

// 信号声明
logic        pkt_rx_valid;
logic [31:0] pkt_rx_addr;
logic [31:0] pkt_rx_length;
logic [31:0] pkt_rx_data;
logic        pkt_rx_data_valid;
logic [15:0] pkt_rx_id;
logic [15:0] pkt_rx_type;
logic        pkg_rx_start;
logic        pkg_rx_end;
logic        pkt_rx_enable;

//tx master
logic        tx_start_master;        
logic [31:0] tx_base_addr_master;    
logic [31:0] tx_length_master;       
logic [15:0] tx_id_master;          
logic [15:0] tx_packet_type_master;
logic        tx_enable_master;
logic [31:0] tx_data_master;      
logic        tx_data_valid_master;
logic        tx_data_ready_master;
logic        tx_data_end_master;
logic        tx_sending_master;   
//tx slave
logic        tx_start_slave;        
logic [31:0] tx_base_addr_slave;    
logic [31:0] tx_length_slave;       
logic [15:0] tx_id_slave;          
logic [15:0] tx_packet_type_slave;
logic        tx_enable_slave;
logic [31:0] tx_data_slave;      
logic        tx_data_valid_slave;
logic        tx_data_ready_slave;
logic        tx_data_end_slave;
logic        tx_sending_slave;   

logic [31:0] pkt_base_addr;
logic       trigger;

`ifdef SINGLE_TEST
    initial begin
        $display("Running single test mode");
    end

    // DUT - SPI Master
    spi_master dut (
        .sys_clk, .sys_rst_n,
        .miso, .mosi, .sclk, .cs_n,
        .control,
        .tx_data_valid, .tx_data_ready,
        .tx_data,
        .rx_data,
        .rx_data_valid
    );

    // DUT - SPI Slave
    spi_slave uut_slave (
        .sys_clk, .sys_rst_n,
        .mosi, .miso, .sclk, .cs_n,
        .control,
        .tx_data_valid(tx_data_valid_s),
        .tx_data_ready(tx_data_ready_s),
        .tx_error(),
        .tx_done_pulse(),
        .tx_data(tx_data_s),
        .rx_data(rx_data_s),
        .rx_data_valid(rx_data_valid_s)
    );

`else 

// DUT - SPI Master
spi_master dut (
    .sys_clk, .sys_rst_n,
    .miso, .mosi, .sclk, .cs_n,
    .control,
    .tx_data_valid(pkt_tx_data_valid_master), .tx_data_ready(pkt_tx_data_ready_master),
    .tx_data(pkt_tx_data_master),
    .rx_data,
    .rx_data_valid
);

// DUT - SPI Slave
spi_slave uut_slave (
    .sys_clk, .sys_rst_n,
    .mosi, .miso, .sclk, .cs_n,
    .control,
    .tx_data_valid(pkt_tx_data_valid_slave),
    .tx_data_ready(pkt_tx_data_ready_slave),
    .tx_error(),
    .tx_done_pulse(),
    .tx_data(pkt_tx_data_slave),
    .rx_data(rx_data_s),
    .rx_data_valid(rx_data_valid_s)
);


`endif


// spi_packet_rx 例化
spi_packet_rx u_spi_packet_rx (
    .clk           (sys_clk),
    .rst_n         (sys_rst_n),
    .rx_data       (rx_data_s),
    .rx_data_valid (rx_data_valid_s),
    .pkt_rx_enable (pkt_rx_enable),
    .pkt_rx_addr    (pkt_rx_addr),
    .pkt_rx_length  (pkt_rx_length),
    .pkt_rx_data      (pkt_rx_data),
    .pkt_rx_data_valid(pkt_rx_data_valid),
    .pkt_rx_id        (pkt_rx_id),
    .pkt_rx_type      (pkt_rx_type),  
    .pkg_rx_start  (pkg_rx_start),
    .pkg_rx_end    (pkg_rx_end),
    .error()
);


// spi_packet_tx 例化
spi_packet_tx u_spi_packet_tx_master (
    .clk           (sys_clk),
    .rst_n         (sys_rst_n),
    .data_in       (pkt_data_in_master),
    .data_in_valid (pkt_data_in_valid_master),
    .data_in_ready (pkt_data_in_ready_master),
    // .tx_start         (tx_start_master),
    .tx_base_addr  (tx_base_addr_master),
    .tx_length     (tx_length_master),
    .tx_data       (pkt_tx_data_master),
    .tx_data_valid (pkt_tx_data_valid_master),
    .tx_data_ready (pkt_tx_data_ready_master),
    .tx_packet_type (tx_packet_type_master),
    .tx_id         (tx_id_master),
    .tx_data_end   (tx_data_end_master),
    .tx_enable     (tx_enable_master),
    .sending       (tx_sending_master),
    .error         ()
);

logic pkt_error_master;
// 实例化 packet_generate
packet_generate u_packet_generate_master (
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .trigger(trigger),
    .length(tx_length_master),
    .start(tx_start_master),
    .data_in(pkt_data_in_master),
    .data_in_valid(pkt_data_in_valid_master),
    .data_in_ready(pkt_data_in_ready_master),
    .busy(tx_sending_master), // 连接到 spi_packet_tx 的 sending
    .error(pkt_error_master)
);


spi_packet_tx u_spi_packet_tx_slave (
    .clk           (sys_clk),
    .rst_n         (sys_rst_n),
    .data_in       (pkt_data_in_slave),
    .data_in_valid (pkt_data_in_valid_slave),
    .data_in_ready (pkt_data_in_ready_slave),
    // .tx_start         (tx_start_slave),
    .tx_base_addr  (tx_base_addr_slave),
    .tx_length     (tx_length_slave),
    .tx_data       (pkt_tx_data_slave),
    .tx_data_valid (pkt_tx_data_valid_slave),
    .tx_data_ready (pkt_tx_data_ready_slave),
    .tx_packet_type (tx_packet_type_slave),
    .tx_id         (tx_id_slave),
    .tx_data_end   (tx_data_end_slave),
    .tx_enable     (tx_enable_slave),
    .sending       (tx_sending_slave),
    .error         ()
);

logic pkt_error_slave;
// 实例化 packet_generate
packet_generate u_packet_generate_slave (
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .trigger(trigger),
    .length(tx_length_slave),
    .start(tx_start_slave),
    .data_in(pkt_data_in_slave),
    .data_in_valid(pkt_data_in_valid_slave),
    .data_in_ready(pkt_data_in_ready_slave),
    .busy(tx_sending_slave), // 连接到 spi_packet_tx 的 sending
    .error(pkt_error_slave)
);


// Internal
parameter TEST_DATA1 = 32'hA5_5A_3C_3C;
parameter TEST_DATA2 = 32'hFF_00_AA_55;
parameter TEST_DATA3 = 32'h00_00_00_00;
parameter TEST_DATA4 = 32'h93_34_56_87;
parameter TEST_DATA5 = 32'ha3_34_56_87;

logic [31:0] expected_rx_data;
logic [31:0] expected_rx_data_s;
int error_count = 0;

// Test all 4 SPI modes with different configurations
logic [31:0] test_data_patterns [0:3] = {TEST_DATA1, TEST_DATA2, TEST_DATA3, TEST_DATA4};
int bit_lengths [0:2] = {7, 15, 31}; // 8-bit, 16-bit, 32-bit
logic [15:0] burst_len [0:2] = {'h1, 'h1, 'h1}; // Dividers


reg [31:0] transfer_length;

initial begin
    $display("---- SPI Master and Slave Testbench ----");
    sys_rst_n = 0;
    tx_data_valid_s = 0;
    cpol = 0; // CPOL = 0
    cpha = 0; // CPHA = 0
    tx_data_s = 32'h0;
    trigger = 0;
    transfer_length = 0;
    pkt_rx_enable = 0; // Disable packet reception initially
    
    tx_base_addr_master = 32'h0;
    tx_length_master = 0;
    tx_packet_type_master = 16'h0002a; // Example packet type
    tx_id_master = 16'h1234; // Example ID
    tx_enable_master = 0; // Enable master transmission

    tx_base_addr_slave = 32'h0;
    tx_length_slave = 0;
    tx_packet_type_slave = 16'h0002a; // Example packet type
    tx_id_slave = 16'h1234; // Example ID
    tx_enable_slave = 0; // Enable slave transmission
    // tx_start_master = 0; // Start master transmission
    // tx_start_slave = 0; // Start slave transmission


    repeat (5) @(posedge sys_clk);
    sys_rst_n = 1;
    repeat (5) @(posedge sys_clk);
`ifdef SINGLE_TEST
    //below is simple dierct spi test
    $display("TEST SPI TRANSFER is ok ");
    // run_spi_mode_multi_test(0, 1, 7, 2, {TEST_DATA4,TEST_DATA1}, {TEST_DATA2,TEST_DATA4});
    // run_spi_mode_multi_test(1, 1, 7, 2, {TEST_DATA4,TEST_DATA1}, {TEST_DATA2,TEST_DATA4});
    // run_spi_mode_multi_test(0, 1, 31, 2, {TEST_DATA4,TEST_DATA1}, {TEST_DATA2,TEST_DATA4});
    // run_spi_mode_multi_test(1, 1, 31, 2, {TEST_DATA4,TEST_DATA1}, {TEST_DATA2,TEST_DATA4});
    // run_spi_mode_multi_test(1, 1, 31, 1, {TEST_DATA4}, {TEST_DATA4});
    // run_spi_mode_multi_test(0, 1, 31, 1, {TEST_DATA2}, {TEST_DATA1});
    // run_spi_mode_multi_test(1, 1, 31, 5, {TEST_DATA1,TEST_DATA2,TEST_DATA3,TEST_DATA4,TEST_DATA5}, {TEST_DATA5,TEST_DATA4,TEST_DATA3,TEST_DATA2,TEST_DATA1});
    // run_spi_mode_multi_test(0, 1, 31, 5, {TEST_DATA1,TEST_DATA2,TEST_DATA3,TEST_DATA4,TEST_DATA5}, {TEST_DATA5,TEST_DATA4,TEST_DATA3,TEST_DATA2,TEST_DATA1});
`else 
    $display("TEST SPI TRANSFER with packet ");
    repeat (5) @(posedge sys_clk);
    // pkt_start = 1'b1;
    transfer_length = 16; // 256 bytes
    tx_length_master = transfer_length;// 256 bytes
    tx_length_slave = transfer_length;// 256 bytes
    tx_base_addr_master = 32'habcd_0000; // Base address for master packet
    tx_base_addr_slave = 32'habcd_2000; // Base address for slave packet
    tx_enable_master = 1; // Enable master transmission
    tx_enable_slave = 1; // Enable slave transmission
    // tx_start_master = 1; // Start master transmission
    // tx_start_slave = 1; // Start slave transmission

    cpol = 1'b0; // CPOL = 0
    cpha = 1'b1; // CPHA = 0
    
    //############### spi master 模式1 第一次传输
    //cs_n一个包一个包的传输
    control = {16'd1, 5'd31, 3'b111, 3'b000, cpol, cpha, 3'b001};
    $display("Control Word: 0x%h", control);
    repeat (5) @(posedge sys_clk);
    pkt_rx_enable = 1; // Enable packet reception
    trigger = 1;
    repeat (5) @(posedge sys_clk);
    trigger = 0;

    @(posedge pkg_rx_end);
    repeat (5) @(posedge sys_clk);
    //############### spi master 模式2 第二次传输
    //cs_n一个整大包传输，对于spi master来说要明确一个cs_n里面传输了多个
    //transfer_length[31:2] + SYNC_word + SEND_ADDR + SEND_LEN + SEND_ID + crc_header + crc_data
    control = {(transfer_length[31:2]+24/4), 5'd31, 3'b010, 3'b000, cpol, cpha, 3'b001};
    $display("Control Word: 0x%h", control);
    repeat (5) @(posedge sys_clk);
    pkt_rx_enable = 1; // Enable packet reception
    trigger = 1;
    repeat (5) @(posedge sys_clk);
    trigger = 0;

    @(posedge pkg_rx_end);
    repeat (5) @(posedge sys_clk);
    $finish;




`endif 

    $display("All tests completed. Errors: %0d", error_count);
end



// initial begin
//     wait (pkg_rx_end);
//     $display("Packet Reception Completed");
//     repeat (10) @(posedge sys_clk);
//     $finish;
// end




task automatic run_spi_mode_multi_test(
    input logic cpol, input logic cpha, 
    input int bitlen, input [15:0] burst_len, 
    input [31:0] master_tx_data [], input [31:0] slave_tx_data []
);
    // Setup parameters
    logic [31:0] ctrl_word = {burst_len, bitlen[4:0], 3'b010, 3'b000, cpol, cpha, 3'b001};
    logic [31:0] mask;
    logic [31:0] expected_rx_data [];
    logic [31:0] expected_rx_data_s [];
    control = ctrl_word;
    tx_data_valid = 0;
    tx_data_valid_s = 0;

    // Create mask for relevant bits (bitlen+1 bits)
    mask = (1 << (bitlen + 1)) - 1; // e.g., for bitlen=7, mask=32'h000000FF

    // Allocate and set expected data arrays
    expected_rx_data = new[burst_len];
    expected_rx_data_s = new[burst_len];
    for (int i = 0; i < burst_len; i++) begin
        expected_rx_data[i] = slave_tx_data[i] & mask;  // Master receives slave's tx_data
        $display("Master expected data[%0d] = 0x%h", i, expected_rx_data[i]);
        expected_rx_data_s[i] = master_tx_data[i] & mask; // Slave receives master's tx_data
        $display("Slave expected data[%0d] = 0x%h", i, expected_rx_data_s[i]);
    end

    // Wait for stable system
    repeat (2) @(posedge sys_clk);

    //fill slave tx_data
    for (int i = 0; i < burst_len; i++) begin
        tx_data_s = slave_tx_data[i];
        tx_data_valid_s = 1;
        tx_data = master_tx_data[i];
        tx_data_valid = 1;
        @(posedge sys_clk);
        while (!tx_data_ready_s || !tx_data_ready) @(posedge sys_clk);
        tx_data_valid_s = 0;
        tx_data_valid = 0;

        repeat (5) @(posedge sys_clk);
    end 

    // Start burst transaction
    for (int i = 0; i < burst_len; i++) begin
        @(posedge sys_clk);
        // Wait for receive done independently for each transfer
        fork
            begin
                @(negedge rx_data_valid);
                // Check master received data
                if ((rx_data & mask) !== expected_rx_data[i]) begin
                    $display("ERROR: SPI Mode CPOL=%0d, CPHA=%0d, Bitlen=%0d, BurstLen=%0d, Transfer=%0d, Master Expected=0x%h, Got=0x%h",
                             cpol, cpha, bitlen+1, burst_len, i, expected_rx_data[i], rx_data & mask);
                    error_count++;
                end else begin
                    $display("PASS:  SPI Mode CPOL=%0d, CPHA=%0d, Bitlen=%0d, BurstLen=%0d, Transfer=%0d, Master Received=0x%h",
                             cpol, cpha, bitlen+1, burst_len, i, rx_data & mask);
                end
            end
            begin
                @(negedge rx_data_valid_s);
                // Check slave received data
                if ((rx_data_s & mask) !== expected_rx_data_s[i]) begin
                    $display("ERROR: SPI Mode CPOL=%0d, CPHA=%0d, Bitlen=%0d, BurstLen=%0d, Transfer=%0d, Slave Expected=0x%h, Got=0x%h",
                             cpol, cpha, bitlen+1, burst_len, i, expected_rx_data_s[i], rx_data_s & mask);
                    error_count++;
                end else begin
                    $display("PASS:  SPI Mode CPOL=%0d, CPHA=%0d, Bitlen=%0d, BurstLen=%0d, Transfer=%0d, Slave Received=0x%h",
                             cpol, cpha, bitlen+1, burst_len, i, rx_data_s & mask);
                end
            end
        join
    end

    // Wait for transaction to complete
    repeat (20) @(posedge sys_clk);
endtask

endmodule