if ![file isdirectory ./work] { vlib ./work }
set sim_path ./
vmap work ./work


vlog owl_dma_write.sv 
vlog spi_dma_w.sv 
vlog spi_dma_wc_bst.sv 
vlog spi_dma_wc.sv 

vlog xlib_stream_p2w.v
vlog xlib_xyz_biu_w.v
vlog xlib_xyz_fifo.v
vlog xlib_fifos.v
vlog xlib_regslice.v
vlog xlib_rs_fifos.v



vlog tb.sv  +libext+.v +libext+.sv 
vsim work.tb  -voptargs=+acc -L altera_mf_ver
do wave.do
run -all
