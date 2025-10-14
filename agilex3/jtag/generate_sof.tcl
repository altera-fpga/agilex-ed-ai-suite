# generate_sof.tcl
# Script for compiling the coreDLA Agilex 3 JTAG Design example targeting Intel Agilex 3C Development Kit.
# Responsible for generating the .sof file.

# Check if exactly three arguments are provided
proc compile_script {project_name revision_name family_name device_name} {
    qexec "qsys-generate -syn --family=\"$family_name\" --part=$device_name qsys/shell.qsys 2>&1"
    qexec "quartus_syn --write_settings_files=off $project_name 2>&1"
    qexec "quartus_fit --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1"
    qexec "quartus_sta $project_name -c $revision_name --mode=finalize 2>&1"
    qexec "quartus_cdb -t dla_adjust_pll.tcl 2>&1"
    qexec "quartus_asm --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1"
}

proc main {} {
    set project_name top
    set revision_name top
    set family_name {Agilex 3}
    set device_name A3CY135BM16AE6S
    # Setup QSYS project
    cd qsys
    qexec "echo \"INFO: Creating Platform Designer System\""
    qexec "qsys-script --cmd=\"set system_name shell;\" --script=ed_zero.tcl --quartus_project=none 2>&1"
    cd ..
    # Compile the project and generate bitstream
    compile_script $project_name $revision_name $family_name $device_name
    # Generates QoR JSON - extra report for user and build_example_Diesngo
    set project_ip_clock "pd|dla_pll_0|altera_iopll_inst_outclk0"
    source dla_parse_report.tcl 
    dla_parse_report -project top -ip-clock ${project_ip_clock} -platform-clock ${project_ip_clock}
}


main
