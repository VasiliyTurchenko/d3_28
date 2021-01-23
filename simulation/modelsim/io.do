onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /out_test/clk
add wave -noupdate /out_test/res_o
add wave -noupdate /out_test/res_o_short
add wave -noupdate /out_test/t3n
add wave -noupdate /out_test/t4n
add wave -noupdate /out_test/t5n
add wave -noupdate /out_test/t6n
add wave -noupdate -color {Medium Violet Red} /out_test/t7n
add wave -noupdate /out_test/t8n
add wave -noupdate /out_test/t9n
add wave -noupdate -color Blue /out_test/t10n
add wave -noupdate /out_test/t10
add wave -noupdate /out_test/t_romn
add wave -noupdate /out_test/A_stolb
add wave -noupdate -expand /out_test/US
add wave -noupdate -expand /out_test/USn
add wave -noupdate /out_test/DUT/D22A
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {259997330 ns} 0} {{Cursor 2} {250000090 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
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
WaveRestoreZoom {249990430 ns} {250006270 ns}
