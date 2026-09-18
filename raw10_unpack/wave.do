onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/clk
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/rst_n
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/i_rdy
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/i_val
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/i_data
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/o_val
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/o_rdy
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/o_data
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/byte_buf
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/byte_cnt
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/nxt_cnt
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/pop
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/push
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/o_val_r
add wave -noupdate -expand -label sim:/tb/dut/Group1 -group {Region: sim:/tb/dut} /tb/dut/i_rdy_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1010 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {872 ns} {1399 ns}
