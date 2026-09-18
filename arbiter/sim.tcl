if {![file isdirectory work]} { vlib work }
vmap work work

vlog -sv fixed_arbiter.sv rr_arbiter.sv wrr_arbiter.sv matrix_arbiter.sv tb_arbiter.sv
vsim -c work.tb_arbiter -voptargs=+acc
run -all
quit -f
