if ![file isdirectory ./work] { vlib ./work }


vmap work ./work
vlog  ./\*.*v
vlog  ./\*.*sv

vlog tb.sv  +libext+.v +libext+.sv 

vsim work.tb -L altera_mf_ver -voptargs=+acc
do wave.do
run -all

