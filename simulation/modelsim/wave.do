onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand /ic74155_test/out
add wave -noupdate -radix unsigned -childformat {{{/ic74155_test/inp[2]} -radix unsigned} {{/ic74155_test/inp[1]} -radix unsigned} {{/ic74155_test/inp[0]} -radix unsigned}} -expand -subitemconfig {{/ic74155_test/inp[2]} {-height 17 -radix unsigned} {/ic74155_test/inp[1]} {-height 17 -radix unsigned} {/ic74155_test/inp[0]} {-height 17 -radix unsigned}} /ic74155_test/inp
add wave -noupdate /ic74155_test/en
add wave -noupdate /ic74155_test/enable_on
add wave -noupdate /ic74155_test/enable_off
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {250 ns} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ns} {220 ns}
