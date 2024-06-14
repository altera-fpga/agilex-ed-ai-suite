# Copyright 2024-2025 Altera Corporation

# Script for compiling the coreDLA ED3 (de10-agilex)
# is responsible for generating the .sof file
# Is called by dla_build_example_design for building the ED3 hardware

# Check if exactly three arguments are provided
proc unix_compile_script {project_name revision_name family_name device_name} {
    qexec "qsys-generate -syn --family=\"$family_name\" --part=$device_name board.qsys 2>&1 | tee qsys_generate.log"
    qexec "qsys-archive --quartus-project=$project_name --rev=opencl_bsp_ip --add-to-project board.qsys 2>&1 | tee qsys_archive.log"
    qexec "quartus_syn --read_settings_files=off --write_settings_files=off $project_name -c $revision_name 2>&1 | tee quartus_syn.log"
    qexec "quartus_fit --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1 | tee quartus_fit.log"
    qexec "quartus_sta $project_name -c $revision_name --mode=finalize 2>&1 | tee quartus_sta.log"
    qexec "quartus_cdb -t dla_adjust_pll.tcl 2>&1 | tee dla_adjust_pll.log"
    qexec "quartus_asm --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1 | tee quartus_asm.log"
}


proc windows_compile_script {project_name revision_name family_name device_name} {
    puts "Running qsys-generate. Writing output to qsys-generate.log";
    qexec "qsys-generate -syn --family=\"$family_name\" --part=$device_name board.qsys 2>&1 >> qsys_generate.log"
    puts "Running qsys-archive. Writing output to qsys-archive.log";
    qexec "qsys-archive --quartus-project=$project_name --rev=opencl_bsp_ip --add-to-project board.qsys 2>&1 >> qsys_archive.log"
    puts "Running quartus_syn. Writing output to quartus_syn.log";
    qexec "quartus_syn --read_settings_files=off --write_settings_files=off $project_name -c $revision_name 2>&1 >> quartus_syn.log"
    puts "Running quartus_fit. Writing output to quartus_fit.log";
    qexec "quartus_fit --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1 >> quartus_fit.log"
    puts "Running quartus_sta. Writing output to quartus_sta.log";
    qexec "quartus_sta $project_name -c $revision_name --mode=finalize 2>&1 >> quartus_sta.log"
    puts "Running quartus_cdb -t dla_adjust_pll. Writing output to dla_adjust_pll.log";
    qexec "quartus_cdb -t dla_adjust_pll.tcl 2>&1 >> dla_adjust_pll.log"
    puts "Running quartus_asm. Writing output to quartus_asm.log";
    qexec "quartus_asm --read_settings_files=on --write_settings_files=off $project_name -c $revision_name 2>&1 >> quartus_asm.log"
}


proc main {} {
    set project_name top
    set revision_name flat
    set family_name Agilex
    set device_name AGFB014R24B2E2V

    if {[string equal $::tcl_platform(platform) "unix"]} {
        unix_compile_script $project_name $revision_name $family_name $device_name
    } else {
        windows_compile_script $project_name $revision_name $family_name $device_name
    }
}

main

# Generate the QoR reports
source dla_parse_report.tcl
set clock "board_inst|kernel_clk_gen|kernel_clk_gen|kernel_pll_outclk0"
dla_parse_report -project flat -ip-clock $clock -platform-clock $clock
