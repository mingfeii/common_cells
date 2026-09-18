onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/clk
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/rst_n
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_rst_n
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/pio_adr_we
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/pio_len_we
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/nch
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/pio_d
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/pio_adr
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/pio_len
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/dma_done
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/dma_err
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -expand /tb/dma_rdy
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -expand /tb/dma_val
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -expand /tb/dma_eof
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -expand /tb/dma_d
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_rrdy
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_rval
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_rlen
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_raddr
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_rdata
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_rdval
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wrdy
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wval
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wlen
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_waddr
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/bus_wdata
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/i
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/ret
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/fd0
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/data
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/dma_val_o
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/CH
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/dma_rdy_o
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -expand /tb/dma_eof_o
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -expand /tb/dma_d_o
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/dst_done_is
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/irq
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} -expand /tb/dst_addr
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/mem_addr
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/clk
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/rst_n
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/bus_rst_n
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/pio_adr_we
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/pio_len_we
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/nch
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/pio_d
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/pio_adr
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/pio_len
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/dma_done
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/dma_err
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/dma_rdy
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/dma_val
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/dma_eof
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/dma_d
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/bus_rrdy
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/bus_rval
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/bus_rlen
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/bus_raddr
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/bus_rdata
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/Group1 -group {Region: sim:/tb/multi_dma_r_inst} /tb/multi_dma_r_inst/bus_rdval
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/clk
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/rst_n
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/bus_rst_n
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/done
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/err
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/biu_adr
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/biu_len
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/biu_req
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/biu_ack
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/nch
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/pio_adr_we
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/pio_len_we
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/pio_d
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/rsp_val
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/bus_rdata
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/pio_adr
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/pio_len
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/dma_rdy
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/dma_val
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/dma_eof
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/dma_d
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/adr_reg
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/len_reg
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -childformat {{{/tb/multi_dma_r_inst/u_dma/rsp_cnt[2]} -radix unsigned} {{/tb/multi_dma_r_inst/u_dma/rsp_cnt[1]} -radix unsigned} {{/tb/multi_dma_r_inst/u_dma/rsp_cnt[0]} -radix unsigned}} -expand -subitemconfig {{/tb/multi_dma_r_inst/u_dma/rsp_cnt[2]} {-height 15 -radix unsigned} {/tb/multi_dma_r_inst/u_dma/rsp_cnt[1]} {-height 15 -radix unsigned} {/tb/multi_dma_r_inst/u_dma/rsp_cnt[0]} {-height 15 -radix unsigned}} /tb/multi_dma_r_inst/u_dma/rsp_cnt
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/delay_cyc
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/biu_ack
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/burst_request
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -childformat {{{/tb/multi_dma_r_inst/u_dma/dat_cnt[2]} -radix unsigned} {{/tb/multi_dma_r_inst/u_dma/dat_cnt[1]} -radix unsigned} {{/tb/multi_dma_r_inst/u_dma/dat_cnt[0]} -radix unsigned}} -expand -subitemconfig {{/tb/multi_dma_r_inst/u_dma/dat_cnt[2]} {-color Pink -height 15 -radix unsigned} {/tb/multi_dma_r_inst/u_dma/dat_cnt[1]} {-color Pink -height 15 -radix unsigned} {/tb/multi_dma_r_inst/u_dma/dat_cnt[0]} {-color Pink -height 15 -radix unsigned}} /tb/multi_dma_r_inst/u_dma/dat_cnt
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -radix unsigned -childformat {{{/tb/multi_dma_r_inst/u_dma/dff_cnt[2]} -radix unsigned} {{/tb/multi_dma_r_inst/u_dma/dff_cnt[1]} -radix unsigned} {{/tb/multi_dma_r_inst/u_dma/dff_cnt[0]} -radix unsigned}} -expand -subitemconfig {{/tb/multi_dma_r_inst/u_dma/dff_cnt[2]} {-height 15 -radix unsigned} {/tb/multi_dma_r_inst/u_dma/dff_cnt[1]} {-height 15 -radix unsigned} {/tb/multi_dma_r_inst/u_dma/dff_cnt[0]} {-height 15 -radix unsigned}} /tb/multi_dma_r_inst/u_dma/dff_cnt
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -color Gold /tb/multi_dma_r_inst/u_dma/biu_ch
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/len_reg_1
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/run_reg
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} /tb/multi_dma_r_inst/u_dma/rd_cnt
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -color Coral /tb/multi_dma_r_inst/u_dma/rd_cnt_sel
add wave -noupdate -expand -label sim:/tb/multi_dma_r_inst/u_dma/Group1 -group {Region: sim:/tb/multi_dma_r_inst/u_dma} -expand /tb/multi_dma_r_inst/u_dma/dff_eof
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/clk}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/rst_n}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/wrdy}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/wval}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/wd}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/rrdy}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/rval}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/rd}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/cnt}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/full}
add wave -noupdate -expand -group 2 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/empty}
add wave -noupdate -expand -group 2 -radix unsigned {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[2]/u_dff/usedw}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/clk}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/rst_n}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/wrdy}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/wval}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/wd}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/rrdy}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/rval}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/rd}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/cnt}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/full}
add wave -noupdate -expand -group 1 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/empty}
add wave -noupdate -expand -group 1 -radix unsigned {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[1]/u_dff/usedw}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/clk}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/rst_n}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/wrdy}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/wval}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/wd}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/rrdy}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/rval}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/rd}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/cnt}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/full}
add wave -noupdate -expand -group 0 {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/empty}
add wave -noupdate -expand -group 0 -radix unsigned {/tb/multi_dma_r_inst/u_dma/DMA_RFFIN[0]/u_dff/usedw}
add wave -noupdate /tb/dst_done_is
add wave -noupdate /tb/irq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3633255741 ps} 0}
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
WaveRestoreZoom {3565975760 ps} {3833446664 ps}
