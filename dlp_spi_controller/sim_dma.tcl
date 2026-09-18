if ![file isdirectory ./work] { vlib ./work }
vmap work ./work
vlog spi_master.sv
vlog spi_slave.sv
vlog ./lib/xlib_xyz_fifo.v
vlog xc_sync_fifo_rec.v
vlog crc.v
vlog packet_generate_tb.sv
vlog spi_packet_rx.sv
vlog spi_packet_tx.sv

vlog ./lib/xlib_avalon_bus_r.v
vlog ./lib/xlib_avalon_bus.v
vlog ./lib/xlib_avalon_bus_w.v
vlog ./lib/xlib_avalon_ram.sv
vlog ./lib/xlib_dma_rc_bst.v
vlog ./lib/xlib_dma_rc.v
vlog ./lib/xlib_stream_p2w.v
vlog ./lib/xlib_stream_w2p.v
vlog ./lib/xlib_xyz_biu_w.v
vlog ./lib/xlib_xyz_dma_r.v
vlog ./lib/xlib_xyz_fifoa.v
vlog ./lib/xlib_fifos.v
vlog ./lib/xlib_fifos.v

vlog ./lib/xlib_regslice.v
vlog ./lib/xlib_rs_fifos.v

vlog spi_dma_r.v 
vlog spi_dma_rc_bst.v
vlog spi_dma_w.sv 
vlog spi_dma_wc_bst.sv
vlog spi_dma_wc.sv
vlog dma_read.sv
vlog spi_slave_top.sv
vlog bus_read_control.sv
vlog bus_write_control.sv


vlog tb_dma.sv +libext+.v +libext+.sv
 vsim work.tb  -L altera_mf_ver -voptargs=+acc
 do wave.do
 run -all
