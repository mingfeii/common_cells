if ![file isdirectory ./work] { vlib ./work }

set sim_path ./

vmap work ./work
vlog  $sim_path\*.*v
vlog  $sim_path\*.*sv

vlog tb.sv  +libext+.v +libext+.sv 

vsim work.tb  -voptargs=+acc
do wave.do
run -all


