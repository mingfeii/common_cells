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
vlog tb.sv +libext+.v +libext+.sv
 vsim work.tb  -L altera_mf_ver -voptargs=+acc
 do wave.do
 run -all
