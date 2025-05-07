# generate_sof.tcl
# Script for compiling the coreDLA Agilex 5 JTAG Design example targeting Intel Agilex 5 Modular Development Kit.
# Responsible for generating the .sof file.

# Check if exactly three arguments are provided
proc compile_script {project_name revision_name family_name device_name} {
    qexec "qsys-generate -syn --family=\"$family_name\" --part=$device_name qsys/shell.qsys 2>&1 | tee qsys_generate.log"
    qexec "quartus_syn --write_settings_files=off $project_name 2>&1 | tee quartus_syn.log"
    qexec "quartus_fit --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1 | tee quartus_fit.log"
    qexec "quartus_sta $project_name -c $revision_name --mode=finalize 2>&1 | tee quartus_sta.log"
    qexec "quartus_cdb -t dla_adjust_pll.tcl 2>&1 | tee dla_adjust_pll.log"
    qexec "quartus_asm --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1 | tee quartus_asm.log"
}

proc main {} {
    set project_name top
    set revision_name top
    set family_name {Agilex 5}
    set device_name A5ED065BB32AE6SR0
    # Setup QSYS project
    cd qsys
    qexec "echo \"INFO: Creating Platform Designer System\""
    qexec "qsys-script --cmd=\"set system_name shell;\" --script=ed_zero.tcl --quartus_project=none 2>&1 | tee deploy_shell.og"
    cd ..
    # Compile the project and generate bitstream
    compile_script $project_name $revision_name $family_name $device_name
    # Generates QoR JSON
    set project_ip_clock "pd|dla_pll_0|altera_iopll_inst_outclk0"
    source dla_parse_report.tcl 
    dla_parse_report -project top -ip-clock ${project_ip_clock} -platform-clock ${project_ip_clock}
}


main
