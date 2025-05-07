# (c) 1992-2024 Altera Corporation.
# Altera, the Altera logo, Altera, MegaCore, NIOS II, Quartus and TalkBack words
# and logos are trademarks of Altera Corporation or its subsidiaries in the U.S.
# and/or other countries. Other marks and brands may be claimed as the property
# of others. See Trademarks on altera.com for full list of Altera trademarks or
# See www.Intel.com/legal (if Altera)
# Your use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any output
# files any of the foregoing (including device programming or simulation
# files), and any associated documentation or information are expressly subject
# to the terms and conditions of the Altera Program License Subscription
# Agreement, Altera MegaCore Function License Agreement, or other applicable
# license agreement, including, without limitation, that your use is for the
# sole purpose of programming logic devices manufactured by Altera and sold by
# Altera or its authorized distributors.  Please refer to the applicable
# agreement for further details.
post_message "Running adjust PLLs script"

# Required packages
package require ::quartus::project
package require ::quartus::report
package require ::quartus::flow
# Need to interact with atom netlists
package require ::quartus::atoms
# Need to loade the design
package require ::quartus::design
package ifneeded ::altera::pll_legality 1.0 {
  switch $tcl_platform(platform) {
    windows {
      load [file join $::quartus(binpath) qcl_pll_legality_tcl.dll] pll_legality
    }
    unix {
      load [file join $::quartus(binpath) libqcl_pll_legality_tcl[info sharedlibextension]] pll_legality
    }
  }
}
package require ::quartus::qcl_pll
package require ::quartus::pll::legality

# Definitions
set pll_search_string  "*dla_pll_0*"
if {![info exists k_clk_name]} {
    set k_clk_name "${pll_search_string}altera_iopll_inst_outclk0"
}

set iteration 1
set setup_timing_violation 1

# When a clock is unused, set its FMAX to this (very high) number so it doesn't impact settings of other clocks
set unused_clk_fmax 10000

# Quartus Environment
set project_name top
set revision_name top
set acds_version 25.1

# Utility functions

# ------------------------------------------------------------------------------------------
proc get_nearest_achievable_frequency { desired_kernel_clk  \
                                        refclk_freq \
                                        device_family \
                                        device_speedgrade} {
#
# Description :  Returns the closest achievable IOPLL frequency less than or
#                equal to desired_kernel_clk.
#
# Parameters :
#    desired_kernel_clk  - The desired frequency in MHz (floating point)
#    refclk_freq         - The IOPLL's reference clock frequency in MHz (floating point up to 6 digits)
#    device_family       - The device family ("Agilex 5")
#    device_speedgrade   - The device speedgrade (1, 2, 3, 4, 5, or 6)
#
# Assumptions :
#    - There is one desired output clock derived by the PLL, the kernel_clk
#    - The clock has a have zero phase shift
#    - The desired_kernel_clk frequency is > 10 MHz
#
# -------------------------------------------------------------------------------------------

  # Use array get to ensure correct input formatting (and avoid curly braces)
  set desired_output(0) [list -type c -index 0 -freq $desired_kernel_clk -phase 0.0 -is_degrees false -duty 50.0]
  set desired_counter [array get desired_output]

  # Prepare the arguments for a call to the PLL legality package.
  # The non-obvious parameters here are all effectively don't cares.
  # hack: hardcode speedgrade to 3, because the somehow the legality solver does not support speedgrade 5 or 6
  # gui_pll_mode is Integer-N PLL, so -is_fractional is set to false
  # gui_operation_mode sets -compensation_mode
  # gui_fractional_cout sets -x
  set ref_list [list  -family                       $device_family \
                      -speedgrade                   3 \
                      -refclk_freq                  $refclk_freq \
                      -is_fractional                false \
                      -compensation_mode            direct \
                      -is_counter_cascading_enabled false \
                      -x                            32 \
                      -validated_counter_values     {} \
                      -desired_counter_values       $desired_counter \
                      -prot_mode                    BASIC]

  post_message "Calling ::quartus::pll::legality::retrieve_output_clock_frequency_list with $ref_list"
  if {[catch {::quartus::pll::legality::retrieve_output_clock_frequency_list $ref_list} result]} {
    post_message "Call to retrieve_output_clock_frequency_list failed because:"
    post_message $result
    return TCL_ERROR
    # ERROR
  }

  # We get a list of six legal frequencies for kernel_clk
  array set result_array $result
  set freq_list $result_array(freq)

  # Pick the closest frequency that's still less than the desired frequency
  # Recover the legal kernel_clk frequencies as we go
  set best_freq 0
  set possible_kernel_freqs {}

  foreach freq_temp $freq_list {
    set freq $freq_temp
    lappend possible_kernel_freqs $freq
    if { $freq > $desired_kernel_clk } {
      # The frequency exceeds fmax -- no good.
    } elseif { $freq > $best_freq } {
      set best_freq $freq
    }
  }

  post_message "List of possible_kernel_freqs: ${possible_kernel_freqs}"
  if {$best_freq == 0} {
    post_message "All of the frequencies were too high!"
    return TCL_ERROR
    # ERROR
  } else {
    post_message "Found best possible frequency: ${best_freq}"
    return $best_freq
    # SUCCESS!
  }

}

# ------------------------------------------------------------------------------------------
proc adjust_iopll_frequency_in_postfit_netlist { design_name \
                                                 pll_name \
                                                 device_family \
                                                 device_speedgrade \
                                                 legalized_kernel_clk \
                                                 {pll_refclk ""} } {
#
# Description :  Configures IOPLL "pll_name" parameter settings to produce a new output frequency
#                of legalized_kernel_clk.  This must be a legal setting for success.
#
# Parameters :
#    design_name          - Design name (i.e. <design_name>.qpf)
#    pll_name             - The full hierarchical name of the target IOPLL in the design
#    device_family        - The device family (Agilex 5)
#    device_speedgrade    - The device speedgrade (1, 2, 3, 4, 5, or 6)
#    legalized_kernel_clk - The new kernel_clk frequency (legalized by get_nearest_achievable_frequency)
#    pll_refclk           - Refclock frequency in MHz
#
# Assumptions :
#    - The legalized_kernel_clk frequency is, in fact, legal
#    - There is one desired output clocks, the kernel_clk
#    - The desired clock has zero phase shift
#    - The PLL is set to Medium (auto) bandwidth
#    - m-counter, n-counter, and c0 counter are not by-passed
#
# -------------------------------------------------------------------------------------------
  set refclk_mhz $pll_refclk
  # Get the IOPLL node
  if {$refclk_mhz eq ""} {
    if { [catch {set node [get_atom_node_by_name -name $pll_name]} ] } {
      post_message "IOPLL not found: $pll_name"
      list_plls_in_design
      return TCL_ERROR
      # ERROR
    }

    # Get the refclk frequency from the IOPLL node
    # Using the netlist's refclk frequency gives us a santity check.
    set refclk_freq_bin [get_atom_node_info -key REF_CLK_0_FREQ -node $node]
    set refclk [expr "0b$refclk_freq_bin"]
    set refclk_mhz [expr {$refclk / 1000000.0}]
  }
  # Desired output frequency (kernel_clk)
  set outclk0 $legalized_kernel_clk
  set desired_output(0) [list -type c -index 0 -freq $outclk0 -phase 0.0 -is_degrees false -duty 50.0]
  # must enable clock 1 as well because two peripheral clocks are always enabled. Copy clock 0 values
  set desired_output(1) [list -type c -index 1 -freq $outclk0 -phase 0.0 -is_degrees false -duty 50.0]
  set desired_counters  [array get desired_output]

  # Compute the new IOPLL settings
  set result 0

  # linqiaol hack: hardcode speedgrade to 3, because the somehow the legality solver does not support speedgrade 5 or 6
  # gui_fractional_cout sets x
  # m, n, and k (fractional count values) are omitted
  set arg_list [list -prot_mode "BASIC" \
                     -using_adv_mode false \
                     -family $device_family \
                     -speedgrade 3 \
                     -compensation_mode direct \
                     -refclk_freq $refclk_mhz \
                     -is_fractional false \
                     -x 32 \
                     -bw_preset Medium \
                     -is_counter_cascading_enabled false \
                     -validated_counter_settings [array get desired_output] \
                     -prot_mode                    BASIC]

  set error [catch {::quartus::pll::legality::get_physical_parameters_for_generation $arg_list} result]

  if {$error} {
    post_message "Failed to generate new IOPLL settings.  The requested output frequency might have been illegal."
    post_message $result
    return TCL_ERROR
    # ERROR
  }

  # Extract the new IOPLL settings
  array set result_array $result

  # M counter settings
  array set m_array $result_array(m)
  set m_hi_div      $m_array(m_high)
  set m_lo_div      $m_array(m_low)
  set m_bypass      $m_array(m_bypass_en)
  # m_cnt_odd_div_duty_en
  set m_duty_tweak  $m_array(m_tweak)

  # N counter settings
  array set n_array $result_array(n)
  set n_hi_div      $n_array(n_high)
  set n_lo_div      $n_array(n_low)
  set n_bypass      $n_array(n_bypass_en)
  # n_cnt_odd_div_duty_en
  set n_duty_tweak  $n_array(n_tweak)

  post_message "m_hi_div: $m_hi_div"
  post_message "m_lo_div: $m_lo_div"
  post_message "m_bypass: $m_bypass"
  post_message "m_duty_tweak: $m_duty_tweak"

  post_message "n_hi_div: $n_hi_div"
  post_message "n_lo_div: $n_lo_div"
  post_message "n_bypass: $n_bypass"
  post_message "n_duty_tweak: $n_duty_tweak"

  # VCO frequency
  set vco_freq [format "%0*b" 36  [expr { int([round_to_atom_precision $result_array(vco_freq)] * 1000000) }]]

  # PFD frequency
  set pfd_freq [expr {$refclk_mhz / ($n_hi_div + $n_lo_div)}]
  set pfd_freq [format "%0*b" 36  [expr { int($pfd_freq * 1000000) }]]

  # C counter settings
  array set c_array $result_array(c)

  # C0 counter settings
  array set c0_array $c_array(0)
  array set c1_array $c_array(1)
  set outclk_freq0 [format "%0*b" 36  [expr { int([round_to_atom_precision $c0_array(freq)] * 1000000) }]]
  set c0_hi_div     $c0_array(c_high)
  set c0_lo_div     $c0_array(c_low)
  set c0_bypass     $c0_array(c_bypass_en)
  # c_cnt_odd_div_duty_en0
  set c0_duty_tweak $c0_array(c_tweak)

  set outclk_freq1 [format "%0*b" 36  [expr { int([round_to_atom_precision $c1_array(freq)] * 1000000) }]]
  set c1_hi_div     $c1_array(c_high)
  set c1_lo_div     $c1_array(c_low)
  set c1_bypass     $c1_array(c_bypass_en)
  # c_cnt_odd_div_duty_en0
  set c1_duty_tweak $c1_array(c_tweak)

  post_message "c0_array(freq): $c0_array(freq)"
  post_message "c0_hi_div: $c0_hi_div"
  post_message "c0_lo_div: $c0_lo_div"
  post_message "c0_bypass: $c0_bypass"
  post_message "c0_duty_tweak: $c0_duty_tweak"

  # Apply the new settings:
      # Modify by pxx
  if {$device_family == "Agilex 5" } {
      # bit vector
      set_atom_node_info -key OUT_CLK_0_FREQ -node $node $outclk_freq0
      set_atom_node_info -key OUT_CLK_0_DUTYCYCLE_DEN -node $node [expr {2 * ($c0_lo_div + $c0_hi_div)}]
      if ($c0_duty_tweak) {
        set_atom_node_info -key OUT_CLK_0_DUTYCYCLE_NUM -node $node [expr {2 * $c0_hi_div - 1}]
      } else {
        set_atom_node_info -key OUT_CLK_0_DUTYCYCLE_NUM -node $node [expr {2 * $c0_hi_div}]
      }
      # need to set OUT_CLK_1_* values too to pass constra
      set_atom_node_info -key OUT_CLK_0_C_DIV -node $node [expr {$c0_lo_div + $c0_hi_div}]
      set_atom_node_info -key OUT_CLK_1_FREQ -node $node $outclk_freq1
      set_atom_node_info -key OUT_CLK_1_DUTYCYCLE_DEN -node $node [expr {2 * ($c1_lo_div + $c1_hi_div)}]
      if ($c0_duty_tweak) {
        set_atom_node_info -key OUT_CLK_1_DUTYCYCLE_NUM -node $node [expr {2 * $c1_hi_div - 1}]
      } else {
        set_atom_node_info -key OUT_CLK_1_DUTYCYCLE_NUM -node $node [expr {2 * $c1_hi_div}]
      }
      set_atom_node_info -key OUT_CLK_1_C_DIV -node $node [expr {$c1_lo_div + $c1_hi_div}]
      set_atom_node_info -key VCO_CLK_FREQ -node $node $vco_freq
      set_atom_node_info -key PFD_CLK_FREQ -node $node $pfd_freq
      set_atom_node_info -key REF_CLK_N_DIV -node $node [expr {$n_lo_div + $n_hi_div}]
      set_atom_node_info -key FB_CLK_M_DIV -node $node [expr {$m_lo_div + $m_hi_div}]

      post_message "New OUT_CLK_0_FREQ: [get_atom_node_info -key OUT_CLK_0_FREQ -node $node]"
      post_message "New OUT_CLK_0_DUTYCYCLE_DEN: [get_atom_node_info -key OUT_CLK_0_DUTYCYCLE_DEN -node $node]"
      post_message "New OUT_CLK_0_DUTYCYCLE_NUM: [get_atom_node_info -key OUT_CLK_0_DUTYCYCLE_NUM -node $node]"
      post_message "New OUT_CLK_1_FREQ: [get_atom_node_info -key OUT_CLK_1_FREQ -node $node]"
      post_message "New OUT_CLK_1_DUTYCYCLE_DEN: [get_atom_node_info -key OUT_CLK_1_DUTYCYCLE_DEN -node $node]"
      post_message "New OUT_CLK_1_DUTYCYCLE_NUM: [get_atom_node_info -key OUT_CLK_1_DUTYCYCLE_NUM -node $node]"
      # post_message "New OUT_CLK_0_C_DIV: [get_atom_node_info -key OUT_CLK_0_C_DIV: -node $node]"
      post_message "New VCO_CLK_FREQ: [get_atom_node_info -key VCO_CLK_FREQ -node $node]"
      post_message "New PFD_CLK_FREQ: [get_atom_node_info -key PFD_CLK_FREQ -node $node]"
      post_message "New REF_CLK_N_DIV: [get_atom_node_info -key REF_CLK_N_DIV -node $node]"
      post_message "New FB_CLK_M_DIV: [get_atom_node_info -key FB_CLK_M_DIV -node $node]"
  } else {
      post_message "Unsupported device family $device_family"
      return TCL_ERROR
  }
  # Success!
  return TCL_OK
}


proc round_to_atom_precision { value } {

  # Round to 6 decimal points
  set n 6
  set rounded_num [format "%.${n}f" $value]
  set double_version [expr {double($rounded_num)} ]

  if {[string length $double_version] <= [string length $rounded_num]} {
    return $double_version
  } else  {
    return $rounded_num
  }
}


proc list_plls_in_design { } {
  post_message "Found the following IOPLLs in design:"
  foreach_in_collection node [get_atom_nodes -type IOPLL] {
    set name [get_atom_node_info -key NAME -node $node]
    post_message "   $name"
  }
}


proc find_kernel_pll_in_design {pll_search_string} {
  foreach_in_collection node [get_atom_nodes -type IOPLL] {
    set node_name [ get_atom_node_info -key NAME -node $node]
    set name [get_atom_node_info -key NAME -node $node]
    if { [ string match $pll_search_string $node_name ] == 1} {
      post_message "Found kernel_pll: $node_name"
      set kernel_pll_name $node_name
      return $kernel_pll_name
    }
    puts $node_name
  }
}


# Return values: [retval panel_id row_index]
#   panel_id and row_index are only valid if the query is successful
# retval:
#    0: success
#   -1: not found
#   -2: panel not found (could be report not loaded)
#   -3: no rows found in panel
#   -4: multiple matches found
proc find_report_panel_row { panel_name col_index string_op string_pattern } {
    if {[catch {get_report_panel_id $panel_name} panel_id] || $panel_id == -1} {
        return -2;
    }

    if {[catch {get_number_of_rows -id $panel_id} num_rows] || $num_rows == -1} {
        return -3;
    }

    # Search for row match.
    set found 0
    set row_index -1;

    for {set r 1} {$r < $num_rows} {incr r} {
        if {[catch {get_report_panel_data -id $panel_id -row $r -col $col_index} value] == 0} {
            if {[string $string_op $string_pattern $value]} {
                if {$found == 0} {
                    # If multiple rows match, return the first
                    set row_index $r
                }
                incr found
            }
        }
    }

    if {$found > 1} {return [list -4 $panel_id $row_index]}
    if {$row_index == -1} {return -1}

    return [list 0 $panel_id $row_index]
}


# get_fmax_from_report: Determines the fmax for the given clock. The fmax value returned
# will meet all timing requirements (setup, hold, recovery, removal, minimum pulse width)
# across all corners.  The return value is a 2-element list consisting of the
# fmax and clk name
proc get_fmax_from_report { clkname required recovery_multicycle iteration } {
    global revision_name
    global unused_clk_fmax
    # Find the clock period.
    set result [find_report_panel_row "*Timing Analyzer||Clocks" 0 match $clkname]
    set retval [lindex $result 0]

    if {$retval == -1} {
        if {$required == 1} {
           error "Error: Could not find clock: $clkname"
        } else {
           post_message -type warning "Could not find clock: $clkname.  Clock is not required assuming 10 GHz and proceeding."
           return [list $unused_clk_fmax $clkname]
        }
    } elseif {$retval < 0} {
        error "Error: Failed search for clock $clkname (error $retval)"
    }

    # Update clock name to full clock name ($clkname as passed in may contain wildcards).
    set panel_id [lindex $result 1]
    set row_index [lindex $result 2]
    set clkname [get_report_panel_data -id $panel_id -row $row_index -col 0]
    set clk_period [get_report_panel_data -id $panel_id -row $row_index -col 2]

    post_message "Clock $clkname"
    post_message "  Period: $clk_period"

    # Determine the most negative slack across all relevant timing metrics (setup, recovery, minimum pulse width)
    # and across all timing corners. Hold and removal metrics are not taken into account
    # because their slack values are independent on the clock period (for kernel clocks at least).
    #
    # Paths that involve both a posedge and negedge of the kernel clocks are not handled properly (slack
    # adjustment needs to be doubled).
    set timing_metrics [list "Setup" "Recovery" "Minimum Pulse Width"]
    set timing_metric_colindex [list 1 3 5 ]
    set timing_metric_required [list 1 0 0]
    set wc_slack $clk_period
    set has_slack 0
    set fmax_from_summary 5000.0

    set panel_name "*Timing Analyzer||Multicorner Timing Analysis Summary"
    set panel_id [get_report_panel_id $panel_name]
    set result [find_report_panel_row $panel_name 0 equal " $clkname"]
    set retval [lindex $result 0]
    set single off
    if {$retval == -2} {
      post_message -type critical_warning "Multicorner Analysis is off. No analysis has been done for other corners!"
      set single on
    }

    # Find the "Fmax Summary" numbers reported in Quartus.  This may not
    # account for clock transfers but it does account for pos-to-neg edge same
    # clock transfers.  Whatever we calculate should be less than this.
    set fmax_panel_name UNKNOWN
    if {[string match $single "off"]} {
      set fmax_panel_name "*Timing Analyzer||* Model||*Fmax Summary"
    } else {
      set fmax_panel_name "*Timing Analyzer||Fmax Summary"
    }
    foreach panel_name [get_report_panel_names] {
      if {[string match $fmax_panel_name $panel_name] == 1} {
        set result [find_report_panel_row $panel_name 2 equal $clkname]
        set retval [lindex $result 0]
        if {$retval == 0} {
          set restricted_fmax_field [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col 1]
          regexp {([0-9\.]+)} $restricted_fmax_field restricted_fmax
          if {$restricted_fmax < $fmax_from_summary} {
            set fmax_from_summary $restricted_fmax
          }
        }
      }
    }
    post_message "  Restricted Fmax from STA: $fmax_from_summary"

    # Find the worst case slack across all corners and metrics
    foreach metric $timing_metrics metric_required $timing_metric_required col_ndx $timing_metric_colindex {
      if {[string match $single "on"]} {
        set panel_name "*Timing Analyzer||$metric Summary"
        set result [find_report_panel_row $panel_name 0 equal "$clkname"]
        set col_ndx 1
      } else {
        set panel_name "*Timing Analyzer||Multicorner Timing Analysis Summary"
        set result [find_report_panel_row $panel_name 0 equal " $clkname"]
        set single off
      }
      set panel_id [get_report_panel_id $panel_name]
      set retval [lindex $result 0]

      if {$retval == -1} {
        if {$required == 1 && $metric_required == 1} {
          error "Error: Could not find clock: $clkname"
        }
      } elseif {$retval < 0 && $retval != -4 } {
        error "Error: Failed search for clock $clkname (error $retval)"
      }

      if {$retval == 0 || $retval == -4} {
        set slack [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col $col_ndx ]
        post_message "    $metric slack: $slack"
        if {$slack != "N/A"} {
          if {$metric == "Setup" || $metric == "Recovery"} {
            set has_slack 1
            if {$metric == "Recovery"} {
            set normalized_slack [ expr $slack / $recovery_multicycle ]
              post_message "    normalized $metric slack: $normalized_slack"
              set slack $normalized_slack
            }
          }
        }
        # Keep track of the most negative slack.
        if {$slack < $wc_slack} {
          set wc_slack $slack
          set wc_metric $metric
        }
      }
    }
    if {$has_slack == 1} {
        # IOPLL jitter compensation convergence aid
        # for iterations 3, 4, 5 add 50ps, 100ps, 200ps of extra IOPLL period adjustment
        set jitter_compensation 0.0;
        if {$iteration > 2} {
          set jitter_compensation [expr 0.05*(2**($iteration-3))]
        }

        # Adjust the clock period to meet the worst-case slack requirement.
        set clk_period [expr $clk_period - $wc_slack + $jitter_compensation]
        post_message "  Adjusted period: $clk_period ([format %+0.3f [expr -$wc_slack]], $wc_metric)"

        # Compute fmax from clock period. Clock period is in nanoseconds and the
        # fmax number should be in MHz.
        set fmax [expr 1000 / $clk_period]

        if {$fmax_from_summary < $fmax} {
            post_message "  Restricted Fmax from STA is lower than $fmax, using it instead."
            set fmax $fmax_from_summary
        }

        # Truncate to two decimal places. Truncate (not round to nearest) to avoid the
        # very small chance of going over the clock period when doing the computation.
        set fmax [expr floor($fmax * 100) / 100]
        post_message "  Fmax: $fmax"
    } else {
        post_message -type warning "No slack found for clock $clkname - assuming 10 GHz."
        set fmax $unused_clk_fmax
    }

    return [list $fmax $clkname]
}

# Returns [k_fmax fmax1 k_clk_name]
proc get_kernel_clks_and_fmax { k_clk_name recovery_multicycle iteration} {
    set result [list]
    # Read in the achieved fmax
    post_message "Calculating maximum fmax..."
    set x [ get_fmax_from_report $k_clk_name 1 $recovery_multicycle $iteration]
    set fmax1 [ lindex $x 0 ]
    set k_clk_name [ lindex $x 1 ]

    # The maximum is determined by both the kernel-clock and the double-pumped clock
    set k_fmax $fmax1
    return [list $k_fmax $fmax1 $k_clk_name]
}


##############################################################################
##############################       MAIN        #############################
##############################################################################

post_message "Project name: $project_name"
post_message "Revision name: $revision_name"

load_package design

##### LOOP START #####
while {$setup_timing_violation == 1 && $iteration <= 5} {
    post_message "Adjusting PLL iteration: $iteration"

  # Open Quartus project
  project_open $project_name -revision $revision_name
  design::load_design -writeable -snapshot final
  load_report $revision_name

  # adjust PLL settings
  set k_clk_name_full   $k_clk_name

  # Process arguments.
  set fmax1 unknown
  set k_fmax -1

  # get device speedgrade
  set device_family [get_global_assignment -name FAMILY]
  post_message "Device family name is $device_family"
  set part_name [get_global_assignment -name DEVICE]
  post_message "Device part name is $part_name"
  set report [report_part_info $part_name]
  regexp {Speed Grade.*$} $report speedgradeline
  regexp {(\d+)} $speedgradeline speedgrade
  if { $speedgrade < 1 || $speedgrade > 8 } {
    post_message "Speedgrade is $speedgrade and not in the range of 1 to 8"
    post_message "Terminating post-flow script"
    return TCL_ERROR
  }
  post_message "Speedgrade is $speedgrade"

  if {![info exists recovery_multicycle] } {
    # set up family specific parameters
    if { $device_family == "Agilex" || $device_family == "Agilex 7" || $device_family == "Agilex 5" } {
      # changes made to the multicycle path here need to also be reflected in the multicycle value in top_post.sdc
      set recovery_multicycle 16.0
    } else {
      post_message "Unsupported device family: $device_family"
      return TCL_ERROR
    }
  }

  # Logic to find Fmax
  if {$k_fmax == -1} {
      set x [get_kernel_clks_and_fmax $k_clk_name $recovery_multicycle $iteration]
      set k_fmax       [ lindex $x 0 ]
      set fmax1        [ lindex $x 1 ]
      set k_clk_name_full   [ lindex $x 2 ]
  }

  post_message "Kernel Fmax determined to be $k_fmax";

  design::unload_design
  # Load post-fit atom netlist
  set refclk_cache "kernel_pll_refclk_freq.txt"
  if { [catch {read_atom_netlist -type cmp} bummer] } {
    post_message "Post-fit netlist not found. Please run quartus_fit."
    post_message $bummer
    return TCL_ERROR
  # ERROR
  }

  set kernel_pll_name [find_kernel_pll_in_design $pll_search_string]

  # Get the IOPLL node
  if { [catch {set node [get_atom_node_by_name -name $kernel_pll_name]} ] } {
    post_message "IOPLL not found: $kernel_pll_name"
    list_plls_in_design
    return TCL_ERROR
    # ERROR
  }

  # Check whether the PLL atom type is supported
  set atom_type [get_atom_node_info -key ENUM_ATOM_TYPE -node $node]
  if {($atom_type ne "TENNM_PH2_IOPLL")} {
    post_message "IOPLL found, but the atom type $atom_type is not supported"
    return TCL_ERROR
  }

  # Get the refclk frequency from the IOPLL node
  # Using the netlist's refclk frequency gives us a santity check.
  # modify by pxx
  set refclk_freq_bin  [get_atom_node_info -key REF_CLK_0_FREQ -node $node]
  set refclk [expr "0b$refclk_freq_bin"]
  set refclk_mhz [expr {$refclk / 1000000.0}]
  set fh [open $refclk_cache "w"]
  puts $fh $refclk
  close $fh
  post_message "PLL reference clock frequency:"
  post_message "  $refclk_mhz mHz"

  set actual_kernel_clk [get_nearest_achievable_frequency $k_fmax $refclk_mhz $device_family $speedgrade]
  post_message "Desired kernel_clk frequency:"
  post_message "  $k_fmax MHz"
  if {$actual_kernel_clk != "TCL_ERROR"} {
    post_message "Actual kernel_clk frequency:"
    post_message "  $actual_kernel_clk MHz"
  } else {
    error "Error! Could not dial PLL back enough to meet the kernel frequency $k_fmax"
  }

  # Do changes for current revision (either base or import revision)
  set success [adjust_iopll_frequency_in_postfit_netlist $revision_name $kernel_pll_name $device_family $speedgrade $actual_kernel_clk]
  if {$success == "TCL_OK"} {
    post_message "IOPLL settings adjusted successfully for current revision"
  }
  write_atom_netlist -file abc
  post_message "Updated atom cdb"
  design::unload_design
  project_close

  # A little report
  project_open $project_name -revision $revision_name
  load_report $revision_name

  post_message "Generating acl_quartus_report.txt"
  set outfile   [open "acl_quartus_report.txt" w]
  set aluts_l   [regsub -all "," [get_fitter_resource_usage -alut] "" ]
  if {[catch {set aluts_m [regsub -all "," [get_fitter_resource_usage -resource "Memory ALUT usage"] "" ]} result]} {
    set aluts_m 0
  }
  if { [string length $aluts_m] < 1 || ! [string is integer $aluts_m] } {
    set aluts_m 0
  }
  set aluts     [expr $aluts_l + $aluts_m]
  set registers [get_fitter_resource_usage -reg]
  set logicutil [get_fitter_resource_usage -utilization]
  set io_pin    [get_fitter_resource_usage -io_pin]
  set dsp       [get_fitter_resource_usage -resource "*DSP*"]
  set mem_bit   [get_fitter_resource_usage -mem_bit]
  set m9k       [get_fitter_resource_usage -resource "M?0K*"]

  puts $outfile "ALUTs: $aluts"
  puts $outfile "Registers: $registers"
  puts $outfile "Logic utilization: $logicutil"
  puts $outfile "I/O pins: $io_pin"
  puts $outfile "DSP blocks: $dsp"
  puts $outfile "Memory bits: $mem_bit"
  puts $outfile "RAM blocks: $m9k"
  puts $outfile "Actual clock freq: $actual_kernel_clk"
  puts $outfile "Kernel fmax: $k_fmax"
  puts $outfile "1x clock fmax: $fmax1"

  # Highest non-global fanout signal
  set result [find_report_panel_row "Fitter||Place Stage||Fitter Resource Usage Summary" 0 equal "Highest non-global fan-out"]
  if {[lindex $result 0] < 0} {error "Error: Could not find highest non-global fan-out (error $retval)"}
  set high_fanout_signal_fanout_count [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col 1]
  puts $outfile "Highest non-global fanout: $high_fanout_signal_fanout_count"

  close $outfile
  # End little report
  # Preserve original sta report (only for first adjust PLL iteration)
  if { $iteration == 1 } {file copy -force output_files/$revision_name.sta.rpt output_files/$revision_name.sta-orig.rpt}

  # delete STA violation report files from previous iterations
  file delete {*}[glob -nocomplain $revision_name.failing_clocks.rpt]
  file delete {*}[glob -nocomplain $revision_name.failing_paths.rpt]

  # Re-run STA
  post_message "Launching STA"
  if {[catch {execute_module -tool sta -args "--report_script=dla_failing_clocks.tcl --force_dat"} result]} {
    post_message -type error "Error! $result"
    exit 2
  }
  
  set setup_timing_violation 0
  set filename "$revision_name.failing_clocks.rpt"
  if {[catch {open $filename r} fid]} {
    post_message "No timing violations found"
  } else {
    while {[gets $fid line] != -1} {
      regexp {.* Setup .*$} $line setupline
      if {![info exists setupline]} {
        regexp {.* Recovery .*$} $line setupline
      }
      if {[info exists setupline]} {
        if { $device_family == "Agilex 5" } {
          regexp {.*dla_pll_0.*$} $setupline outclkline
        }
        if {[info exists outclkline]} {
          post_message "Timing violation on kernel clock found"
          set setup_timing_violation 1
          unset outclkline
        }
        unset setupline
      }
    }
  close $fid
  }
  incr iteration
  project_close
}

##### LOOP END #####
