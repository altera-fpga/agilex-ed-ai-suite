variable AXI_STREAM_DATA_WIDTH_BYTES 4
variable INGRESS_ON_CHIP_MEMORY_SIZE_BYTES 524288
variable EGRESS_ON_CHIP_MEMORY_SIZE_BYTES 131072

variable INGRESS_SGDMA_CSR_ADDR 0x00000020
variable INGRESS_SGDMA_DESCRIPTOR_ADDR 0x00000040
variable EGRESS_SGDMA_CSR_ADDR 0x00000060
variable EGRESS_SGDMA_DESCRIPTOR_ADDR 0x00000080
variable HW_TIMER_BASE_ADDR 0x00000000
variable HW_TIMER_CLK_FREQ_HZ 300000000

variable claimed_issp -1
variable inference_latencies
array set inference_latencies {}

proc read_hw_timer_us {master_path} {
  global HW_TIMER_BASE_ADDR HW_TIMER_CLK_FREQ_HZ
  set cycles [master_read_32 $master_path $HW_TIMER_BASE_ADDR 1]
  set latency_us [expr {($cycles * 1.0e6) / $HW_TIMER_CLK_FREQ_HZ}]
  return $latency_us
}

proc read_hw_timer_status {master_path} {
  global HW_TIMER_BASE_ADDR
  set status [master_read_32 $master_path [expr {$HW_TIMER_BASE_ADDR + 0x4}] 1]
  return $status
}

proc print_elapsed_time {label elapsed_us} {
  set ms [expr {$elapsed_us / 1000.0}]
  set seconds [expr {$elapsed_us / 1000000.0}]
  if {$seconds < 1.0} {
    puts "$label: [format "%.3f" $ms] ms ([format "%.1f" $elapsed_us] us)"
  } else {
    puts "$label: [format "%.3f" $seconds] s"
  }
}

proc generate_performance_report {report_file num_inferences total_time_us} {
  global inference_latencies

  set fh [open $report_file "w"]

  # Header
  puts $fh "=================================================================================="
  puts $fh "                    FPGA AI SUITE INFERENCE PERFORMANCE REPORT"
  puts $fh "=================================================================================="
  puts $fh "Generated: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
  puts $fh ""
  puts $fh "SUMMARY"
  puts $fh "--------------------------------------------------------------------------------"
  puts $fh "Total inferences:        $num_inferences"
  puts $fh "Total execution time:    [format "%.3f" [expr {$total_time_us / 1000.0}]] ms"

  set total_seconds [expr {$total_time_us / 1000000.0}]
  if {$total_seconds > 0} {
    set throughput [expr {$num_inferences / $total_seconds}]
    puts $fh "Overall throughput:      [format "%.2f" $throughput] inferences/second"
  }
  puts $fh ""

  set sum_latency 0
  set min_latency $inference_latencies(0)
  set max_latency $inference_latencies(0)

  for {set j 0} {$j < $num_inferences} {incr j} {
    set latency $inference_latencies($j)
    set sum_latency [expr {$sum_latency + $latency}]
    if {$latency < $min_latency} { set min_latency $latency }
    if {$latency > $max_latency} { set max_latency $latency }
  }

  set avg_latency [expr {$sum_latency / double($num_inferences)}]

  puts $fh "PER-INFERENCE LATENCY (End-to-End, Hardware Timer @ 300 MHz)"
  puts $fh "--------------------------------------------------------------------------------"
  puts $fh "Average:                 [format "%.1f" $avg_latency] us ([format "%.3f" [expr {$avg_latency / 1000.0}]] ms)"
  puts $fh "Minimum:                 [format "%.1f" $min_latency] us ([format "%.3f" [expr {$min_latency / 1000.0}]] ms)"
  puts $fh "Maximum:                 [format "%.1f" $max_latency] us ([format "%.3f" [expr {$max_latency / 1000.0}]] ms)"
  puts $fh ""
  puts $fh "=================================================================================="
  puts $fh "END OF REPORT"
  puts $fh "=================================================================================="

  close $fh
  puts "Performance report written to: $report_file"
}

proc validate_args {input_file input_tensor_size output_tensor_size} {
  global INGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global AXI_STREAM_DATA_WIDTH_BYTES

  set file_size [file size $input_file]

  if {[expr {$file_size % $AXI_STREAM_DATA_WIDTH_BYTES}] != 0} {
      puts "Error: this design example only supports input sizes aligned to $AXI_STREAM_DATA_WIDTH_BYTES bytes. Please pad accordingly."
      exit 1
  }

  if {[expr {$file_size % $input_tensor_size}] != 0} {
      puts "Error: this graph only supports input sizes aligned to $input_tensor_size bytes. Please pad accordingly."
      exit 1
  }
  set num_inferences [expr {$file_size / $input_tensor_size}]
  set file_size_hex [format "0x%X" $file_size]

  puts "Input file: $input_file"
  puts "Input size: $file_size_hex bytes"
  puts "Number of inferences: $num_inferences"

  return [list $file_size $num_inferences]
}

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

proc initialize_dma {master_path} {
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR

  set csr_register_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x2

  set csr_register_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x2

  after 10

  set csr_register_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x0

  set csr_register_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x0
}

proc stop_sgdmas {master_path} {
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR

  set csr_register_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x20

  set csr_register_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x20
}

proc start_sgdmas {master_path} {
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR

  set csr_register_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x00

  set csr_register_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x00
}

proc clear_sgdma_responses {master_path} {
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR

  set egress_resp_addr [expr {$EGRESS_SGDMA_CSR_ADDR + 0x20 + 0x10}]
  master_read_32 $master_path $egress_resp_addr 2

  set ingress_resp_addr [expr {$INGRESS_SGDMA_CSR_ADDR + 0x20 + 0x10}]
  master_read_32 $master_path $ingress_resp_addr 2
}

proc stage_input {input_file master_path} {
  master_write_from_file $master_path $input_file 0x00080000
  master_read_to_file $master_path "debug_input_dump.bin" 0x00080000 [file size $input_file]
}

proc queue_egress_descriptor {master_path size} {
  global EGRESS_SGDMA_DESCRIPTOR_ADDR

  set csr_register_addr [expr {$EGRESS_SGDMA_DESCRIPTOR_ADDR + 0x4}]
  master_write_32 $master_path $csr_register_addr 0x00100000

  set csr_register_addr [expr {$EGRESS_SGDMA_DESCRIPTOR_ADDR + 0x8}]
  master_write_32 $master_path $csr_register_addr $size

  set csr_register_addr [expr {$EGRESS_SGDMA_DESCRIPTOR_ADDR + 0xc}]
  master_write_32 $master_path $csr_register_addr 0x80000000
}

proc queue_ingress_descriptor {master_path size} {
  global INGRESS_SGDMA_DESCRIPTOR_ADDR

  master_write_32 $master_path [expr {$INGRESS_SGDMA_DESCRIPTOR_ADDR + 0x0}] 0x00080000
  master_write_32 $master_path [expr {$INGRESS_SGDMA_DESCRIPTOR_ADDR + 0x4}] 0x00000000
  master_write_32 $master_path [expr {$INGRESS_SGDMA_DESCRIPTOR_ADDR + 0x8}] $size
  master_write_32 $master_path [expr {$INGRESS_SGDMA_DESCRIPTOR_ADDR + 0xC}] 0x80000300
}

proc read_output {master_path output_file size} {
  master_read_to_file $master_path $output_file 0x00100000 $size
}

proc create_input_bin {partition_data index} {
  set temp_file "chunk_$index.bin"
  set temp_fh [open $temp_file "wb"]
  fconfigure $temp_fh -translation binary
  puts -nonewline $temp_fh $partition_data
  close $temp_fh
  return $temp_file
}

proc poll_register {master_path register_addr register_val_assert} {
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
    puts "Status Register polling timeout. CSR addr: [format 0x%08X $register_addr] = [format 0x%08X $register_val] \nRegister should have bit(s) = [format 0x%08X $register_val_assert]"
    puts "CSR content: [format 0x%08X $register_val]"
    exit 1
  }
}

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


# Called by main process for functional run
#
# Flow summary:
#   For each inference (sequentially):
#     1. Stage input tensor to on-chip ingress memory (0x00080000)
#     2. Queue egress SGDMA descriptor (prepare output path at 0x00100000)
#     3. Queue ingress SGDMA descriptor (stream input from memory -> IP)
#     4. Poll ingress CSR until DMA complete (input fully streamed to IP)
#     5. Poll egress CSR until DMA complete (IP processing done, output captured)
#     6. Read output tensor from on-chip egress memory to file
#     7. Append result to combined output file
#
# Key timing: Egress descriptor queued BEFORE ingress to prevent output backpressure.
# Each inference completes fully before next begins (no pipelining due to single output buffer).
#
# Performance metrics collected:
#   - Per-inference latency: stage input -> read output (true end-to-end per inference)
#   - Overall throughput: total inferences / total wall-clock time
#   - Min/max/average latency across all inferences
#
# Arguments:
#   input_file - Path to input binary file
#   input_tensor_size - Size of each input tensor in bytes
#   output_tensor_size - Size of each output tensor in bytes
#   jtag_path - Glob for matching device for master and issp services
proc spatial_main_functional {input_file input_tensor_size output_tensor_size jtag_path} {
  global INGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global EGRESS_ON_CHIP_MEMORY_SIZE_BYTES
  global AXI_STREAM_DATA_WIDTH_BYTES
  global INGRESS_SGDMA_DESCRIPTOR_ADDR
  global EGRESS_SGDMA_DESCRIPTOR_ADDR
  global INGRESS_SGDMA_CSR_ADDR
  global EGRESS_SGDMA_CSR_ADDR
  global HW_TIMER_BASE_ADDR
  global DLA_IP_0_CSR_ADDR
  global inference_latencies

  puts "Running inference on Spatial Design Example"
  puts "________________________________________________________________________________\n"
  puts "Input tensor size = $input_tensor_size bytes"
  puts "Output tensor size = $output_tensor_size bytes"

  # Validating script arguments. Return input file size in bytes
  set args_result [validate_args $input_file $input_tensor_size $output_tensor_size]
  set file_size [lindex $args_result 0]
  set num_inferences [lindex $args_result 1]
  set file_size_hex [format "0x%X" $file_size]

  # Make sure the input and output tensors can fit into on-chip memory
  if {$input_tensor_size > $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES} {
    puts "Input tensor size is too large to fully fit into on-chip memory of size $INGRESS_ON_CHIP_MEMORY_SIZE_BYTES bytes. Partial transfers are not supported by this design\n"
    exit 1
  }
  if {$output_tensor_size > $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES} {
    puts "Output tensor size is too large to fully fit into on-chip memory of size $EGRESS_ON_CHIP_MEMORY_SIZE_BYTES bytes. Partial transfers are not supported by this design\n"
    exit 1
  }

  # Claim service path to System Console
  set master_path [claim_master $jtag_path]

  # Assert resetn using source/probe IP
  assert_reset $jtag_path

  initialize_dma $master_path

  set input_fh [open $input_file "rb"]
  fconfigure $input_fh -translation binary

  set combined_fh [open "output.bin" "wb"]
  fconfigure $combined_fh -translation binary

  set log_fh [open "inference_timing.log" "w"]
  puts $log_fh "=================================================================================="
  puts $log_fh "                    PER-INFERENCE TIMING LOG"
  puts $log_fh "=================================================================================="
  puts $log_fh "Generated: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
  puts $log_fh ""
  puts $log_fh [format "%-10s %-15s" "Inference" "HW_Timer(us)"]
  puts $log_fh "--------------------------------------------------------------------------------"

  for {set j 0} {$j < $num_inferences} {incr j} {

    puts "Processing inference [expr {$j + 1}]/$num_inferences..."

    set offset [expr {$j * $input_tensor_size}]

    # Seek to the offset and read the chunk
    if {[catch {seek $input_fh $offset} err]} {
      puts "Error seeking to offset $offset: $err"
      close $input_fh
      close $combined_fh
      exit 1
    }

    set partition_data [read $input_fh $input_tensor_size]
    set partition_data_file_name [create_input_bin $partition_data $j]

    stage_input $partition_data_file_name $master_path
    file delete $partition_data_file_name

    queue_egress_descriptor $master_path $output_tensor_size
    queue_ingress_descriptor $master_path $input_tensor_size

    set sgdma_csr_assert 0x00000002
    poll_register $master_path $INGRESS_SGDMA_CSR_ADDR $sgdma_csr_assert
    poll_register $master_path $EGRESS_SGDMA_CSR_ADDR $sgdma_csr_assert

    set output_file "partition_out_$j.bin"
    read_output $master_path $output_file $output_tensor_size

    clear_sgdma_responses $master_path

    # Debug: Read all timer registers
    set timer_cycles [master_read_32 $master_path $HW_TIMER_BASE_ADDR 1]
    set timer_status [master_read_32 $master_path [expr {$HW_TIMER_BASE_ADDR + 0x4}] 1]
    set timer_counter [master_read_32 $master_path [expr {$HW_TIMER_BASE_ADDR + 0x8}] 1]
    puts "  Timer cycles: [format 0x%08X $timer_cycles]"

    set inference_latencies($j) [read_hw_timer_us $master_path]
    puts $log_fh [format "%-10d %-15.3f" $j $inference_latencies($j)]

    set bin_fh [open $output_file "rb"]
    fconfigure $bin_fh -translation binary
    set bin_data [read $bin_fh]
    puts -nonewline $combined_fh $bin_data
    close $bin_fh
    file delete $output_file
  }

  puts $log_fh "=================================================================================="
  close $log_fh

  close $input_fh
  close $combined_fh

  set sum_latency 0
  set min_latency $inference_latencies(0)
  set max_latency $inference_latencies(0)
  for {set j 0} {$j < $num_inferences} {incr j} {
    set latency $inference_latencies($j)
    set sum_latency [expr {$sum_latency + $latency}]
    if {$latency < $min_latency} { set min_latency $latency }
    if {$latency > $max_latency} { set max_latency $latency }
  }
  set avg_latency [expr {$sum_latency / double($num_inferences)}]

  set total_hw_time_us $sum_latency
  set total_hw_time_seconds [expr {$total_hw_time_us / 1000000.0}]
  set throughput [expr {$num_inferences / $total_hw_time_seconds}]

  puts "\n"
  puts "=================================================================================="
  puts "                           PERFORMANCE RESULTS                                    "
  puts "=================================================================================="
  puts ""
  puts "  Completed: $num_inferences inferences (HW Timer: [format "%.3f" [expr {$total_hw_time_us / 1000.0}]] ms)"
  puts ""
  puts "  ╔═══════════════════════════════════════════════════════════════════════════╗"
  puts "  ║                       KEY PERFORMANCE METRICS                             ║"
  puts "  ╠═══════════════════════════════════════════════════════════════════════════╣"
  puts "  ║                                                                           ║"
  puts "  ║  THROUGHPUT:         [format "%9.2f" $throughput] inferences/second                          ║"
  puts "  ║                                                                           ║"
  puts "  ║  LATENCY (Kernel Frequency @ 300 MHz):                                    ║"
  puts "  ║    • Average:       [format "%9.3f" $avg_latency] us  ([format "%6.3f" [expr {$avg_latency / 1000.0}]] ms)                             ║"
  puts "  ║    • Minimum:       [format "%9.3f" $min_latency] us  ([format "%6.3f" [expr {$min_latency / 1000.0}]] ms)                             ║"
  puts "  ║    • Maximum:       [format "%9.3f" $max_latency] us  ([format "%6.3f" [expr {$max_latency / 1000.0}]] ms)                             ║"
  puts "  ║                                                                           ║"
  puts "  ╚═══════════════════════════════════════════════════════════════════════════╝"
  puts ""
  puts "==================================================================================\n\n"

  puts "Inference successfully completed.\n"
  # Generate detailed performance report
  set report_file "performance_report.txt"
  generate_performance_report $report_file $num_inferences $total_hw_time_us
}
