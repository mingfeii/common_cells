onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/clk
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/rst_n
add wave -noupdate -expand -label sim:/tb/Group1 -group {Region: sim:/tb} /tb/q
add wave -noupdate -expand -label sim:/tb/lfsr_u/Group1 -group {Region: sim:/tb/lfsr_u} /tb/lfsr_u/clk
add wave -noupdate -expand -label sim:/tb/lfsr_u/Group1 -group {Region: sim:/tb/lfsr_u} /tb/lfsr_u/rst_n
add wave -noupdate -expand -label sim:/tb/lfsr_u/Group1 -group {Region: sim:/tb/lfsr_u} /tb/lfsr_u/q
add wave -noupdate -expand -label sim:/tb/lfsr_u/Group1 -group {Region: sim:/tb/lfsr_u} /tb/lfsr_u/lfsr_feedback
add wave -noupdate -expand -label sim:/tb/lfsr_u/Group1 -group {Region: sim:/tb/lfsr_u} /tb/lfsr_u/r_reg
add wave -noupdate -expand -label sim:/tb/lfsr_u/Group1 -group {Region: sim:/tb/lfsr_u} /tb/lfsr_u/r_reg_nxt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {92000015 ns} 0}
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
WaveRestoreZoom {91998228 ns} {92007957 ns}
