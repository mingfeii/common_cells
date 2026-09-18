onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_memory_tester/ddr_slave/aclk
add wave -noupdate /tb_memory_tester/ddr_slave/aresetn
add wave -noupdate /tb_memory_tester/ddr_slave/wr_busy
add wave -noupdate /tb_memory_tester/ddr_slave/wr_data
add wave -noupdate /tb_memory_tester/ddr_slave/wr_datamask
add wave -noupdate /tb_memory_tester/ddr_slave/wr_addr
add wave -noupdate /tb_memory_tester/ddr_slave/wr_en
add wave -noupdate /tb_memory_tester/ddr_slave/wr_addr_en
add wave -noupdate /tb_memory_tester/ddr_slave/wr_ack
add wave -noupdate /tb_memory_tester/ddr_slave/rd_busy
add wave -noupdate /tb_memory_tester/ddr_slave/rd_addr
add wave -noupdate /tb_memory_tester/ddr_slave/rd_addr_en
add wave -noupdate /tb_memory_tester/ddr_slave/rd_en
add wave -noupdate /tb_memory_tester/ddr_slave/rd_data
add wave -noupdate /tb_memory_tester/ddr_slave/rd_valid
add wave -noupdate /tb_memory_tester/ddr_slave/rd_ack
add wave -noupdate /tb_memory_tester/ddr_slave/awid
add wave -noupdate /tb_memory_tester/ddr_slave/awaddr
add wave -noupdate /tb_memory_tester/ddr_slave/awlen
add wave -noupdate /tb_memory_tester/ddr_slave/awsize
add wave -noupdate /tb_memory_tester/ddr_slave/awburst
add wave -noupdate /tb_memory_tester/ddr_slave/awlock
add wave -noupdate /tb_memory_tester/ddr_slave/awcache
add wave -noupdate /tb_memory_tester/ddr_slave/awprot
add wave -noupdate /tb_memory_tester/ddr_slave/awqos
add wave -noupdate /tb_memory_tester/ddr_slave/awregion
add wave -noupdate /tb_memory_tester/ddr_slave/awuser
add wave -noupdate /tb_memory_tester/ddr_slave/awvalid
add wave -noupdate /tb_memory_tester/ddr_slave/awready
add wave -noupdate /tb_memory_tester/ddr_slave/wdata
add wave -noupdate /tb_memory_tester/ddr_slave/wstrb
add wave -noupdate /tb_memory_tester/ddr_slave/wlast
add wave -noupdate /tb_memory_tester/ddr_slave/wuser
add wave -noupdate /tb_memory_tester/ddr_slave/wvalid
add wave -noupdate /tb_memory_tester/ddr_slave/wready
add wave -noupdate /tb_memory_tester/ddr_slave/bid
add wave -noupdate /tb_memory_tester/ddr_slave/bresp
add wave -noupdate /tb_memory_tester/ddr_slave/buser
add wave -noupdate /tb_memory_tester/ddr_slave/bvalid
add wave -noupdate /tb_memory_tester/ddr_slave/bready
add wave -noupdate /tb_memory_tester/ddr_slave/arid
add wave -noupdate /tb_memory_tester/ddr_slave/araddr
add wave -noupdate /tb_memory_tester/ddr_slave/arlen
add wave -noupdate /tb_memory_tester/ddr_slave/arsize
add wave -noupdate /tb_memory_tester/ddr_slave/arburst
add wave -noupdate /tb_memory_tester/ddr_slave/arlock
add wave -noupdate /tb_memory_tester/ddr_slave/arcache
add wave -noupdate /tb_memory_tester/ddr_slave/arprot
add wave -noupdate /tb_memory_tester/ddr_slave/arqos
add wave -noupdate /tb_memory_tester/ddr_slave/arregion
add wave -noupdate /tb_memory_tester/ddr_slave/aruser
add wave -noupdate /tb_memory_tester/ddr_slave/arvalid
add wave -noupdate /tb_memory_tester/ddr_slave/arready
add wave -noupdate /tb_memory_tester/ddr_slave/rid
add wave -noupdate /tb_memory_tester/ddr_slave/rdata
add wave -noupdate /tb_memory_tester/ddr_slave/rresp
add wave -noupdate /tb_memory_tester/ddr_slave/rlast
add wave -noupdate /tb_memory_tester/ddr_slave/ruser
add wave -noupdate /tb_memory_tester/ddr_slave/rvalid
add wave -noupdate /tb_memory_tester/ddr_slave/rready
add wave -noupdate /tb_memory_tester/ddr_slave/wr_en_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/wr_addr_en_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/decode_wsize
add wave -noupdate /tb_memory_tester/ddr_slave/decode_rsize
add wave -noupdate /tb_memory_tester/ddr_slave/rd_addr_en_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/rd_en_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/rid_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/rlast_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/rdata_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/rvalid_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/awff_write
add wave -noupdate /tb_memory_tester/ddr_slave/awff_wdata
add wave -noupdate /tb_memory_tester/ddr_slave/awff_read
add wave -noupdate /tb_memory_tester/ddr_slave/awff_rdata
add wave -noupdate /tb_memory_tester/ddr_slave/awff_full
add wave -noupdate /tb_memory_tester/ddr_slave/awff_empty
add wave -noupdate /tb_memory_tester/ddr_slave/i_awadrs
add wave -noupdate /tb_memory_tester/ddr_slave/i_awlen
add wave -noupdate /tb_memory_tester/ddr_slave/i_awsize
add wave -noupdate /tb_memory_tester/ddr_slave/i_aw_incr
add wave -noupdate /tb_memory_tester/ddr_slave/i_awid
add wave -noupdate /tb_memory_tester/ddr_slave/i_awburst
add wave -noupdate /tb_memory_tester/ddr_slave/wff_write
add wave -noupdate /tb_memory_tester/ddr_slave/wff_wdata
add wave -noupdate /tb_memory_tester/ddr_slave/wff_read
add wave -noupdate /tb_memory_tester/ddr_slave/wff_rdata
add wave -noupdate /tb_memory_tester/ddr_slave/wff_full
add wave -noupdate /tb_memory_tester/ddr_slave/wff_empty
add wave -noupdate /tb_memory_tester/ddr_slave/i_wdata
add wave -noupdate /tb_memory_tester/ddr_slave/i_wstrb
add wave -noupdate /tb_memory_tester/ddr_slave/i_wlast
add wave -noupdate /tb_memory_tester/ddr_slave/bff_write
add wave -noupdate /tb_memory_tester/ddr_slave/bff_wdata
add wave -noupdate /tb_memory_tester/ddr_slave/bff_read
add wave -noupdate /tb_memory_tester/ddr_slave/bff_rdata
add wave -noupdate /tb_memory_tester/ddr_slave/bff_full
add wave -noupdate /tb_memory_tester/ddr_slave/bff_empty
add wave -noupdate /tb_memory_tester/ddr_slave/write_adrs
add wave -noupdate /tb_memory_tester/ddr_slave/nxt_write_adrs
add wave -noupdate /tb_memory_tester/ddr_slave/write_count
add wave -noupdate /tb_memory_tester/ddr_slave/nxt_write_count
add wave -noupdate /tb_memory_tester/ddr_slave/write_state
add wave -noupdate /tb_memory_tester/ddr_slave/nxt_write_state
add wave -noupdate /tb_memory_tester/ddr_slave/awsize_reg
add wave -noupdate /tb_memory_tester/ddr_slave/awsize_reg_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/arff_write
add wave -noupdate /tb_memory_tester/ddr_slave/arff_wdata
add wave -noupdate /tb_memory_tester/ddr_slave/arff_read
add wave -noupdate /tb_memory_tester/ddr_slave/arff_rdata
add wave -noupdate /tb_memory_tester/ddr_slave/arff_full
add wave -noupdate /tb_memory_tester/ddr_slave/arff_empty
add wave -noupdate /tb_memory_tester/ddr_slave/i_aradrs
add wave -noupdate /tb_memory_tester/ddr_slave/i_arlen
add wave -noupdate /tb_memory_tester/ddr_slave/i_arsize
add wave -noupdate /tb_memory_tester/ddr_slave/i_ar_incr
add wave -noupdate /tb_memory_tester/ddr_slave/i_arid
add wave -noupdate /tb_memory_tester/ddr_slave/i_arburst
add wave -noupdate /tb_memory_tester/ddr_slave/read_adrs
add wave -noupdate /tb_memory_tester/ddr_slave/nxt_read_adrs
add wave -noupdate /tb_memory_tester/ddr_slave/read_count
add wave -noupdate /tb_memory_tester/ddr_slave/nxt_read_count
add wave -noupdate /tb_memory_tester/ddr_slave/read_data_count
add wave -noupdate /tb_memory_tester/ddr_slave/nxt_read_data_count
add wave -noupdate /tb_memory_tester/ddr_slave/addr_rd_lock
add wave -noupdate /tb_memory_tester/ddr_slave/addr_rd_lock_nxt
add wave -noupdate /tb_memory_tester/ddr_slave/read_state
add wave -noupdate /tb_memory_tester/ddr_slave/nxt_read_state
add wave -noupdate /tb_memory_tester/ddr_slave/arsize_reg
add wave -noupdate /tb_memory_tester/ddr_slave/arsize_reg_nxt
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/axi_clk
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rstn
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/start
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/pass
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/o_total_len
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/o_time_counter
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/test_done
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awaddr
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awlen
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awsize
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awburst
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awlock
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awcache
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awprot
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awqos
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awregion
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awuser
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awvalid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/awready
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/wdata
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/wstrb
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/wlast
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/wuser
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/wvalid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/wready
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/bid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/bresp
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/buser
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/bvalid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/bready
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/araddr
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arlen
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arsize
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arburst
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arlock
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arcache
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arprot
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arqos
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arregion
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/aruser
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arvalid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/arready
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rdata
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rresp
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rlast
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/ruser
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rvalid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rready
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/alen
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/aaddr
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/aready
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/avalid
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/asize
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/aburst
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/alock
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/atype
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/states
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/nstates
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/fail
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/done
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/bvalid_done
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/start_sync
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/write_cnt
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/read_cnt
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rdata_store
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/wburst_done
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/rburst_done
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/write_done
add wave -noupdate -expand -label sim:/tb_memory_tester/tester/axi_ctrl_U/Group1 -group {Region: sim:/tb_memory_tester/tester/axi_ctrl_U} /tb_memory_tester/tester/axi_ctrl_U/read_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {220830842 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 242
configure wave -valuecolwidth 268
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {220789680 ps} {220968154 ps}
