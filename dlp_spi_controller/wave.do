onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/clk
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/rst_n
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/pkt_rx_clear
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/data_in
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/data_in_valid
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/data_in_ready
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/ack_ready
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/read_cmd_is
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/sim_wr
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/bypass_syncword
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_base_addr
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_length
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_id
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_packet_type
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_enable
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_data
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_data_valid
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_data_ready
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_data_end
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/sending
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/error
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/state
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/next_state
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/data_cnt
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/word_cnt
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_data_r
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_data_valid_r
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/timeout_cnt
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/timeout
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/length_error
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/header_crc
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/data_crc
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_base_addr_reg
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_length_reg
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_id_reg
add wave -noupdate -expand -label sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave/Group1 -group {Region: sim:/tb/u_spi_slave_top/u_spi_packet_tx_slave} /tb/u_spi_slave_top/u_spi_packet_tx_slave/tx_packet_type_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {1917242292 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 377
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
WaveRestoreZoom {2738737853 ps} {2746683684 ps}
