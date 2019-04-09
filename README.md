# thesis_SFV
this repository contains the codes for Yuxin Wang's Master Thesis Research

The contents in each directory is listed as follows:
- auto_gen [the automatic waypoint guide generation tool]
  
  all python files belong to the generation tool
  
  the .csv file and the .v are the sample data for demo

- neural_network_prediction

  NN_model.keras the is trained neural network model

  NN_predict.py is the script to score all flip-flops using the model above

  .csv file is the sample data for demo
  
- riscv_formal_verificaiton 

  this riscv-semi-formal is based on work from Clifford Wolf, refer to https://github.com/SymbioticEDA/riscv-formal
  
  some vcd files and tcl files specifically designed for waypoint based Semi-formal methods

- sync_fifo

  this directory contains the script to source information fron Candece RC as well as the raw data gathered for scoring prediction

How to use
-----

- Neural_network_prediction

simply run:  python NN_predict.py [your csv file]

- auto_gen

simply run:  python parse_v_file.py [your csv file] [your verilog file]

- riscv_formal_verification

  this version with jg_cmd.tcl is designed specifically for Cadence JasperGold. Readers can modify it to accommodate for other formal engine supports SVA.

  Files need to be modify during SFV run is jg_define.sv, jg_cmd.tcl based on specific instruction you want to run. naming convention is strictly based on RISCV specification. It won't be hard to figure it out thus will not be elborated here.



