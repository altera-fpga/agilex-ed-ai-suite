# generate_sof.tcl
# Compile the bitstream for the spatial IP on the Altera Agilex 5 E-Series Modular Development Kit
# using the VDS system.

# Build the VDS system by doing the following:
#
# 1. Open the system top level Quartus project. This is required since system.tcl calls
# "load_package vds", "get_project_directory" along with many other vds:: namespace Tcl APIs,
# which are only available inside of a Quartus project.
#
# 2. Source system.tcl which saves vds files under src/vds. A side effect is that vds will overwrite
# the top level .qsf file with an incomplete VDS_IP_FILE/VDS_FILE list. To get
# around this, system_top.qsf is saved and restored after vds generation.
#
# 3. Restore the QSF, rewrite a complete vds_files.tcl from the saved VDS tree,
#    then run quartus_ipgenerate (emits synth RTL for VDS_FILE / VDS_IP_FILE,
#    including EMIF created from VLNV) and the rest of the Quartus compile.

# VDS GUI-backed operations (create_system) require an X display even when
# scripted, so Xvfb is started and pointed to directly here. This requires Xvfb
# to be installed (package "xvfb" on Ubuntu, "xorg-x11-server-Xvfb" on RHEL).
# The whole vds system is created by invoking "quartus_sh build_system.tcl" inside of a
# "build_system.sh" script that sets $DISPLAY
proc build_vds_system {family_name device_name board_name} {
    # Save the .qsf file to restore after vds files are generated
    file copy -force system_top.qsf system_top.qsf.orig

    # Create build_system.tcl. Inside, it sources system.tcl
    set fp [open build_system.tcl w]
    puts $fp {project_open system_top}
    puts $fp {load_package vds}

    # system.tcl gives no progress feedback while it builds the system (a
    # multi-minute, silent step), so every mutating vds:: command (create_system
    # /create_cell/connect_net/etc., but not query commands like get_*/list_*/
    # report_*/is_*) is traced to print as it runs. load_package vds is called
    # early here (a no-op when system.tcl calls it again) so the vds:: commands
    # exist to trace before system.tcl is sourced.
    puts $fp {proc log_vds_call {commandString op} { puts "VDS: $commandString" }}
    puts $fp {
foreach vds_cmd [info commands ::vds::*] {
    set vds_cmd_name [namespace tail $vds_cmd]
    if {[regexp {^(get|list|report|is)_} $vds_cmd_name]} continue
    trace add execution $vds_cmd enter log_vds_call
}
}
    puts $fp {source system.tcl}
    puts $fp {project_close -dont_export_assignments}
    close $fp

    # Create the build_system.sh script that sets $DISPLAY and runs build_system.tcl
    set fp [open build_system.sh w]
    puts $fp {if ! command -v Xvfb >/dev/null 2>&1; then}
    puts $fp {    echo "Error: Xvfb not found. Please install it (package \"xvfb\" on Ubuntu, \"xorg-x11-server-Xvfb\" on RHEL)." >&2}
    puts $fp {    exit 1}
    puts $fp {fi}
    puts $fp {set -e}
    puts $fp {display=":$$"}
    puts $fp {Xvfb "$display" -screen 0 1024x768x24 -nolisten tcp &}
    puts $fp {xvfb_pid=$!}
    puts $fp {trap 'kill $xvfb_pid 2>/dev/null' EXIT}
    puts $fp {for i in 1 2 3 4 5; do [ -e "/tmp/.X11-unix/X${display#:}" ] && break; sleep 1; done}
    puts $fp {DISPLAY="$display" quartus_sh -t build_system.tcl}
    close $fp
    qexec "bash build_system.sh"

    file rename -force system_top.qsf.orig system_top.qsf
    file delete -force system_top.qsf.backup

    # Enumerate the generated VDS output directly from the filesystem rather
    # than scraping the QSF: sourcing system.tcl does not reliably record a
    # VDS_IP_FILE assignment for every child IP, which leaves those IPs out of
    # top level generation and produces "undefined entity" synthesis errors.
    # Each system directory holds "<system>.vds" plus an "ip" subdirectory of
    # child IPs, so the assignments can be reconstructed deterministically.
    # IP_SEARCH_PATHS stay in system_top.qsf.
    set fp [open vds_files.tcl w]
    foreach vds_file [glob -nocomplain src/vds/*/*.vds] {
        set sysdir [file dirname $vds_file]
        set sys [file tail $sysdir]
        puts $fp "set_global_assignment -name VDS_FILE $vds_file -tag \"vds::$sys\""
        foreach ip_file [glob -nocomplain $sysdir/ip/*.ip] {
            puts $fp "set_global_assignment -name VDS_IP_FILE $ip_file -tag \"vds::$sys\""
        }
    }
    close $fp
}

proc compile_script {project_name revision_name} {
    qexec "quartus_ipgenerate --generate_project_ip_files --synthesis=verilog $project_name -c $revision_name"
    qexec "quartus_syn --read_settings_files=off --write_settings_files=off $project_name -c $revision_name"
    qexec "quartus_fit --read_settings_files=on --write_settings_files=off $project_name -c $revision_name"
    qexec "quartus_sta $project_name -c $revision_name --mode=finalize --do_report_timing"
    # Dial the kernel IOPLL to the fmax the fitter actually reached. This edits
    # the post-fit netlist and re-runs STA, so it has to land between the fitter
    # and the assembler.
    qexec "quartus_cdb -t dla_adjust_pll.tcl"
    qexec "quartus_asm --read_settings_files=on --write_settings_files=off $project_name -c $revision_name"
}

# dla_adjust_pll.tcl leaves the kernel clock at whatever frequency the fitter
# could reach, which is rarely the target setup_project.py wrote into
# kernel_clk.json before the compile. The host demo divides its cycle count by
# that value to report a latency in microseconds, so bring the file up to date
# with the frequency the bitstream actually carries.
proc update_kernel_clk {} {
    set report "acl_quartus_report.txt"
    set config "kernel_clk.json"

    foreach file [list $report $config] {
        if {![file exists $file]} {
            post_message -type warning "$file not found, leaving the kernel clock in kernel_clk.json alone"
            return
        }
    }

    set fh [open $report r]
    set report_text [read $fh]
    close $fh

    if {![regexp {Actual clock freq:\s*([0-9.]+)} $report_text -> achieved_mhz]} {
        post_message -type warning "No achieved clock frequency in $report, leaving the kernel clock in kernel_clk.json alone"
        return
    }

    set fh [open $config r]
    set config_text [read $fh]
    close $fh

    # setup_project.py writes this key on its own line through json.dumps, so a
    # line oriented substitution cannot disturb the rest of the file.
    set pattern {("kernel_clk_mhz"\s*:\s*)[0-9.]+}
    if {![regexp $pattern $config_text]} {
        post_message -type warning "No kernel_clk_mhz key in $config, leaving it alone"
        return
    }
    regsub $pattern $config_text "\\1$achieved_mhz" config_text

    set fh [open $config w]
    puts -nonewline $fh $config_text
    close $fh
    post_message "Recorded kernel clock of $achieved_mhz MHz in $config"
}

proc main {} {
    set project_name system_top
    set revision_name system_top
    set family_name "Agilex 5"
    set device_name A5ED065BB32AE4S
    set board_name "Agilex 5 FPGA E-Series 065B Modular Development Kit MK-A5E065BB32AEA"

    qexec "echo \"INFO: Building VDS system\""
    build_vds_system $family_name $device_name $board_name

    # Compile the project and generate bitstream
    compile_script $project_name $revision_name

    update_kernel_clk

    # Generates QoR JSON
    set project_ip_clock "system_inst|kernel_clk_iopll|kernel_clk_iopll_outclk0"
    source dla_parse_report.tcl
    dla_parse_report -project $project_name -ip-clock ${project_ip_clock} -platform-clock ${project_ip_clock}  -revision ${revision_name} -project ${project_name}
}

main
