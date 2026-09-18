onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb/data_ch0
add wave -noupdate -radix unsigned /tb/data_ch1
add wave -noupdate -radix unsigned /tb/data_ch2
add wave -noupdate /tb/bus_ch0
add wave -noupdate /tb/DW
add wave -noupdate /tb/bus_ch1
add wave -noupdate /tb/bus_ch2
add wave -noupdate -childformat {{{/tb/bytes_ch0[7]} -radix unsigned} {{/tb/bytes_ch0[6]} -radix unsigned} {{/tb/bytes_ch0[5]} -radix unsigned} {{/tb/bytes_ch0[4]} -radix unsigned} {{/tb/bytes_ch0[3]} -radix unsigned} {{/tb/bytes_ch0[2]} -radix unsigned} {{/tb/bytes_ch0[1]} -radix unsigned} {{/tb/bytes_ch0[0]} -radix unsigned}} -expand -subitemconfig {{/tb/bytes_ch0[7]} {-height 17 -radix unsigned} {/tb/bytes_ch0[6]} {-height 17 -radix unsigned} {/tb/bytes_ch0[5]} {-height 17 -radix unsigned} {/tb/bytes_ch0[4]} {-height 17 -radix unsigned} {/tb/bytes_ch0[3]} {-height 17 -radix unsigned} {/tb/bytes_ch0[2]} {-height 17 -radix unsigned} {/tb/bytes_ch0[1]} {-height 17 -radix unsigned} {/tb/bytes_ch0[0]} {-height 17 -radix unsigned}} /tb/bytes_ch0
add wave -noupdate -childformat {{{/tb/bytes_ch1[7]} -radix unsigned} {{/tb/bytes_ch1[6]} -radix unsigned} {{/tb/bytes_ch1[5]} -radix unsigned} {{/tb/bytes_ch1[4]} -radix unsigned} {{/tb/bytes_ch1[3]} -radix unsigned} {{/tb/bytes_ch1[2]} -radix unsigned} {{/tb/bytes_ch1[1]} -radix unsigned} {{/tb/bytes_ch1[0]} -radix unsigned}} -expand -subitemconfig {{/tb/bytes_ch1[7]} {-radix unsigned} {/tb/bytes_ch1[6]} {-radix unsigned} {/tb/bytes_ch1[5]} {-radix unsigned} {/tb/bytes_ch1[4]} {-radix unsigned} {/tb/bytes_ch1[3]} {-radix unsigned} {/tb/bytes_ch1[2]} {-radix unsigned} {/tb/bytes_ch1[1]} {-radix unsigned} {/tb/bytes_ch1[0]} {-radix unsigned}} /tb/bytes_ch1
add wave -noupdate /tb/bytes_ch2
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/clk
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/rst_n
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/cpb_r
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/cpb_w
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/cpb_a
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/cpb_d
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/cpb_q
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/irq
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wrdy
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wval
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wlen
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_waddr
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wdata
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/src_rdy
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/src_val
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/src_eof
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/src_d
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -radix unsigned /tb/src_cnt
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/data_ch0
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/data_ch1
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/data_ch2
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/clk
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/rst_n
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/cpb_r
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/cpb_w
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/cpb_a
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/cpb_d
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/cpb_q
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/irq
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/bus_wrdy
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/bus_wval
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/bus_wlen
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/bus_waddr
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/bus_wdata
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/src_rdy
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/src_val
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/src_eof
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/src_d
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/pio_adr_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/dst_adr
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/pack_data
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/dma_done
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/cr
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/cr_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/sr_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/pio_len_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/en
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/dst_bpp
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/rdy
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/p2w_rdy
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/p2w_val
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/p2w_eof
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/p2w_d
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/dst_done
add wave -noupdate -expand -label sim:/tb/dma_w_U/Group1 -group {Region: sim:/tb/dma_w_U} /tb/dma_w_U/dst_done_is
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/clk
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/rst_n
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/bus_rst_n
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/pio_adr_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/pio_len_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/pio_d
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/pio_adr
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/pio_len
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/pio_cst
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/dff_cnt
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/dff_ack
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/dff_eof
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/done
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_adr
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_len
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_sob
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_ch
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_eob
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_val
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_rdy
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/rsp_val
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/cnt_reg
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/cnt_reg_1
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_req
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_ack
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma} /tb/dma_w_U/multi_dma_w_dut/u_dma/biu_adr_bst
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/clk
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/rst_n
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/bus_rst_n
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/pio_adr_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/pio_len_we
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/pio_d
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/pio_adr
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/pio_len
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/pio_cst
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/dff_cnt
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/dff_ack
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/dff_eof
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/done
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/biu_adr
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/biu_len
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/biu_ch
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/biu_req
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/biu_ack
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/rsp_val
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/burst_request
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/adr_reg
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/run_reg
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/rsp_cnt
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/delay_cyc
add wave -noupdate -expand -label sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0/Group1 -group {Region: sim:/tb/dma_w_U/multi_dma_w_dut/u_dma/u0} /tb/dma_w_U/multi_dma_w_dut/u_dma/u0/dff_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1664231 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {2855832788 ps} {12785803538 ps}
