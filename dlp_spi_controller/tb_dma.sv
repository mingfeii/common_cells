/*
验证策略：
1. 每次驱动spi master发送一个命令，命令可以有以下的类型
   - 读DDR数据，burst模式
   - 写DDR数据，burst模式
   - 读寄存器，单个寄存器
   - 写寄存器，单个寄存器
   spi master发送的数据可以从地址开始加加的地址数据，方便check。
2.spi master 仿真模型 每次发送写命令后， spi_slave dut会把数据接收后写到ddr里（写单个寄存器也写到ddr中）
    * 3. 有task检查返回到spi master的ack 包的状态是否符号预期,同时检测数据是否加加。

3. 检查读dma的正确性，同样读取一段从地址加加的地址数据，检查ack数据的正确性。

4. spi master发送时能构造出包头错误的包，检查spi slave的错误处理能力。

*/

`timescale 1ns / 1ns 

module tb;

// Clock & Reset
logic sys_clk = 0;
logic sys_rst_n = 0;
always #5 sys_clk = ~sys_clk; // 100MHz sys_clk

parameter WIDTH_MAX = 1280;
parameter HEIGHT_MAX = 960;
parameter PW = 32;
parameter AW = 32;
parameter DW = 32; //fixed to 32
parameter DMA_BL = 3;
parameter BL = 4;
parameter APB_AW = 6;
parameter ID = 32'hACC;
parameter FN = 1;

localparam SZ = WIDTH_MAX * HEIGHT_MAX;

parameter   BUSNW=1,//write channel
            BUSNR=2,// read channel 
            SDR_ARDY_RATE=100,
            SDR_SZ=2**25;
//define custom transfer


localparam BASE0_ADDR = 32'h0000;

integer done_cnt;
logic [31:0] tx_cnt;

logic [31:0] tx_mem [SZ-1:0];


logic  [BUSNR-1:0]          bus_rrdy ;
logic  [BUSNR-1:0]          bus_rval ;
logic  [BUSNR-1:0] [BL-1:0] bus_rlen ;
logic  [BUSNR-1:0] [AW-1:0] bus_raddr;
logic  [BUSNR-1:0] [DW-1:0] bus_rdata;
logic  [BUSNR-1:0]          bus_rdval;
logic  [BUSNW-1:0]          bus_wrdy ;
logic  [BUSNW-1:0]          bus_wval;
logic  [BUSNW-1:0] [BL-1:0] bus_wlen;
logic  [BUSNW-1:0] [AW-1:0] bus_waddr;
logic  [BUSNW-1:0] [DW-1:0] bus_wdata;
logic                       sdr_wrdy ;
logic                       sdr_wval ;
logic              [BL-1:0] sdr_wlen ;
logic              [AW-1:0] sdr_waddr;
logic              [DW-1:0] sdr_wdata;
logic                       sdr_rrdy ;
logic                       sdr_rval ;
logic              [BL-1:0] sdr_rlen ;
logic              [AW-1:0] sdr_raddr;
logic              [DW-1:0] sdr_rdata;
logic                       sdr_rdval;

logic          src_bus_rrdy;
logic          src_bus_rval;
logic [BL-1:0] src_bus_rlen;
logic [AW-1:0] src_bus_raddr;
logic [DW-1:0] src_bus_rdata;
logic          src_bus_rdval;


assign  src_bus_rrdy=bus_rrdy;
assign  src_bus_rdval=bus_rdval;
assign  src_bus_rdata=bus_rdata;
assign  bus_rval=src_bus_rval;
assign  bus_rlen=src_bus_rlen;
assign  bus_raddr=src_bus_raddr;



// SPI Interface
logic miso;
logic mosi;
logic sclk;
logic cs_n;

logic [31:0] control;
logic dma_done_R;
logic dma_done_w;


logic [31:0] rx_data_master;
logic rx_data_valid_master;

logic [31:0] data_in_master;
logic data_in_valid_master;
logic data_in_ready_master;
logic [31:0] tx_base_addr_master;
logic [31:0] tx_length_master;
logic [15:0] tx_packet_type_master;
logic [15:0] tx_id_master;
logic tx_data_end_master;
logic tx_enable_master;
logic tx_sending_master;
logic read_cmd_is_master;
logic ack_ready_master;
logic sim_wr;
logic bypass_syncword_master;

logic[31:0] tx_data_master;
logic tx_data_valid_master;
logic tx_data_ready_master;

wire rx_crc_header_err = u_spi_slave_top.header_crc_error;
wire rx_crc_data_err = u_spi_slave_top.data_crc_error;
wire rx_pkt_rx_end = u_spi_slave_top.pkt_rx_end;

//rx package for master side 
logic [31:0] pkt_rx_addr_master;
logic [31:0] pkt_rx_length_master;
logic [31:0] pkt_rx_data_master;
logic pkt_rx_data_valid_master;
logic [15:0] pkt_rx_id_master;
logic [15:0] pkt_rx_type_master;
logic pkt_rx_start_master;
logic pkt_rx_end_master;
logic pkt_rx_data_last_master;
logic header_crc_error_master;
logic data_crc_error_master;
logic pkg_rx_error_master;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        done_cnt <= 0;
    else if (tx_data_end_master)
        done_cnt <= done_cnt + 1'b1;

always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        tx_cnt <= 0;
    else if (tx_data_end_master)
        tx_cnt <= 0;
    else if (data_in_valid_master && data_in_ready_master)
        tx_cnt <= tx_cnt + 1'b1;

always @(posedge sys_clk)
    if (data_in_valid_master && data_in_ready_master)
        tx_mem[tx_cnt] <= data_in_master;


reg [31:0] transfer_length;
logic [31:0] base_addr;
logic [31:0] length;
logic [15:0] packet_type;
logic [15:0] id;

initial begin
    sys_rst_n = 0;
    tx_base_addr_master = 0;
    tx_length_master = 0;
    tx_packet_type_master = 0;
    tx_id_master = 0;
    tx_enable_master = 1'b1;
    sim_wr = 1'b0;
    data_in_valid_master = 1'b0;
    data_in_master = 0;
    bypass_syncword_master = 1'b0; // 默认不绕过同步字

    //initial internal signals
    base_addr = 0;
    length = 0;
    packet_type = 0;
    id = 0;
    transfer_length = 0;
    read_cmd_is_master = 0;

    repeat (5) @(posedge sys_clk);
    sys_rst_n = 1;
    repeat (5) @(posedge sys_clk);

/* ==========  tset 0  test spi burst dma write ==============*/    
    $display("********************* TEST Write DDR with burst mode *********************");
    repeat (5) @(posedge sys_clk);

    transfer_length = 4096; // 1024 bytes
    length = transfer_length;
    id = 'h2;
    packet_type = 16'h00; // 0x00 for write DDR command
    base_addr = 32'h1000; // Starting address for the transfer
    sim_wr = 1'b1;
    //配置spi master 
    control = {(transfer_length[31:2]+24/4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};
    fork 
        begin  
            drv_spi_master_packet_tx(base_addr, length, packet_type, id);
            control = {(transfer_length[31:2]+24/4+4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};
            //这里只是重新写，提供等待ack的时钟，0x9000是一个特殊的地址，不用管
            bypass_syncword_master = 1'b1; // 绕过同步字
            drv_spi_master_packet_tx(32'h9000, length, 16'h0000, id);
        end 
        begin 
            //等待ack包
            check_ack_packet(0, id, base_addr, 1'b0); // 0: OK status, 1: read command
        end
    join 
    bypass_syncword_master = 1'b0; // 绕过同步字
    sim_wr = 1'b0; //

/* ==========  tset 1  test spi burst dma read ==============*/    
    $display("********************* TEST Read DDR with burst mode *********************");
    repeat (5) @(posedge sys_clk);

    transfer_length = 4096; // 1024 bytes
    length = transfer_length;
    id = 'h5678;
    packet_type = 16'h01; // 0x01 for read DDR command
    base_addr = 32'h1000; // Starting address for the transfer
    sim_wr = 1'b0;
    repeat (5) @(posedge sys_clk);

    //配置spi master
    control = {(transfer_length[31:2]+24/4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};
    fork
        begin
            drv_spi_master_packet_tx(base_addr, length, packet_type, id);

            /*
                must wait command send done !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                then pull down bypass_syncword_master, other wise read cmd can not send correctly
            */
            repeat(1000)@(posedge sys_clk);


            bypass_syncword_master = 1'b1; // 绕过同步字
            sim_wr = 1'b1;//
            control = {(transfer_length[31:2]+24/4+4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};
            drv_spi_master_packet_tx(32'h9000, length+4, 16'h0000, id);
            drv_spi_master_packet_tx(32'h9000, length+4, 16'h0000, id);

        end
        begin
            //等待ack包
            check_ack_packet(0, id, base_addr, 1'b1); // 0: OK status, 1: read command
        end
    join

    bypass_syncword_master = 1'b0; // 绕过同步字
    sim_wr = 1'b0;//



/* ==========  tset 3  test spi signle reg write ==============*/    
    $display("********************* TEST Write REG with signle mode *********************");
    repeat (5) @(posedge sys_clk);

    transfer_length = 4; // 4 bytes signle register write
    length = transfer_length;
    id = 'h9abc;
    packet_type = 16'h02; // 0x02 for write register command
    base_addr = 32'h2900; // Starting address for the transfer
    sim_wr = 1'b1;
    //配置spi master 
    control = {(transfer_length[31:2]+24/4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};

    fork 
        begin  
            drv_spi_master_packet_tx(base_addr, length, packet_type, id);
            control = {(transfer_length[31:2]+24/4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};
            //这里只是重新写，提供等待ack的时钟，0x9000是一个特殊的地址，不用管
            bypass_syncword_master = 1'b1; // 绕过同步字
            drv_spi_master_packet_tx(32'h9000, length, 16'h0000, id);
        end 
        begin 
            //等待ack包
            check_ack_packet(0, id, base_addr, 1'b0); // 0: OK status, 1: read command
        end
    join 
    bypass_syncword_master = 1'b0; // 绕过同步字
    sim_wr = 1'b0; //

/* ==========  tset 4  test spi signle reg read ==============*/    
    $display("********************* TEST Read REG with signle mode *********************");
    repeat (5) @(posedge sys_clk);
    transfer_length = 4; // 4 bytes signle register write
    length = transfer_length;
    id = 'h9def;
    packet_type = 16'h03; // 0x02 for write register command
    base_addr = 32'h2900; // Starting address for the transfer
    sim_wr = 1'b0;
    repeat (5) @(posedge sys_clk);
    //配置spi master
    control = {(transfer_length[31:2]+24/4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};
    fork
        begin
            drv_spi_master_packet_tx(base_addr, length, packet_type, id);
       
            bypass_syncword_master = 1'b1; // 绕过同步字
            sim_wr = 1'b1;//
            control = {(transfer_length[31:2]+24/4), 5'd31, 3'b010, 3'b000, 1'b1, 1'b1, 3'b001};
            drv_spi_master_packet_tx(32'h9000, length+4, 16'h0000, id);
            drv_spi_master_packet_tx(32'h9000, length+4, 16'h0000, id);

        end
        begin
            //等待ack包
            check_ack_packet(0, id, base_addr, 1'b1); // 0: OK status, 1: read command
        end
    join

    bypass_syncword_master = 1'b0; // 绕过同步字
    sim_wr = 1'b0;//


/* ==========  tset 5  test spi burst dma write with error ==============*/    
// $display("********************* TEST Write DDR with burst mode and error *********************");


    //cs_n一个包一个包的传输
    // control = {16'd1, 5'd31, 3'b111, 3'b000, cpol, cpha, 3'b001};

    repeat(100)@(posedge sys_clk);
    $display("All tests completed. ");
    $finish;


end


initial begin : err_detect
fork

forever @(posedge sys_clk)

    if (data_crc_error_master) begin 
        $display("[MASTER] Data CRC error detected at time %t", $time);
        $stop;
    end 
join

end


xlib_avalon_ram #(
.DW(DW),
.AW(AW),
.BL(BL),
.BI(1),
.SZ(SDR_SZ),
.ARDY_RATE(SDR_ARDY_RATE)
) sdr (
.clk    (sys_clk),
.rst_n  (sys_rst_n),
.rrdy   (sdr_rrdy),
.rval   (sdr_rval),
.rlen   (sdr_rlen),
.raddr  (sdr_raddr),
.rdata  (sdr_rdata),
.rdval  (sdr_rdval),
.wrdy   (sdr_wrdy),
.wval   (sdr_wval),
.wlen   (sdr_wlen),
.waddr  (sdr_waddr),
.wdata  (sdr_wdata));


xlib_avalon_bus #(
 .NW(BUSNW),
 .NR(BUSNR),
 .DW(DW),
 .AW(AW),
 .BL(BL),
 .R_FW(4)
 ) bus (
.clk      (sys_clk),
.rst_n    (sys_rst_n),
.s_wrdy   (bus_wrdy),  
.s_wval   (bus_wval),
.s_wlen   (bus_wlen),
.s_waddr  (bus_waddr),
.s_wdata  (bus_wdata),
.s_rrdy   (bus_rrdy),
.s_rval   (bus_rval),
.s_rlen   (bus_rlen),
.s_raddr  (bus_raddr),
.s_rdata  (bus_rdata),
.s_rdval  (bus_rdval),
.m_wrdy   (sdr_wrdy),
.m_wval   (sdr_wval),
.m_wlen   (sdr_wlen),
.m_waddr  (sdr_waddr),
.m_wdata  (sdr_wdata),
.m_rrdy   (sdr_rrdy),
.m_rval   (sdr_rval),
.m_rlen   (sdr_rlen),
.m_raddr  (sdr_raddr),
.m_rdata  (sdr_rdata),
.m_rdval  (sdr_rdval));





// spi_packet_tx 例化
spi_packet_tx u_spi_packet_tx_master (
    .clk           (sys_clk),
    .rst_n         (sys_rst_n),
    .data_in       (data_in_master),
    .data_in_valid (data_in_valid_master),
    .data_in_ready (data_in_ready_master),
    .tx_base_addr  (tx_base_addr_master),
    .tx_length     (tx_length_master),
    .tx_data       (tx_data_master),
    .tx_data_valid (tx_data_valid_master),
    .tx_data_ready (tx_data_ready_master),
    .tx_packet_type (tx_packet_type_master),
    .tx_id         (tx_id_master),
    .read_cmd_is   (read_cmd_is_master),
    .sim_wr        (sim_wr),
    .bypass_syncword (bypass_syncword_master), // 绕过同步字    
    .tx_data_end   (tx_data_end_master),
    .tx_enable     (tx_enable_master),
    .sending       (tx_sending_master),
    .ack_ready     (ack_ready_master),
    .error         ()
);

spi_master dut (
    .sys_clk(sys_clk), 
    .sys_rst_n(sys_rst_n),
    .miso(miso),
    .mosi(mosi), 
    .sclk(sclk), 
    .cs_n(cs_n),
    .control(control),
    .tx_data_valid(tx_data_valid_master ), 
    .tx_data_ready(tx_data_ready_master),
    .tx_data(tx_data_master),
    .rx_data_o(rx_data_master),
    .rx_data_valid_o(rx_data_valid_master)
);

spi_packet_rx u_spi_packet_rx_master (
    .clk           (sys_clk),
    .rst_n         (sys_rst_n),
    .rx_data       (rx_data_master),
    .rx_data_valid (rx_data_valid_master),
    .pkt_rx_enable (1'b1),
    .pkt_rx_addr    (pkt_rx_addr_master),
    .pkt_rx_length  (pkt_rx_length_master),
    .pkt_rx_data      (pkt_rx_data_master),
    .pkt_rx_data_valid(pkt_rx_data_valid_master),
    .pkt_rx_id        (pkt_rx_id_master),
    .pkt_rx_type      (pkt_rx_type_master),  
    .pkt_rx_start     (pkt_rx_start_master),
    .pkt_rx_end       (pkt_rx_end_master),
    .pkt_rx_data_last (pkt_rx_data_last_master),
    .header_crc_error (header_crc_error_master),
    .data_crc_error   (data_crc_error_master),
    .error            (pkt_rx_error_master)
);


// 例化 spi_slave_top
spi_slave_top #(
    .WIDTH_MAX(WIDTH_MAX),
    .HEIGHT_MAX(HEIGHT_MAX),
    .PW(PW),
    .AW(AW),
    .DW(DW),
    .DMA_BL(DMA_BL),
    .BL(BL),
    .APB_AW(APB_AW),
    .ID(ID)
) u_spi_slave_top (
    .clk(sys_clk),
    .rst_n(sys_rst_n),

    // read dma
    .src_bus_rrdy(src_bus_rrdy),
    .src_bus_rval(src_bus_rval),
    .src_bus_rlen(src_bus_rlen),
    .src_bus_raddr(src_bus_raddr),
    .src_bus_rdata(src_bus_rdata),
    .src_bus_rdval(src_bus_rdval),
    .dma_done_R(dma_done_R),

    // write dma
    .bus_wrdy(bus_wrdy),
    .bus_wval(bus_wval),
    .bus_wlen(bus_wlen),
    .bus_waddr(bus_waddr),
    .bus_wdata(bus_wdata),
    .dma_done_w(dma_done_w),

    // SPI interface
    .mosi(mosi),
    .miso(miso),
    .sclk(sclk),
    .cs_n(cs_n)
);




 task automatic drv_spi_master_packet_tx(
    input logic [31:0] base_addr,
    input logic [31:0] length,
    input logic [15:0] packet_type,
    input logic [15:0] id
);
    tx_base_addr_master = base_addr;
    tx_length_master = length;
    tx_packet_type_master = packet_type;
    tx_id_master = id;
    tx_enable_master = 1'b1;

    $display("statrt to drive spi master packet tx with base_addr: 0x%h, length: %0d, packet_type: 0x%h, id: 0x%h", 
             base_addr, length, packet_type, id);
    @(posedge sys_clk);
    while (!ack_ready_master && !data_in_ready_master) begin
        @(posedge sys_clk);
    end

    // 如果是读命令（packet_type为0x01或0x03），拉高data_in_valid_master一拍以锁定信息
    if (packet_type == 16'h0001 || packet_type == 16'h0003) begin
        data_in_valid_master = 1'b1;
        @(posedge sys_clk);
        data_in_valid_master = 1'b0;
        $display("drv_spi_master_packet_tx finish at time %t", $time);

        /*
            因为读命令后task立即返回了，没有写的数据，此时写sim_wr扩充spi时钟时会继续写tx。所以要加延迟
        */
        repeat(10)@(posedge sys_clk);

        return;
    end
    //handshake with ack_ready_master
    data_in_valid_master = 1'b1;
    @(posedge sys_clk);
    data_in_valid_master = 1'b0;

    // 根据length驱动data_in_master（4字节对齐，每个字节递增）
    for (int i = 0; i < length/4; i++) begin
        // 每个字节基于base_addr低8位递增
        logic [7:0] byte_val0 = base_addr[7:0] + i;
        logic [7:0] byte_val1 = base_addr[15:8] + i;
        logic [7:0] byte_val2 = base_addr[23:16] + i;
        logic [7:0] byte_val3 = base_addr[31:24] + i;

        data_in_master = {byte_val3, byte_val2, byte_val1, byte_val0}; // 32位数据，每字节相同
        data_in_valid_master = 1'b1;
        @(posedge sys_clk);
        while (!data_in_ready_master) begin
            @(posedge sys_clk);
        end
    end

    data_in_valid_master = 1'b0;

    $display("drv_spi_master_packet_tx finish at time %t", $time);
endtask





 task automatic check_ack_packet(
    input logic [15:0] expected_status,           // 预期状态：0 (OK), 1 (Header CRC Err), 2 (Data CRC Err)
    input logic [15:0] expected_rx_id_master,    // 预期的包ID
    input logic [31:0] origin_tx_addr_master,    // 发送时的原始地址
    input bit is_read_cmd                        // 1: 读命令, 0: 写命令
);
    logic header_crc_detected = 1'b0;

    @(posedge sys_clk);
    while (!pkt_rx_start_master && !header_crc_error_master) begin
        if (header_crc_error_master) header_crc_detected = 1'b1; 
        @(posedge sys_clk);
    end
    if (header_crc_error_master) header_crc_detected = 1'b1; 

    // 检查 ACK 包类型是否为 0x04
    if (pkt_rx_type_master !== 16'h0004) begin
        $error("ACK packet type error: expected 0x04, got 0x%h", pkt_rx_type_master);
        $stop;
    end else begin 
        $display("ACK packet type is correct: 0x%h", pkt_rx_type_master);

    end 

    // 检查 ID 是否匹配
    if (pkt_rx_id_master !== expected_rx_id_master) begin
        $error("ACK packet ID mismatch: expected 0x%h, got 0x%h", expected_rx_id_master, pkt_rx_id_master);
        $stop;
    end else begin 

        $display("ACK packet ID is correct: 0x%h", pkt_rx_id_master);
    end 

    // 检查 status（复用在 pkt_rx_addr_master）
    if (pkt_rx_addr_master[15:0] !== expected_status) begin
        $error("ACK status mismatch: expected 0x%h, got 0x%h", expected_status, pkt_rx_addr_master[15:0]);
        $stop; 
    end 
    else begin 
        $display("ACK status is correct: 0x%h", pkt_rx_addr_master[15:0]);
    end

    // 如果有 Header CRC 错误，只检查 status 后退出
    if (header_crc_detected) begin
        if (pkt_rx_addr_master[15:0] !== 16'h0001) begin
            $error("Header CRC error detected, but status is not 0x01: got 0x%h", pkt_rx_addr_master[15:0]);
            $stop;
        end
        return;
    end

    // 检查长度（写命令：length 应为 0；读命令：length 应非 0 且 4 字节对齐）
    if (!is_read_cmd) begin
        if (pkt_rx_length_master !== 0) begin
            $error("Write command ACK length error: expected 0, got 0x%h", pkt_rx_length_master);
            $stop;
        end
    end else begin
        if (pkt_rx_length_master == 0) begin
            $error("Read command ACK length error: expected non-zero, got 0");
            $stop;
        end
        if (pkt_rx_length_master % 4 !== 0) begin
            $error("Read command ACK length not 4-byte aligned: got 0x%h", pkt_rx_length_master);
            $stop;
        end
    end

    // 如果是读命令，验证返回的数据
    if (is_read_cmd && !header_crc_detected) begin
        int data_count = pkt_rx_length_master / 4;
        logic [31:0] expected_data;

        for (int i = 0; i < data_count; i++) begin
            logic [7:0] byte_val0;
            logic [7:0] byte_val1;
            logic [7:0] byte_val2;
            logic [7:0] byte_val3;

            while (!pkt_rx_data_valid_master && !pkt_rx_data_last_master) begin
                @(posedge sys_clk);
            end

            byte_val0 = origin_tx_addr_master[7:0] + i;
            byte_val1 = origin_tx_addr_master[15:8] + i;
            byte_val2 = origin_tx_addr_master[23:16] + i;
            byte_val3 = origin_tx_addr_master[31:24] + i;

            expected_data = {byte_val3, byte_val2, byte_val1, byte_val0}; // 32 位数据，每字节相同
            if (pkt_rx_data_master !== expected_data) begin
                $error("Read command data mismatch at index %0d: expected 0x%h, got 0x%h", 
                       i, expected_data, pkt_rx_data_master);
                $stop;
            end

            // 检查最后一个数据
            if (i == data_count - 1 && !pkt_rx_data_last_master) begin
                $error("Read command missing pkt_rx_data_last_master at last data");
            end
            @(posedge sys_clk);
        end

        if (data_crc_error_master) begin
            $error("Data CRC error detected in read command ACK");
            $stop;
        end

    end

endtask








endmodule