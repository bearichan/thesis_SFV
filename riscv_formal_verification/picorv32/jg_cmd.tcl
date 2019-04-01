clear -all;

analyze -v2k picorv32.v;
analyze -sv -f sv_file.f;

elaborate -top {rvfi_testbench};
# elaborate -top {serv_top_verif}

clock clock;
# reset -expression reset;
# reset -sequence -vcd rvfi_valid_lw_new.vcd
reset -sequence -vcd auto_lw_new.vcd

# abstract -init_value -task {<embedded>} {wrapper.uut.pc};
# assume -bound 10 {wrapper.uut.pc == wrapper.uut.o_ibus_adr};
# abstract -init_value {wrapper.uut.ctrl.o_ibus_cyc}
# abstract -init_value -task {<embedded>} {wrapper.uut.regfile.memory[0]};
# assume -bound 80  -constant wrapper.uut.rs1_fv 
# abstract -register_value rvfi_testbench.wrapper.uut.rvfi_insn


prove -bg -all;
