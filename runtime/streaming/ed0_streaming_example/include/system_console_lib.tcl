# This design example only supports an AXI Width of 128 bits = 16 bytes
variable AXI_STREAM_DATA_WIDTH_BYTES 16
# This design example has a limit to ingress on-chip memory size in bytes
variable INGRESS_ON_CHIP_MEMORY_SIZE_BYTES 524288
# This design example has a limit to egress on-chip memory size in bytes
variable EGRESS_ON_CHIP_MEMORY_SIZE_BYTES 131072

# DDR-Free ED Address Map Constants
variable DLA_IP_0_CSR_ADDR 0x00038000
variable INGRESS_SGDMA_CSR_ADDR 0x00030000
variable INGRESS_SGDMA_DESCRIPTOR_ADDR 0x00030020
variable EGRESS_SGDMA_CSR_ADDR 0x00030040
variable EGRESS_SGDMA_DESCRIPTOR_ADDR 0x00030060

variable EXTERNAL_MEMORY_OFFSET 0x0

# Service paths
variable claimed_issp -1


# Process to validate arguments to script
proc validate_args {input_file num_inferences} {
  global INGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global AXI_STREAM_DATA_WIDTH_BYTES
  # Make sure user requested number of inferences is valid
  if {$num_inferences < 0} {
    puts "Number of inferences must be greater than 0."
    exit 1
  }

  # Get the size of the file in bytes
  set file_size [file size $input_file]

  # Make sure the input file is aligned to the mSGDMA/FPGA AI Suite stream width
  if {[expr {$file_size % $AXI_STREAM_DATA_WIDTH_BYTES}] != 0} {
      puts "Error: this design example only supports input sizes aligned to 128 bits. Please pad accordingly."
      exit 1
  }

  # Format input file size into hex representation
  set file_size_hex [format "0x%X" $file_size]

  puts "Input file: $input_file"
  puts "Input size: $file_size_hex bytes"

  return $file_size
}


# Calculate the packed egress byte count after the AXI-to-Avalon bridge strips
# invalid bytes.  Each output element is FP16 (2 bytes).  The bridge packs only
# valid bytes and zero-pads the final beat to 128-bit (AXI_STREAM_DATA_WIDTH)
# alignment.
proc calculate_egress_bytes {C H W} {
  global EGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global AXI_STREAM_DATA_WIDTH_BYTES

  set valid_bytes [expr {$H * $W * $C * 2}]
  set aligned_bytes [expr {(($valid_bytes + $AXI_STREAM_DATA_WIDTH_BYTES - 1) / $AXI_STREAM_DATA_WIDTH_BYTES) * $AXI_STREAM_DATA_WIDTH_BYTES}]

  if {$aligned_bytes <= 0} {
    puts "Error with egress byte calculation. Please check your output shape size arguments (C H W)"
    exit 1
  }

  if {$aligned_bytes > $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES} {
    puts "Output inference results is too large to fully fit into on-chip memory of size $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES bytes. Output inference results will be partitioned and transferred partially.\n"
  }

  set aligned_bytes_hex [format "0x%X" $aligned_bytes]
  puts "Expected number of packed egress bytes (128-bit aligned): $aligned_bytes_hex bytes"

  return $aligned_bytes
}


# Initiate reset via source/probe IP
proc assert_reset {jtag_path} {
  global claimed_issp
  set issp_index 0
  if {$claimed_issp == -1} {
    set issps [get_service_paths issp]
    set issp [lindex $issps [lsearch -glob $issps $jtag_path]]
    if {$issp == ""} {
      puts "No issp path matching $jtag_path found. Exiting"
      exit 1
    }
    puts "Using path $issp for issp"
    set claimed_issp [claim_service issp $issp mylib]
  }
  set source_data 0x0
  issp_write_source_data $claimed_issp $source_data
  set source_data 0x1
  issp_write_source_data $claimed_issp $source_data
}

# Claim master service
proc claim_master {jtag_path} {
  set mpaths [get_service_paths master]
  set mpath [lindex $mpaths [lsearch -glob $mpaths $jtag_path]]
  if {$mpath == ""} {
    puts "No master path matching $jtag_path found. Exiting"
    exit 1
  }
  puts "Using path $mpath for master"
  set master_path [claim_service master $mpath ""]
  return $master_path
}


# Initializing coreDLA (register map: fpga/csr/rtl/inc/dla_csr_constants.svh)
proc initialize_coredla {master_path enable_layout_transform_writeback input_size} {
  global DLA_IP_0_CSR_ADDR
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR
  global EXTERNAL_MEMORY_OFFSET

  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x220}]
  master_write_32 $master_path $csr_register_addr 0

  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x204}]
  master_write_32 $master_path $csr_register_addr 0

  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x200}]
  master_write_32 $master_path $csr_register_addr 3

  if {$enable_layout_transform_writeback} {
    # need to write to writeback registers,
    # 1 - Base Address
    set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x230}]
    master_write_32 $master_path $csr_register_addr $EXTERNAL_MEMORY_OFFSET

    # 2 - frame size
    set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x234}]
    master_write_32 $master_path $csr_register_addr $input_size

    # 3 - range
    set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x238}]
    master_write_32 $master_path $csr_register_addr [expr {$input_size * 5}]
  }

  # Writing 0x1 to this register will instruct DLA to accept input until register is cleared
  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x22c}]
  master_write_32 $master_path $csr_register_addr 1

  # Reset egress SGDMA
  set csr_register_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x2

  # Reset ingress SGDMA
  set csr_register_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x2
}


# Stop both ingress/egress SGDMAs by writing 0x20 to CSRs
proc stop_sgdmas {master_path} {
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR
  # Stop SGDMA
  set csr_register_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x20

  # Stop ingress SGDMA
  set csr_register_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x20
}


# Start both ingress/egress SGDMAs by writing 0x0 to CSRs
proc start_sgdmas {master_path} {
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR
  # Start egress SGDMA
  set csr_register_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x00

  # Start ingress SGDMA
  set csr_register_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x00
}


proc stage_input {input_file master_path} {
  # Initializing rom with input image
  master_write_from_file $master_path $input_file 0x00200000
}


# Adding descriptor to egress streaming mSGDMA
proc queue_egress_descriptor {master_path size} {
  global EGRESS_SGDMA_DESCRIPTOR_ADDR

  # Destination addr
  set csr_register_addr [expr {$EGRESS_SGDMA_DESCRIPTOR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x00280000

  # Length should be 128 bit aligned
  set csr_register_addr [expr {$EGRESS_SGDMA_DESCRIPTOR_ADDR + 0x8}]
  master_write_32 $master_path $csr_register_addr $size

  # Queue descriptor (Writing 0x8000_0000)
  set csr_register_addr [expr {$EGRESS_SGDMA_DESCRIPTOR_ADDR + 0xc}]
  master_write_32 $master_path $csr_register_addr 0x80000000
}


# Adding descriptor to ingress streaming mSGDMA
proc queue_ingress_descriptor {master_path size} {
  global INGRESS_SGDMA_DESCRIPTOR_ADDR

  # Source addr
  master_write_32 $master_path $INGRESS_SGDMA_DESCRIPTOR_ADDR 0x00200000

  # Transfer length in bytes (input size)
  set csr_register_addr [expr {$INGRESS_SGDMA_DESCRIPTOR_ADDR + 0x8}]
  master_write_32 $master_path $csr_register_addr $size

  # Queue descriptor
  set csr_register_addr [expr {$INGRESS_SGDMA_DESCRIPTOR_ADDR + 0xc}]
  master_write_32 $master_path $csr_register_addr 0x80000000
}


# Read output from on-chip memory
proc read_output {master_path output_file size} {
  master_read_to_file $master_path $output_file 0x00280000 $size
}


# Read output from on-chip memory
proc check_inference_count {master_path iteration} {
  global DLA_IP_0_CSR_ADDR
  # Completion counter assert from index
  set completion_counter_assert 0x00000000
  set completion_counter_assert [expr {$completion_counter_assert + $iteration}]
  set formatted_counter_assert [format "0x%08X" $completion_counter_assert]

  # Check what completion counter CSR in HW is set to
  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x224}]
  set completion_counter_result [master_read_32 $master_path $csr_register_addr 1]
  puts "Completion counter from HW: $completion_counter_result"
  if {$completion_counter_result != $formatted_counter_assert} {
    error "Error: completion counter should be equal to $formatted_counter_assert but instead is $completion_counter_result"
  }
}


# This process handles creating a binary file from input partition data
proc create_input_bin {partition_data index} {
  set temp_file "chunk_$index.bin"
  set temp_fh [open $temp_file "wb"]
  fconfigure $temp_fh -translation binary
  puts -nonewline $temp_fh $partition_data
  close $temp_fh
  return $temp_file
}


# This process polls a register and returns if assertion is true within a timeout window
proc poll_register {master_path register_addr register_val_assert} {
  # Set timeout to be 30 seconds (in centi-seconds)
  set timeout_count 3000
  while {$timeout_count > 0} {
    set register_val [master_read_32 $master_path $register_addr 1]
    if {$register_val == $register_val_assert} {
      break
    }
    set timeout_count [expr {$timeout_count - 1}]
    after 10
  }
  if {$timeout_count == 0} {
    puts "Register polling timeout. CSR addr: $register_addr = $register_val \nRegister should be = $register_val_assert"
    exit 1
  }
}


# Read inference counter values to get performance
# There is an assumption here that the clk_ddr is attached to 100MHz
proc get_performance {master_path num_inferences use_core_clock} {
  global DLA_IP_0_CSR_ADDR

  # Used to measure throughput
  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x240}]
  if {$use_core_clock} {
    set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x27c}]
  }
  set active_clk_lo [master_read_32 $master_path $csr_register_addr 1]

  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x244}]
  if {$use_core_clock} {
    set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x280}]
  }
  set active_clk_hi [master_read_32 $master_path $csr_register_addr 1]

  set total_active_clk_count [expr { $active_clk_lo | ($active_clk_hi << 32) }]
  set active_clk_count_per_inference [expr {$total_active_clk_count / $num_inferences}]

  # Used to measure latency
  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x248}]
  set all_active_clk_lo [master_read_32 $master_path $csr_register_addr 1]

  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x24c}]
  set all_active_clk_hi [master_read_32 $master_path $csr_register_addr 1]

  set all_active_clk_count [expr { $all_active_clk_lo | ($all_active_clk_hi << 32) }]
  set all_active_clk_count_per_inference [expr {$all_active_clk_count / $num_inferences}]

  # Core only throughput
  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x27c}]
  set core_active_clk_lo [master_read_32 $master_path $csr_register_addr 1]

  set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x280}]
  set core_active_clk_hi [master_read_32 $master_path $csr_register_addr 1]

  set total_core_active_clk_count [expr { $core_active_clk_lo | ($core_active_clk_hi << 32) }]
  set core_active_clk_count_per_inference [expr {$total_core_active_clk_count / $num_inferences}]

  # Calculate and report total and core clk counts and overall throughput
  set clk_period [expr { 1.0 / 100000000.0 }]
  set final_fps [expr { 1 / ($clk_period * $active_clk_count_per_inference) }]
  set final_latency [expr { 1 / ($clk_period * $all_active_clk_count_per_inference) }]

  puts "Total active clk cycles: $total_active_clk_count"
  puts "Total core active clk cycles (without input and output streamer): $total_core_active_clk_count"
  puts "Final Throughput: $final_fps fps assuming 100MHz clk_ddr"
}


# This checks if the descriptor buffers are full
proc check_descriptor_buffer_full {master_path} {
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR
  set egress_descriptor_status [master_read_32 $master_path $EGRESS_SGDMA_CSR_ADDR 1]
  set ingress_descriptor_status [master_read_32 $master_path $INGRESS_SGDMA_CSR_ADDR 1]

  if {$egress_descriptor_status & 0x4} {
    error "Egress descriptor is full."
  }
  if {$ingress_descriptor_status & 0x4} {
    error "Ingress descriptor is full."
  }
}


# Flip the endianness of each 128-bit (16-byte) chunk in a binary file.
# The egress mSGDMA writes in big-endian order, so the 128-bit words need
# to be byte-reversed to recover the little-endian data the DLA produced.
proc flip_endianness_128bit {input_file output_file} {
  set fh_in [open $input_file "rb"]
  fconfigure $fh_in -translation binary
  set data [read $fh_in]
  close $fh_in

  set len [string length $data]
  set chunk_size 16
  set result ""

  for {set i 0} {$i < $len} {incr i $chunk_size} {
    set chunk [string range $data $i [expr {$i + $chunk_size - 1}]]
    set reversed ""
    for {set j [expr {[string length $chunk] - 1}]} {$j >= 0} {incr j -1} {
      append reversed [string index $chunk $j]
    }
    append result $reversed
  }

  set fh_out [open $output_file "wb"]
  fconfigure $fh_out -translation binary
  puts -nonewline $fh_out $result
  close $fh_out
}


# Convert an endian-corrected binary file of FP16 values to a text file
# with one decimal float per line.  Tcl has no native half-precision support,
# so we manually decode IEEE 754 binary16.
proc bin_to_fp16_txt {input_file output_file} {
  set fh_in [open $input_file "rb"]
  fconfigure $fh_in -translation binary
  set data [read $fh_in]
  close $fh_in

  set len [string length $data]
  set fh_out [open $output_file "w"]

  for {set i 0} {$i < $len} {incr i 2} {
    binary scan [string range $data $i [expr {$i + 1}]] su half
    set sign [expr {($half >> 15) & 0x1}]
    set exp  [expr {($half >> 10) & 0x1F}]
    set mant [expr {$half & 0x3FF}]

    if {$exp == 0} {
      if {$mant == 0} {
        set val 0.0
      } else {
        set val [expr {pow(-1, $sign) * pow(2, -14) * ($mant / 1024.0)}]
      }
    } elseif {$exp == 31} {
      if {$mant == 0} {
        set val [expr {$sign ? "-inf" : "inf"}]
      } else {
        set val "nan"
      }
    } else {
      set val [expr {pow(-1, $sign) * pow(2, $exp - 15) * (1.0 + $mant / 1024.0)}]
    }

    puts $fh_out $val
  }

  close $fh_out
}


# Called by main process for functional run
proc main_functional {num_inferences input_file C H W cvec enable_layout_transform_writeback input_size jtag_path} {
  global INGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global EGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global AXI_STREAM_DATA_WIDTH_BYTES
  global INGRESS_SGDMA_DESCRIPTOR_ADDR
  global EGRESS_SGDMA_DESCRIPTOR_ADDR
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR
  global DLA_IP_0_CSR_ADDR


  puts "Running functional inference on DDR-Free Design Example"
  puts "________________________________________________________________________________\n"
  puts "Output shape of graph: \[$C $H $W]"

  # Validating script arguments. Return input file size in bytes
  set file_size [validate_args $input_file $num_inferences]
  set file_size_hex [format "0x%X" $file_size]

  # Make sure the input file can fit into on-chip memory
  if {$file_size > $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES} {
    puts "Input file '$input_file' is too large to fully fit into on-chip memory of size $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES bytes. Input file will be partitioned and transferred partially.\n"
  }

  # Calculate packed egress byte count (bridge strips invalid bytes)
  set output_streamer_transfers [calculate_egress_bytes $C $H $W]

  puts "Number of inferences: $num_inferences"

  # Claim service path to System Console
  set master_path [claim_master $jtag_path]

  puts "\n________________________________________________________________________________"
  puts "                    STARTING FPGA AI SUITE INFERENCE                            "
  puts "________________________________________________________________________________\n"

  # Assert resetn using source/probe IP
  assert_reset $jtag_path
  # Initialize coreDLA's CSR registers
  initialize_coredla $master_path $enable_layout_transform_writeback $input_size

  # Open the input binary file for reading
  for {set i 1} {$i <= $num_inferences} {incr i} {
    # Open input file per iteration due to the potential partioning in the case where input file > INGRESS_ON_CHIP_MEMORY_SIZE_BYTES.
    set input_fh [open $input_file "rb"]
    fconfigure $input_fh -translation binary

    # Create an output file every iteration of inferences
    set combined_fh [open "output$i.bin" "wb"]
    fconfigure $combined_fh -translation binary

    # Logic to ensure input image can fully fit into ingress on-chip memory
    # If not, must partition input data into chunks at a time. This allows us to queue
    # descriptors for partial input sizes.
    set num_input_partition [expr {int(($file_size + $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES - 1) / $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES)}]
    for {set j 0} {$j < $num_input_partition} {incr j} {
      set offset [expr {$j * $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES}]
      set size [
        expr {($file_size - $offset) < $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES ? ($file_size - $offset) : $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES}
      ]

      # Seek to the offset and read the chunk
      # Need to catch an error if offset > file size
      if {[catch {seek $input_fh $offset} err]} {
        puts "Error seeking to offset $offset: $err"
        close $input_fh
        exit 1
      }

      # Begin partioning the input data to INGRESS_ON_CHIP_MEMORY_SIZE_BYTES chunks
      set partition_data [read $input_fh $size]
      set partition_data_file_name [create_input_bin $partition_data $j]
      stage_input $partition_data_file_name $master_path
      queue_ingress_descriptor $master_path $size
      file delete $partition_data_file_name

      # Poll SGDMA register to check if input data streaming is complete
      set sgdma_csr_assert 0x00000002
      poll_register $master_path $INGRESS_SGDMA_CSR_ADDR $sgdma_csr_assert
    }

    close $input_fh

    # Logic to ensure output inference results can fully fit into egress on-chip memory
    # If not, must partition output data into chunks at a time. This allows us to queue
    # descriptors for partial output sizes.
    set num_output_partition [expr {int(($output_streamer_transfers + $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES - 1) / $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES)}]
    for {set j 0} {$j < $num_output_partition} {incr j} {
      set offset [expr {$j * $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES}]
      set size [
        expr {($output_streamer_transfers - $offset) < $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES ? ($output_streamer_transfers - $offset) : $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES}
      ]
      # Queue chunks of EGRESS_ON_CHIP_MEMORY_SIZE_BYTES at a time to ensure a fit in egress on-chip memory
      queue_egress_descriptor $master_path $size

      # Poll SGDMA register to check if output data streaming is complete
      set sgdma_csr_assert 0x00000002
      poll_register $master_path $EGRESS_SGDMA_CSR_ADDR $sgdma_csr_assert

      # Write a partition of the inference result to the partition file
      set output_file "partition_out_$j.bin"
      read_output $master_path $output_file $size

      # Open partioned output inference result
      set bin_fh [open $output_file "rb"]
      fconfigure $bin_fh -translation binary
      set bin_data [read $bin_fh]

      # Append smaller partition of inference result to larger output$i.bin file for inference iteration
      puts -nonewline $combined_fh $bin_data
      close $bin_fh
      file delete $output_file
    }
    # Ensure inference count has gone up
    check_inference_count $master_path $i
    close $combined_fh

    # Endian-flip and convert to FP16 text
    set result_idx [expr {$i - 1}]
    flip_endianness_128bit "output$i.bin" "result${result_idx}.bin"
    bin_to_fp16_txt "result${result_idx}.bin" "result${i}.txt"
  }

  # Concatenate per-inference text files into a single result.txt
  set fh_result [open "result.txt" "w"]
  for {set i 1} {$i <= $num_inferences} {incr i} {
    set fh_part [open "result${i}.txt" "r"]
    puts -nonewline $fh_result [read $fh_part]
    close $fh_part
  }
  close $fh_result

  get_performance $master_path $num_inferences false

  puts "\n$num_inferences inferences successfully completed"
}


# Called by main process for perfromance testing
proc main_performance {input_file C H W measure_core_ip_throughput cvec enable_layout_transform_writeback input_size jtag_path} {
  global INGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global EGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global AXI_STREAM_DATA_WIDTH_BYTES
  global INGRESS_SGDMA_DESCRIPTOR_ADDR
  global EGRESS_SGDMA_DESCRIPTOR_ADDR
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR
  global DLA_IP_0_CSR_ADDR

  puts "            Running performance testing on DDR-Free Design Example                "
  puts "________________________________________________________________________________\n"
  puts "Output shape of graph = \[$C $H $W]"

  # Used to measure performance
  set num_inferences 32
  if {$measure_core_ip_throughput} {
    # Used to measure core ip performance.
    set num_inferences 1
  }

  # Validating script arguments. Return input file size in bytes
  set file_size [validate_args $input_file $num_inferences]
  set file_size_hex [format "0x%X" $file_size]

  # Make sure the input file can fit into on-chip memory
  if {$file_size > $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES} {
    puts "Input file '$input_file' is too large to fully fit into on-chip memory of size
    $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES bytes.\nThe `system_console_script.tcl` file will
    partition the input file for partial transfers to solve this problem but it should not
    be used for performance testing. Please increase the on-chip memory size for performance
    testing.\n"
    exit 1
  }

  # Calculate packed egress byte count (bridge strips invalid bytes)
  set output_streamer_transfers [calculate_egress_bytes $C $H $W]

  # Claim service path to System Console
  set master_path [claim_master $jtag_path]

  puts "\n________________________________________________________________________________"
  puts "                    STARTING FPGA AI SUITE INFERENCE                            "
  puts "________________________________________________________________________________\n"


  # Assert resetn using source/probe IP
  assert_reset $jtag_path
  # Stage input file into on-chip memory
  stage_input $input_file $master_path
  # Initialize coreDLA's CSR registers
  initialize_coredla $master_path $enable_layout_transform_writeback $input_size
  stop_sgdmas $master_path

  # $num_inferences cannot exceed the descriptor queue FIFO size
  for {set i 1} {$i <= $num_inferences} {incr i} {
    check_descriptor_buffer_full $master_path
    # Queue egress descriptor into mSGDMA
    queue_egress_descriptor $master_path $output_streamer_transfers
    # Queue ingress descriptor into mSGDMA
    queue_ingress_descriptor $master_path $file_size
  }

  set start_core_streaming [expr {$DLA_IP_0_CSR_ADDR + 0x284}]
  if {$measure_core_ip_throughput} {
    # write 0 to DLA_DMA_CSR_OFFSET_START_CORE_STREAMING to block core streaming from starting
    master_write_32 $master_path $start_core_streaming 0
  }
  start_sgdmas $master_path
  if {$measure_core_ip_throughput} {
    # wait for data being piped to dma fifo, then start core streaming
    after 1000
    master_write_32 $master_path $start_core_streaming 1
  }

  # Completion counter should increment to 32 inferences
  set completion_count_reg_addr [expr {$DLA_IP_0_CSR_ADDR + 0x224}]
  set completion_count_reg_assert $num_inferences
  poll_register $master_path $completion_count_reg_addr $completion_count_reg_assert

  # Check to see if egress SGDMA has completed writing to egress on-chip memory
  set sgdma_csr_assert 0x00000002
  poll_register $master_path $EGRESS_SGDMA_CSR_ADDR $sgdma_csr_assert


  get_performance $master_path $num_inferences $measure_core_ip_throughput

  # Read output from on-chip memory
  set output_file "output0.bin"
  read_output $master_path $output_file $output_streamer_transfers

  # Endian-flip and convert to FP16 text
  flip_endianness_128bit "output0.bin" "result0.bin"
  bin_to_fp16_txt "result0.bin" "result.txt"

  puts "\n$num_inferences inferences successfully completed"
}


proc process_mif_content {file_path master_path config bias_scale} {
    global DLA_IP_0_CSR_ADDR

    if {![file exists $file_path]} {
      puts "Error: File not found at $file_path"
      exit 1
    }

    # Record the starting time
    set start_time [clock seconds]
    puts "Processing the following mif file: $file_path"
    # Open the file for reading
    set file_id [open $file_path r]

    # Parse the header lines to extract address/data radix
    # Example header of CONFIG:
    # DEPTH = 2049;
    # WIDTH = 64;
    # ADDRESS_RADIX = HEX;
    # DATA_RADIX = HEX;
    # CONTENT
    # Example header of FILTER:
    # DEPTH = 96;
    # WIDTH = 17;
    # ADDRESS_RADIX = HEX;
    # DATA_RADIX = BIN;
    # CONTENT
    set address_radix_hex 0
    set data_radix_hex 0
    set depth 0
    set data_width 0
    while {[gets $file_id line] >= 0} {
      if {[regexp {^((--)|%)} $line]} {
        # Ignore lines that start with -- or %
        continue
      } elseif {[regexp {ADDRESS_RADIX\s*=\s*HEX} $line]} {
        # Check if the ADDRESS_RADIX is HEX
        set address_radix_hex 1
      } elseif {[regexp {DATA_RADIX\s*=\s*HEX} $line]} {
        # Check if the DATA_RADIX is HEX
        set data_radix_hex 1
      } elseif {[regexp {DEPTH\s*=\s*(\d+);} $line match depth_value]} {
        set depth $depth_value
      } elseif {[regexp {WIDTH\s*=\s*(\d+);} $line match width_value]} {
        set data_width $width_value
      }  elseif {[regexp {BEGIN} $line]} {
        # Detect the BEGIN line
        break
      }
    }

    # Config CSR register addr for online reconfiguration
    set csr_config_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x380}]
    # Number of CSR words to send for each MIF address location
    set csr_word_to_send [expr {($data_width - 1) / 32 + 1}]

    # Process the actual content
    while {[gets $file_id line] >= 0} {
      if {[regexp {^((--)|%)} $line]} {
        # Ignore lines that start with -- or %
        continue
      } elseif {[regexp {END} $line]} {
        break
      }
      # puts "line is $line"
      set csr_register_addr [expr {$DLA_IP_0_CSR_ADDR + 0x300}]

      # Extract the address and content part
      if {[regexp {(\w+)\s*:\s*(\w+)} $line match address content]} {
        # Calculate the content length
        set content_length [string length $content]

        # Strip the file name of the suffix
        regexp {(ddrfree.*)\.mif$} $file_path match stem

        # List of bytes to be sent as one word over several CSR writes
        # In the case of filter: this is one cvec worth of filter mantissa plus exponent
        # In the case of bias-scale: this is just one bias and scale
        # In the case of configuration, this is one configuration word
        set update_bytes [list]

        # depending on the data radix,
        # different number of characters are scanned in each iteration
        # We do not scan all the characters into an integer at once,
        # e.g. scan $content "%b" chunk_decimal
        # since that would cause overflow in the target variable
        # We also need to make sure to overwrite the entire "data_width" bits at every MIF address location
        # This is to prevent content from the previous write, which reside in a set of helper registers in the CSR interface,
        # from corrupting the update to the current MIF address.
        set scan_incr 32
        if {$data_radix_hex} {
          # Convert hex content to decimal
          set scan_incr 8
        }
        set csr_word_sent 0

        # In an MIF file, the least significant bit are at the end of the string.
        # For master_write_from_file, we want to place the least significant byte at the beginning of source file.
        for {set i [expr {$content_length - $scan_incr}]} {$i >= 0} {set i [expr {$i - $scan_incr}]} {
          set chunk [string range $content $i [expr {$i + $scan_incr - 1}]]
          set chunk_decimal 0
          # Extract the content in the specified radix
          if {$data_radix_hex} {
            scan $chunk "%x" chunk_decimal
          } else {
            scan $chunk "%b" chunk_decimal
          }
          # Transfer the scanned 32-bit words byte-by-byte into the byte-array.
          for {set j 0} {$j < 4} {incr j} {
            lappend update_bytes [expr {($chunk_decimal >> ($j * 8)) & 0xFF}]
          }
          incr csr_word_sent
        }
         # Handle any remaining characters at the start
        set remaining_tokens [expr {$content_length % $scan_incr}]
        if {$remaining_tokens > 0} {
          set chunk [string range $content 0 [expr {$remaining_tokens - 1}]]
          # Left pad with zeros to make it 32 bits
          set padded_chunk_decimal 0
          if {$data_radix_hex} {
            set padded_chunk [format "%08s" $chunk]
            scan $padded_chunk "%x" padded_chunk_decimal
          } else {
            set padded_chunk [format "%032s" $chunk]
            scan $padded_chunk "%b" padded_chunk_decimal
          }
          # Transfer the scanned 32-bit words byte-by-byte into the byte-array.
          for {set j 0} {$j < 4} {incr j} {
            lappend update_bytes [expr {($padded_chunk_decimal >> ($j * 8)) & 0xFF}]
          }
          incr csr_word_sent
        }
        while {$csr_word_sent < $csr_word_to_send} {
          # Fill the rest of the words with zeros
          lappend update_bytes 0 0 0 0
          incr csr_word_sent
        }
        # Combine writes to adjacent CSR words into a single write
        # Issuing separate master_write_32 is too slow
        master_write_memory $master_path $csr_register_addr $update_bytes

        # Build config CSR word
        # Determine the values for bits 31 and 30
        set bit_31 [expr {$config == 0 ? 1 : 0}]
        set bit_30 [expr {$bias_scale == 1 ? 1 : 0}]
        # Convert the hex address to a decimal number using scan
        set address_decimal 0
        if {$address_radix_hex} {
          scan $address "%x" address_decimal
        } else {
          scan $address "%b" address_decimal
        }
        # Convert the decimal number to a binary string and pad to 16 bits
        set address_bin [format "%016b" $address_decimal]
        set config_word [format "%1b%1b%014b%s" $bit_31 $bit_30 0 $address_bin]
        
        # Convert config word to decimal using scan
        scan $config_word "%b" config_word_decimal
        # Convert decimal to hexadecimal
        set config_word_hex [format "%08X" $config_word_decimal]
        
        # Write config word
        master_write_32 $master_path $csr_config_register_addr "0x$config_word_hex"
        # puts "Completed address: $address"
      }
    }
    puts "Finished processing the following mif file: $file_path"
    # Record the end time
    set end_time [clock seconds]
    set elapsed_time [expr {$end_time - $start_time}]
    puts "Elapsed time: $elapsed_time seconds.\n"

    # Close the file
    close $file_id
}


# Online Reconfiguration Main Function
proc main_online_reconfig {parameter_ram_dir_path jtag_path} {
  puts "\n________________________________________________________________________________________"
  puts "     Online reconfiguration of Paramter ROM with: $parameter_ram_dir_path"
  puts "________________________________________________________________________________________\n"

  # Claim service path to System Console UNCOMMENT
  set master_path [claim_master $jtag_path]
  # set master_path "todo"
  # # If main_online_reconfig is called right after programming the design, then issuing a reset is required.
  assert_reset $jtag_path

  # Parse content of filter, bias/scale mif files and convert to CSR writes
  foreach file [glob -nocomplain -directory $parameter_ram_dir_path "ddrfree_filter_hw_reconfig.mif" "ddrfree_bias_scale_hw_reconfig.mif" "ddrfree_config.mif"] {
    if {[string match "*filter_hw_*.mif" $file]} {
      set config 0
      set bias_scale 0
      process_mif_content $file $master_path $config $bias_scale
    } elseif {[string match "*bias_scale_hw_*.mif" $file]} {
      set config 0
      set bias_scale 1
      process_mif_content $file $master_path $config $bias_scale
    } elseif {[string match "*ddrfree_config.mif" $file]} {
      set config 1
      set bias_scale 0
      process_mif_content $file $master_path $config $bias_scale
    } else {
      puts "Unknown file type: $file"
      exit 1
    }
  }
  # wait for the data to propagate through the system
  after 10
  # Issue another reset to flush out the FIFOs after the configuration memory
  assert_reset $jtag_path
}