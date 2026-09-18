add wave -divider Clock_Reset
add wave sim:/tb_arbiter/clk
add wave sim:/tb_arbiter/rst_n
add wave -divider Fixed_Priority
add wave sim:/tb_arbiter/fixed_req
add wave sim:/tb_arbiter/fixed_grant
add wave -divider Round_Robin
add wave sim:/tb_arbiter/rr_req
add wave sim:/tb_arbiter/rr_grant
add wave sim:/tb_arbiter/u_rr/mask
add wave -divider Weighted_Round_Robin
add wave sim:/tb_arbiter/wrr_req
add wave sim:/tb_arbiter/wrr_grant
add wave sim:/tb_arbiter/wrr_busy
add wave sim:/tb_arbiter/u_wrr/mask
add wave sim:/tb_arbiter/u_wrr/credit
add wave -divider Matrix
add wave sim:/tb_arbiter/matrix_req
add wave sim:/tb_arbiter/matrix_grant
add wave sim:/tb_arbiter/u_matrix/matrix
