# Source the library - use path relative to this script file
# Handle both [info script] and $argv0 for different Tcl environments
if {[info exists ::argv0] && $::argv0 ne ""} {
    set script_path $::argv0
} else {
    set script_path [info script]
}

# Get the absolute path to handle relative script paths
set script_dir [file dirname [file normalize $script_path]]


# Printing usage process
proc print_usage {} {
  puts "system_console --script=system_console_script.tcl \[OPTION]\n
  Options:

    help, -help                 Print a usage message

    Sequential IP Parameters
    --arch                      Path to architecture file
    --ip_performance            IP Performance testing (inclusive of input and output streaming IP)
    --core_ip_performance       Core IP Performance testing
    --functional                Functional inference
    --online_reconfiguration    Optional: Path to MIF directory for online reconfiguration
    --input_size                Size of graph input after layout transform in bytes (required for layout transform writeback)
    --num_inferences            Number of inferences
    --input                     Input file path
    --output_shape              Output shape of graph in format: \[C H W]

    Spatial IP Parameters
    --spatial                   Spatial inference
    --input                     Input file path
    --input_shape               Input shape of graph as a 2D or 3D array
    --output_shape              Output shape of graph as a 2D or 3D array"
  
    Common Parameters
    --jtag_path                 Optional: Glob path used to select used jtag path. Should generally be of the format "/devices/<name>/*jtag*" to match both master and issp services
  exit 1
}

# Parse the CVECTOR from the architecture file
proc parse_cvec {arch_path} {
  set arch_file [open $arch_path r]
  set arch_data [read $arch_file]
  close $arch_file

  # Extract the CVEC line
  set cvec_value [lindex [regexp -inline {c_vector\s*:\s*([^\n]+)} $arch_data] 1]

  if {$cvec_value eq ""} {
    puts "Error: Unable to find CVEC in architecture file."
    exit 1
  }

  # Return the CVEC value
  return $cvec_value
}

# Check if layout transform writeback is enabled in the architecture file
proc check_layout_transform_writeback_enabled {arch_path} {
  set arch_file [open $arch_path r]
  set arch_data [read $arch_file]
  close $arch_file

  # Look for enable_layout_transform_writeback line
  set writeback_match [regexp -inline {enable_layout_transform_writeback\s*:\s*([^\n]+)} $arch_data]

  if {[llength $writeback_match] > 0} {
    set writeback_value [string trim [lindex $writeback_match 1]]
    # Check if the value is "true"
    if {$writeback_value eq "true"} {
      return 1
    }
  }

  # Return false if line doesn't exist or is not set to true
  return 0
}

# This process handles parsing of the arguments to the script
proc parse_args {argc argv} {

  # Initialize variables with default values
  set ip_performance 0
  set core_ip_performance 0
  set functional 0
  set num_inferences 0
  set output_shape ""
  set input_file_name ""
  set arch_path ""
  set online_reconfiguration_path ""
  set online_reconfiguration 0
  set cvec 0
  set enable_layout_transform_writeback 0
  set input_size 0
  set C 0
  set H 0
  set W 0
  set spatial 0
  set input_shape ""
  set output_size ""
  set jtag_path "*"

  # Parse command-line arguments
  for {set i 0} {$i < $argc} {incr i} {
    set arg [lindex $argv $i]

    if {[string match --*=* $arg]} {
      # Handle --key=value format
      set key [string range $arg 2 [expr {[string first "=" $arg] - 1}]]
      set value [string range $arg [expr {[string first "=" $arg] + 1}] end]

      switch -- $key {
        ip_performance {
          set ip_performance 1
        }
        core_ip_performance {
          set core_ip_performance 1
        }
        functional {
          set functional 1
        }
        num_inferences {
          set num_inferences $value
        }
        input {
          set input_file_name $value
        }
        arch {
            set arch_path $value
        }
        output_shape {
          # Capture the entire output_shape argument
          if {[string match {\[*} $value]} {
            while {![string match {*\]} $value]} {
              incr i
              append value " [lindex $argv $i]"
            }
            set output_shape $value
          }
        }
        online_reconfiguration {
          set online_reconfiguration_path $value
          set online_reconfiguration 1
        }
        input_size {
          set input_size $value
        }
        input_shape {
          # Capture the entire input_shape argument
          if {[string match {\[*} $value]} {
            while {![string match {*\]} $value]} {
              incr i
              append value " [lindex $argv $i]"
            }
            set input_shape $value
          }
        }
        spatial {
          set spatial 1
        }
        jtag_path {
          set jtag_path $value
        }
        default {
          print_usage
          exit 1
        }
      }
    } else {
      # Handle --flag format
      switch -- $arg {
        --ip_performance {
          set ip_performance 1
        }
        --core_ip_performance {
          set core_ip_performance 1
        }
        --functional {
          set functional 1
        }
        --num_inferences {
          incr i
          set num_inferences [lindex $argv $i]
        }
        --input {
          incr i
          set input_file_name [lindex $argv $i]
        }
        --arch {
          incr i
          set arch_path [lindex $argv $i]
        }
        --output_shape {
          incr i
          set output_shape [lindex $argv $i]
          # Capture the entire output_shape argument
          if {[string match {\[*} $output_shape]} {
            while {![string match {*\]} $output_shape]} {
              incr i
              append output_shape " [lindex $argv $i]"
            }
          }
        }
        --input_shape {
          incr i
          set input_shape [lindex $argv $i]
          # Capture the entire input_shape argument
          if {[string match {\[*} $input_shape]} {
            while {![string match {*\]} $input_shape]} {
              incr i
              append input_shape " [lindex $argv $i]"
            }
          }
        }
        --online_reconfiguration {
          incr i
          set online_reconfiguration_path [lindex $argv $i]
          set online_reconfiguration 1
        }
        --input_size {
          incr i
          set input_size [lindex $argv $i]
        }
        --spatial {
          set spatial 1
        }
        --jtag_path {
          incr i
          set jtag_path [lindex $argv $i]
        }
        default {
          puts "ERROR: Unknown argument '$arg'\n"
          print_usage
          exit 1
        }
      }
    }
  }


  # Spatial flow parses the input and output tensor sizes
  if {$spatial == 1} {
    # Spatial always uses BFP16
    set spatial_data_bytes 2

    if {$output_shape eq ""} {
      puts "ERROR: Output shape is required for spatial inference. The output shape can be found in the reports folder of the IP directory."
      print_usage
      exit 1
    } else {
      set output_shape [string trim $output_shape {\[\]}]
      set output_shape [string map {, " "} $output_shape]
      set components [split $output_shape " "]
      if {[llength $components] == 3} {
        set CO [lindex $components 0]
        set HO [lindex $components 1]
        set WO [lindex $components 2]
        if {$CO eq "" || $HO eq "" || $WO eq ""} {
          puts "ERROR: Unable to parse output shape"
          print_usage
          exit 1
        }
      } elseif {[llength $components] == 2} {
        set CO 1
        set HO [lindex $components 0]
        set WO [lindex $components 1]
        if {$CO eq "" || $HO eq "" || $WO eq ""} {
          puts "ERROR: Unable to parse output shape"
          print_usage
          exit 1
        }
      } else {
        puts "ERROR: Expecting output shape as 2D or 3D array. Unable to parse output shape."
        print_usage
        exit 1
      }

      set output_size [expr {$CO * $HO * $WO * $spatial_data_bytes}]
    }

    if {$input_shape eq ""} {
      puts "ERROR: Input shape is required for spatial inference. The input shape can be found in the reports folder of the IP directory."
      print_usage
      exit 1
    } else {
      set input_shape [string trim $input_shape {\[\]}]
      set input_shape [string map {, " "} $input_shape]
      set components [split $input_shape " "]
      if {[llength $components] == 3} {
        set CI [lindex $components 0]
        set HI [lindex $components 1]
        set WI [lindex $components 2]
        if {$CI eq "" || $HI eq "" || $WI eq ""} {
          puts "ERROR: Unable to parse input shape"
          print_usage
          exit 1
        }
      } elseif {[llength $components] == 2} {
        set CI 1
        set HI [lindex $components 0]
        set WI [lindex $components 1]
        if {$CI eq "" || $HI eq "" || $WI eq ""} {
          puts "ERROR: Unable to parse input shape"
          print_usage
          exit 1
        }
      } else {
        puts "ERROR: Expecting input shape as 2D or 3D array. Unable to parse input shape."
        print_usage
        exit 1
      }

      set input_size [expr {$CI * $HI * $WI * $spatial_data_bytes}]
    }
  }

  if {$online_reconfiguration_path eq "" & $online_reconfiguration == 1} {
    puts "Path to parameter ROM directory is empty\n"
    print_usage
    exit 1
  }

  # Ensure online reconifguration is not attempted
  if {$online_reconfiguration == 0 & $spatial == 0} {
    # Remove brackets and split the output_shape into components
    if {$output_shape eq ""} {
      print_usage
      exit 1
    } else {
      set output_shape [string trim $output_shape {\[\]}]
      set output_shape [string map {, " "} $output_shape]
      set components [split $output_shape " "]
      if {[llength $components] == 3} {
        set C [lindex $components 0]
        set H [lindex $components 1]
        set W [lindex $components 2]
        if {$C eq "" || $H eq "" || $W eq ""} {
          print_usage
          exit 1
        }
      } else {
        print_usage
        exit 1
      }
    }

    # Ensure arch file path exists
    if {$arch_path eq ""} {
      print_usage
      exit 1
    } elseif {![file exists $arch_path]} {
      puts "Error: The arch file '$arch_path' does not exist."
      exit 1
    }

    set cvec [parse_cvec $arch_path]
    set arch_name [file tail $arch_path]
    puts "c_vector from $arch_name: $cvec"

    # Check if layout transform writeback is enabled
    set enable_layout_transform_writeback [check_layout_transform_writeback_enabled $arch_path]
    puts "enable_layout_transform_writeback: $enable_layout_transform_writeback"
    if {$enable_layout_transform_writeback} {
      if {$input_size == 0} {
        puts "Error: --input_size must be provided and greater than 0 when layout transform writeback is enabled in the architecture file. This can be found in the output of dla_compiler."
        print_usage
        exit 1
      }
    }
  }

  # Ensure input file path exists
  if {$input_file_name eq ""} {
    puts "Error: input file path is empty\n"
    print_usage
    exit 1
  } elseif {![file exists $input_file_name]} {
    puts "Error: The input file '$input_file_name' does not exist."
    exit 1
  }

  return [list $ip_performance $core_ip_performance $functional $num_inferences $C $H $W $input_file_name $cvec $online_reconfiguration_path $enable_layout_transform_writeback $input_size $spatial $output_size $jtag_path]
}

# Main Function
proc main {argc argv} {
  global script_dir
  # Check if the script should display help information
  if {$argc > 0} {
    set firstArg [lindex $argv 0]
    if {[string equal $firstArg "help"] || [string equal $firstArg "-help"]} {
      print_usage
    }
  }

  # Parse script arguments
  set parsed_args [parse_args $argc $argv]
  lassign $parsed_args ip_performance core_ip_performance functional num_inferences C H W input_file_name cvec online_reconfiguration_path enable_layout_transform_writeback input_size spatial output_size jtag_path

  # Spatial flow calculate num_inferences based on input file size and input tensor size
  if { $spatial == 1 } {
    set lib_path [file join $script_dir include spatial_system_console_lib.tcl]
    source $lib_path
    spatial_main_functional $input_file_name $input_size $output_size $jtag_path
    exit 0
  }

  set lib_path [file join $script_dir include system_console_lib.tcl]
  source $lib_path

  # Performance and functional testing calls
   if { $online_reconfiguration_path ne "" && ($functional == 1 || $core_ip_performance == 1 || $ip_performance == 1) } {
    puts "Error: Online reconfiguration is not allowed with one of the performance or functional flags set to 1."
    print_usage
    exit 1
  }
  # Performance and functional testing calls
  if {$ip_performance && $core_ip_performance} {
    puts "ERROR: --ip_performance and --core_ip_performance cannot be set at the same time."
    exit 1
  }
  if {($ip_performance || $core_ip_performance) && $functional} {
    puts "ERROR: --ip_performance or --core_ip_performance cannot be set with --functional at the same time."
    exit 1
  } elseif {$functional} {
    if {$num_inferences == 0} {
      puts "Number of inferences must be greater than 0."
      exit 1
    }
    # Functional script logic contained within "main_functional" process in library
    main_functional $num_inferences $input_file_name $C $H $W $cvec $enable_layout_transform_writeback $input_size $jtag_path
  } elseif {$ip_performance || $core_ip_performance} {
    if {$ip_performance} {
      puts "Number of inferences is always set to 32 in IP performance testing for optimal results\n"
    } else {
      puts "Number of inferences is always set to 1 in core IP performance testing for optimal results\n"
    }

    # Performance script logic contained within "main_functional" process in library
    main_performance $input_file_name $C $H $W $core_ip_performance $cvec $enable_layout_transform_writeback $input_size $jtag_path
  } elseif {$online_reconfiguration_path ne ""} {
    main_online_reconfig $online_reconfiguration_path $jtag_path
  } else {
    # Neither performance nor functional test was passed as an argument
    print_usage
  }
}

main $argc $argv