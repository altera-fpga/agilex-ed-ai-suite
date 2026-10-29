# how to run this script:
# option 1: within coredla workspace
# - enter dla_shell.py
# - cd /path/to/this/file
# - run this from the command line: "vsim -c -do run_msim.do"
#
# option 2: run inside the Questasim GUI
# - enter dla_shell.py or (install Modelsim starter edition on Windows laptop)
# - open the Questasim GUI e.g. run this: vsim
# - inside the GUI run this: cd {/path/to/this/file}
# - inside the GUI run this: do run_msim.do

# make a workspace
vlib work

# compile DUT and testbench
vlog -sv +acc ../rtl/axi_st_to_avalon_st_bridge.sv
vlog -sv +acc tb_axi_st_to_avalon_st_bridge.sv

# run the testbench
vsim -voptargs=+acc tb_axi_st_to_avalon_st_bridge -do "log -r *; run -all"

# if you want to see any signal that was not logged, add it to the waveforms and then run this
#restart -f
#run -all
