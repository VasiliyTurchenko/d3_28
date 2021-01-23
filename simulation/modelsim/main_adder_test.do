onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /main_adder_test/alpha
add wave -noupdate -radix unsigned /main_adder_test/beta
add wave -noupdate /main_adder_test/En
add wave -noupdate /main_adder_test/alu_clk
add wave -noupdate -radix unsigned /main_adder_test/alu_out_bus
add wave -noupdate /main_adder_test/P2
add wave -noupdate /main_adder_test/P3
add wave -noupdate /main_adder_test/P4
add wave -noupdate /main_adder_test/simple_add_bin
add wave -noupdate /main_adder_test/simple_add_dec
add wave -noupdate -expand /main_adder_test/name/_4wn
add wave -noupdate /main_adder_test/a_add_b_add_1_bin
add wave -noupdate /main_adder_test/a_add_b_add_1_dec
add wave -noupdate /main_adder_test/__4w2_bin
add wave -noupdate /main_adder_test/__4w2_dec
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 177
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {28520 ns} {35800 ns}
