
quit -sim 
vlib work 
vlog qs_1_design.v qs_1_tb.v 
vsim -voptargs=+acc ALSU_tb 
add wave * 
run -all 
