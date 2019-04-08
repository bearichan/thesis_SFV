set_attribute hdl_search_path {./} 
set_attribute lib_search_path {./}
set_attribute library [list gscl45nm.lib]

set current_design DUT 
set myFiles [list DUT.v]

read_hdl ${myFiles}
elaborate ${current_design}

read_sdc ./constraints.sdc

check_design -unresolved
report timing -lint

# Synthesize the design to the target library
synthesize -to_mapped

write_hdl -mapped >  ${current_design}_netlist.v

puts "***********************"
puts "all_outputs"
puts "***********************"
puts [all_outputs]
set all_out [all_outputs]

puts "***********************"
puts "all_registers"
puts "***********************"
puts [all_registers]
set all_reg [all_registers]

puts "***********************"
puts "all_inputs"
puts "***********************"
puts [all_inputs]
set all_in [all_inputs] 


set fp [ open "test2.rpt" a+ ]


#$all_in

#$all_out

for {set a 0} {$a < [llength $all_reg]} {incr a} {
    set tmp_reg [lindex $all_reg $a]
    regsub -all {\/designs\/DUT\/instances\_seq\/} $tmp_reg "" mytmp
    puts $fp $mytmp

    regsub -all {\[[0-9]*\]} $mytmp "" init_key
    set search_key "*"
    append search_key $init_key
    append search_key "\*Q*"
    append mytmp "\/D"

    set fanin [all_fanin -to $mytmp -startpoints_only]
    set fanin_verbose [all_fanin -to $mytmp]

    regsub -all {\/D} $mytmp {\/CLK} mytmp2
    set fanout [all_fanout -from $mytmp2 -endpoints_only]
    set fanout_verbose [all_fanout -from $mytmp2]

    set in_key "*ports\_in*"
    puts $fp [llength [lsearch -all -inline $fanin $in_key]]

    set out_key "*ports\_out*"
    puts $fp [llength [lsearch -all -inline $fanout $out_key]]
    #set cnt_out 0
    #puts $a
    #puts $fanout
    #regsub -all {\/pins\_in\/D} $fanout "" fanout_for_search 
    #for {set i 0} {$i < [llength $fanout_for_search]} {incr i} {
    #    set out_key "*"
    #    append out_key [lindex $fanout_for_search $i]
    #    puts $out_key
    #    puts [lsearch -all -inline $all_out $out_key]
    #    if { [llength [lsearch -all -inline $all_out $out_key]] } then {incr cnt_out} 
    #}
    #puts $cnt_out

    puts $fp [llength $fanin]
    puts $fp [llength $fanout]
    puts $fp [llength $fanin_verbose]
    puts $fp [llength $fanout_verbose]
    
    set fanin_loop [all_fanin -to $mytmp]
    if { [llength [lsearch -all -inline  $fanin_loop  $search_key] ]} then {puts $fp "1"} else {puts $fp "0"}

    puts $fp [llength $all_in]
    puts $fp [llength $all_out]
    puts $fp [llength $all_reg]
}
puts "registers D done"



close $fp


