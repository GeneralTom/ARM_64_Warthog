transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/twsch/OneDrive/Desktop/ARM_64_Warthog {C:/Users/twsch/OneDrive/Desktop/ARM_64_Warthog/RAM_64bit.v}

vlog -vlog01compat -work work +incdir+C:/Users/twsch/OneDrive/Desktop/ARM_64_Warthog {C:/Users/twsch/OneDrive/Desktop/ARM_64_Warthog/RAM_64bit_testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  RAM_64bit_testbench

add wave *
view structure
view signals
run -all
