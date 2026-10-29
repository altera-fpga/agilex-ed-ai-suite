// Copyright 2020-2024 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.


const char load_mif_fn[] = R"tcl_fn(

# This process polls a register and returns if assertion is true within a timeout window
# timeout is in centi-seconds
proc poll_register {master_path register_addr register_val_assert timeout_count} {
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
  }
  return $register_val
}

proc load_mif_file {file_path master_path csr_addr config bias_scale} {
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
    set csr_config_register_addr [expr {$csr_addr + 0x380}]
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
      set csr_register_addr [expr {$csr_addr + 0x300}]

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
)tcl_fn";
