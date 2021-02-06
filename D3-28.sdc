## Generated SDC file "D3-28.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"

## DATE    "Mon Feb  1 23:24:01 2021"

##
## DEVICE  "EP4CE6E22C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {xtal50Mhz} -period 20.000 -waveform { 0.000 10.000 } [get_ports {ext_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {clk10MHz} -source [get_ports {ext_clk}] -divide_by 5 -master_clock {xtal50Mhz} [get_registers {MHZ_10~reg0}] 
create_generated_clock -name {tn1} -source [get_registers {MHZ_10~reg0}] -edges { 1 3 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[1]}] 
create_generated_clock -name {tn2} -source [get_registers {MHZ_10~reg0}] -edges { 3 5 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[2]}] 
create_generated_clock -name {tn3} -source [get_registers {MHZ_10~reg0}] -edges { 5 7 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[3]}] 
create_generated_clock -name {tn4} -source [get_registers {MHZ_10~reg0}] -edges { 7 9 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[4]}] 
create_generated_clock -name {tn5} -source [get_registers {MHZ_10~reg0}] -edges { 9 11 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[5]}] 
create_generated_clock -name {tn6} -source [get_registers {MHZ_10~reg0}] -edges { 11 13 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[6]}] 
create_generated_clock -name {tn7} -source [get_registers {MHZ_10~reg0}] -edges { 13 15 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[7]}] 
create_generated_clock -name {tn8} -source [get_registers {MHZ_10~reg0}] -edges { 15 17 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[8]}] 
create_generated_clock -name {tn9} -source [get_registers {MHZ_10~reg0}] -edges { 17 19 21 } -master_clock {clk10MHz} -invert [get_registers {machine:impl|clocks2:clocks2_impl|tn[9]}] 
create_generated_clock -name {tn10} -source [get_registers {MHZ_10~reg0}] -edges { 1 19 21 } -master_clock {clk10MHz} [get_registers {machine:impl|clocks2:clocks2_impl|tn[10]}] 
create_generated_clock -name {spi_st} -source [get_registers {MHZ_10~reg0}] -master_clock {clk10MHz} [get_registers {indikator2:indikator_impl|spi_out:spi_impl|xclockd:st|out[0]}] 
create_generated_clock -name {sc} -source [get_registers {MHZ_10~reg0}] -divide_by 4 -master_clock {clk10MHz} [get_registers {sc}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn10}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn10}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn9}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn9}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn8}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn8}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn7}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn7}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn6}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn6}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn5}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn5}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn4}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn4}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn3}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn3}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn2}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn2}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tn1}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tn1}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -rise_to [get_clocks {xtal50Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk10MHz}] -fall_to [get_clocks {xtal50Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn10}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn9}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn8}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn7}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn6}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn5}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn4}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn3}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn2}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {tn1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {clk10MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -rise_to [get_clocks {xtal50Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk10MHz}] -fall_to [get_clocks {xtal50Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {xtal50Mhz}] -rise_to [get_clocks {clk10MHz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {xtal50Mhz}] -fall_to [get_clocks {clk10MHz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {xtal50Mhz}] -rise_to [get_clocks {xtal50Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {xtal50Mhz}] -fall_to [get_clocks {xtal50Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {xtal50Mhz}] -rise_to [get_clocks {clk10MHz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {xtal50Mhz}] -fall_to [get_clocks {clk10MHz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {xtal50Mhz}] -rise_to [get_clocks {xtal50Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {xtal50Mhz}] -fall_to [get_clocks {xtal50Mhz}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

