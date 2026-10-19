# Run from sim/build/<case>/ after run.py --quick has compiled the library.
# Example: vsim -gui -voptargs=+acc -lib ../work tb_async_fifo -gSTYLE=1 -do ../../waves.do
add wave sim:/tb_async_fifo/arst_n
add wave sim:/tb_async_fifo/wrst_n sim:/tb_async_fifo/rrst_n
add wave sim:/tb_async_fifo/wclk sim:/tb_async_fifo/rclk
add wave sim:/tb_async_fifo/winc sim:/tb_async_fifo/wfull
add wave -radix hexadecimal sim:/tb_async_fifo/wdata
add wave sim:/tb_async_fifo/rinc sim:/tb_async_fifo/rempty
add wave -radix hexadecimal sim:/tb_async_fifo/rdata
add wave -radix unsigned sim:/tb_async_fifo/occupancy
add wave -radix binary sim:/tb_async_fifo/debug_wgray sim:/tb_async_fifo/debug_rgray
add wave sim:/tb_async_fifo/debug_direction
add wave sim:/tb_async_fifo/debug_aempty_n sim:/tb_async_fifo/debug_afull_n
run -all
wave zoom full
