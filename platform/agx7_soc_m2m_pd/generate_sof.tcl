# generate_sof.tcl
# Compile the bitstream for the memory-to-memory Agilex 7 SoC example design.

# Generate the qsys system
qexec "cd qsys && qsys-script --new-quartus-project=system --script=system.tcl"
qexec "qsys-generate --quartus-project=top qsys/system.qsys --synthesis"

# Compile the project
load_package flow
project_open top
execute_flow -compile
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
set ip_clock "i_system|dla_pll_0|dla_pll_0_clk_dla"
set platform_clock "MAIN_CLOCK"
dla_parse_report -project top -ip-clock $ip_clock -platform-clock $platform_clock
