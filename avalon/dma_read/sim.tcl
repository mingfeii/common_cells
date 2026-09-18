if ![file isdirectory ./work] { vlib ./work }
set sim_path ./
vmap work ./work

vlog xlib_avalon_bus_r.v
vlog xlib_avalon_bus.v
vlog xlib_avalon_bus_w.v
vlog xlib_avalon_ram.sv
vlog xlib_dma_rc_bst.v
vlog xlib_dma_rc.v
vlog xlib_stream_p2w.v
vlog xlib_stream_w2p.v
vlog xlib_xyz_biu_w.v
vlog xlib_xyz_dma_r.v
vlog xlib_xyz_fifo.v
vlog xlib_fifos.v
vlog xlib_regslice.v
vlog xlib_rs_fifos.v

vlog dma_read.sv


vlog tb.sv  +libext+.v +libext+.sv 
vsim work.tb  -voptargs=+acc -L altera_mf_ver
do wave.do
run -all
