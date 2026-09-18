if ![file isdirectory ./work] { vlib ./work }

vmap work ./work

vlog ready_skid.v

vlog ready_skid_tb.sv  +libext+.v +libext+.sv

vsim work.ready_skid_tb -L altera_mf_ver -voptargs=+acc
do wave.do
run -all
