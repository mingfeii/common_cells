if ![file isdirectory ./work] { vlib ./work }

set sim_path ./
vmap work ./work

vlog  $sim_path/\*.*v
vlog  $sim_path/\*.*sv

vlog ../axi_uart_read.sv
vlog ../efx_sc_fifo.sv
vlog ../usart_rx.v 
vlog ../usart_tx.v 

vlog  ../../../../fpga/Encrypt/Ddr_Controller_Axi.v
vlog  ../../../../fpga/Encrypt/Ddr3_Memory_Controler.v




vlog tb.sv  +libext+.v +libext+.sv
vsim work.tb  -voptargs=+acc
do wave.do
run -all



