onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/clk
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/rst_n
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/cpb_r
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/cpb_w
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/cpb_a
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/cpb_d
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/cpb_q
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/irq
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_bus_rrdy
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_bus_rval
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_bus_rlen
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_bus_raddr
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_bus_rdata
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_bus_rdval
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dst_str_rdy
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dst_str_val
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dst_str_d
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/cr_we
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/sr_we
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_ar_we
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_lr_we
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/src_adr
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/cr
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_length
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/en
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_rdy
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_val
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_eof
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_done
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_d
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_rdy_1
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_val_1
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_eof_1
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dma_d_1
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dst_adr_we
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dst_done
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/dst_done_is
add wave -noupdate -expand -label sim:/tb/dma_r_U/Group1 -group {Region: sim:/tb/dma_r_U} /tb/dma_r_U/bpp
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/clk
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rst_n
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/s_rrdy
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/s_rval
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/s_rlen
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/s_raddr
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/s_rdata
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/s_rdval
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/m_rrdy
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/m_rval
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/m_rlen
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/m_raddr
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/m_rdata
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/m_rdval
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/i
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rff_ne
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rff_nf
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/en
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/ee
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rid
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/x_rval
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rdid
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rdlen
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rdcnt
add wave -noupdate -expand -label sim:/tb/bus/bus_r/Group1 -group {Region: sim:/tb/bus/bus_r} /tb/bus/bus_r/rdlast
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1785000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 207
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
WaveRestoreZoom {946965 ps} {7430031 ps}
