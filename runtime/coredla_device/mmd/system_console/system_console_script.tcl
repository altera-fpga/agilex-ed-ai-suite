# Author: linqiaol
# Purpose: Perform write-read tests on external memory and CoreDLA CSR to make sure the registers can be accessed from host.

# Declare and initialize CL arguments
if {![info exists ::cl(sof)]} {
    set ::cl(sof)                "top.sof"
}

if {![info exists ::cl(enable_pmon)]} {
    set ::cl(enable_pmon)                0
}

if {![info exists ::cl(jtag_path)]} {
    set ::cl(jtag_path) "*jtag*master*"
}

# Declare global variables
set ::g_emif_calip_service ""
set ::g_emif_ddr_service ""
set ::g_dla_csr_service ""
set ::g_pmon_service ""
set ::g_master_paths ""

# Declare some contants
set ::g_const_master_offset_emif  0x0
set ::g_const_master_range_emif   0x080000000
# Actual range of the DLA CSR is from 0x8000_0000 to 0x8000_07FF
# 0x8000_0800 to 0x8000_08FF is the timer address
set ::g_const_master_offset_dla   0x080000000
set ::g_const_master_range_dla    0x000000900

#{{{ load_sof
proc load_sof {} {
    puts "loading sof: $::cl(sof)"
    design_load $::cl(sof)
}
#}}}

#{{{claim_emif_ddr_service
proc claim_emif_ddr_service {} {
    set path [lindex $::g_master_paths [lsearch -glob $::g_master_paths $::cl(jtag_path)]]
    if {$path eq ""} {
        error "Unable to find the JTAG master matching $::cl(jtag_path) from all the master paths detected: $::g_master_paths"
    }
    puts "Using jtag path $path for ddr_service"
    set service [claim_service master $path {} "\{${::g_const_master_offset_emif} ${::g_const_master_range_emif} EXCLUSIVE\}"]
    return $service
}
#}}}

#{{{claim_dla_csr_service
proc claim_dla_csr_service {} {
    set path [lindex $::g_master_paths [lsearch -glob $::g_master_paths $::cl(jtag_path)]]
    if {$path eq ""} {
        error "Unable to find the JTAG master matching $::cl(jtag_path) from all the master paths detected: $::g_master_paths"
    }
    puts "Using jtag path $path for csr_service"
    set service [claim_service master $path {} "\{${::g_const_master_offset_dla} ${::g_const_master_range_dla} EXCLUSIVE\}"]
    return $service
}
#}}}

#{{{claim_pmon_service
proc claim_pmon_service {} {
    set path [lindex $::g_master_paths [lsearch -glob $::g_master_paths *pmon*master*]]
    if {$path eq ""} {
        error "Unable to find the PMON JTAG-Avalon Bridge from all the master paths detected: $::g_master_paths"
    }
    set service [claim_service master $path {} {{0x0 0x00001000 EXCLUSIVE}}]
    return $service
}
#}}}

proc initialization {} {
    load_sof
    # puts "Claim required services"
    set ::g_master_paths       [get_service_paths master]
    # puts "Found the following master service paths:"
    # foreach line $::g_master_paths {
    #     puts "$line"
    # }
    set ::g_dla_csr_service    [claim_dla_csr_service]
    set ::g_emif_ddr_service   [claim_emif_ddr_service]
    if {$::cl(enable_pmon) == 1} {
        puts "Claiming JTAG service to the AXI4 performance monitor"
        set ::g_pmon_service       [claim_pmon_service]
    }
}

proc close_services {} {
    close_service master $::g_dla_csr_service
    if {$::cl(enable_pmon) == 1} {
        close_service master $::g_pmon_service
    }
    close_service master $::g_emif_ddr_service
    puts "Closed DLA JTAG services"
}

initialization