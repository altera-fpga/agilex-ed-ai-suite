# generate_sof.tcl
# Compile the bitstream for the memory-to-memory Arria 10 SoC example design.

# Generate the qsys system
qexec "cd qsys && qsys-script --new-quartus-project=system --script=system.tcl"
qexec "qsys-generate --quartus-project=top qsys/system.qsys --synthesis"

# Compile the project
load_package flow
project_open top
execute_flow -compile
execute_module -tool cpf -args "-c --hps -o bitstream_compression=on output_files/top.sof output_files/top.rbf"
project_close

# Generate the QoR reports
#
# Note: 'dla_parse_report.tcl' is copied into the build directory by
# dla_build_example_design.py.  The script can be manually written into any
# directory with
#
# dla_build_example_design.py scripts --copy dla_parse_report.tcl /path/to/directory`
#
source dla_parse_report.tcl
set ip_clock "system|dla_pll_0|iopll_0|clk_dla"
set platform_clock "clk_100"
dla_parse_report -project top -ip-clock $ip_clock -platform-clock $platform_clock
