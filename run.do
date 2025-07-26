vlib work
vlog spi.v
vlog tb_spi.v
vsim tb
add wave -position insertpoint sim:/tb/dut/*
run -all

