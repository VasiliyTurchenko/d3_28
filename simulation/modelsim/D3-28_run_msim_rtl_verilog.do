transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/tvv/fpga/d3_28 {/home/tvv/fpga/d3_28/D3_28.v}

