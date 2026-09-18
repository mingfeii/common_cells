`define  RTL_SIM
`define  AXI_FULL_DEPLEX 


`define  RAM_IDLE 9'd0
`define  RAM_ACT 9'd3
`define  RAM_WR 9'd8
`define  RAM_RD 9'd10
`define  RAM_RD2PREA 9'd12
`define  RAM_WR2PREA 9'd18
`define  RAM_WR2RD 9'd27
`define  RAM_RD2WR 9'd34
`define  RAM_PREA2REF 9'd37
`define  RAM_REF 9'd46
`define  RAM_NOP 9'd118
`define  RAM_WPAW 9'd120
`define  RAM_WPAR 9'd135
`define  RAM_RPAW 9'd150
`define  RAM_RPAR 9'd159
`define  RAM_SRE 9'd168
`define  RAM_SR 9'd170
`define  RAM_SRX 9'd172
`define  RAM_INIT 9'd244
`define  RAM_WAITING 9'd258
`define  BRAM_LEN 262
`define  BRAM_I_WIDTH 9
`define  BRAM_D_WIDTH 72
`define  MICRO_SEC 8
`define  REF_INTERVAL 24960
`define  DRAM_WIDTH 16
`define  GROUP_WIDTH 8
`define  DRAM_GROUP 2
`define  DM_BIT_WIDTH 16
`define  ROW 16
`define  COL 10
`define  BANK 3
`define  BA_BIT_WIDTH 8
`define  WFIFO_WIDTH 128
`define  BL 8
`define  usReset 200
`define  usCKE 500
`define  tZQinit 512
`define  ODTH8 6
`define  tRL 5
`define  tWL 5
`define  ARBITER_INIT 1
`define  ARBITER_COUNT 64
`define  RAM_FILE    "ddr3_controller.bin"


`timescale 100ps / 10ps
