// Copyright 2020-2024 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Intel's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

// This MMD object can only support one inference request.
// TODO: factor this system-console MMD into its own "aocl" layer.
//       The hostless-ED runtime should use the generic MMD interface
//       to access the "aocl" layer

#include "system_console_wrapper.h"
#include "dla_fifo_pipe.h"

// This design example only supports an AXI Width of 128 bits 16 bytes
#define AXI_STREAM_DATA_WIDTH_BYTES 16
// This design example has a limit to ingress on-chip memory size in bytes
#define INGRESS_ON_CHIP_MEMORY_SIZE_BYTES 524288u
// This design example has a limit to egress on-chip memory size in bytes
#define EGRESS_ON_CHIP_MEMORY_SIZE_BYTES 131072u

// DDR-Free ED Address Map Constants
#define DLA_IP_0_CSR_ADDR 0x00038000u
#define INGRESS_SGDMA_CSR_ADDR 0x00030000u
#define INGRESS_SGDMA_DESCRIPTOR_ADDR 0x00030020u
#define EGRESS_SGDMA_CSR_ADDR 0x00030040u
#define EGRESS_SGDMA_DESCRIPTOR_ADDR 0x00030060u

// Most AOCL_MMD_CALL functions return negative number in case of error,
// MMD_AOCL_ERR is used to indicate an error from the MMD that is being
// returned to the runtime.  Simply set to -2 for now since neither interface
// defines a meaning to return codes for errors.
#define MMD_AOCL_ERR -1

// NOTE: some of the code relies on invalid handle returning -1
// future TODO eliminate dependency on specific error values
#define MMD_INVALID_PARAM -1

// Our diagnostic script relies on handle values < -1 to determine when
// a valid device is present but a functioning ASP is not loaded.
#define MMD_ASP_NOT_LOADED -2
#define MMD_ASP_INIT_FAILED -3

enum {
  // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)
  AOCL_IRQ_POLLING_BASE = 0x0100,  // CSR to polling interrupt status
  AOCL_IRQ_MASKING_BASE = 0x0108,  // CSR to set/unset interrupt mask
  AOCL_MMD_KERNEL = 0,
  AOCL_MMD_MEMORY = 1,
  AOCL_MMD_DLA_CSR = 2,
};



// Handles interacting with a device, communicates through system_console based on existing streaming designs
class Device: public SystemConsoleWrapper {
  static int next_mmd_handle;
  uint64_t fpga_obj_id;
  int mmd_handle;
  std::optional<dla::sequential_fifo::Handle> fifo_reader;
  // Egress shape information set by set_output_shape().
  //   total_bytes: number of bytes the egress SGDMA will transfer per inference
  //                (packed FP16 output, rounded up to AXI_STREAM_DATA_WIDTH_BYTES
  //                so the bridge's final zero-padded beat is included).  Sizes
  //                the SGDMA descriptor and the stream-out staging buffer.
  //   valid_bytes: number of non-padding bytes in the packed egress data
  //                (exactly H*W*C*sizeof(fp16)).  This is what gets copied out
  //                to the caller's buffer in get_output_data(); the trailing
  //                (total_bytes - valid_bytes) zero-padding bytes are dropped
  //                so we never write past the caller's allocation.
  // Wrapped in std::optional so a call to get_output_data() before
  // set_output_shape() throws an explicit error rather than silently emitting
  // zero bytes (which used to happen when these were uninitialised ints).
  struct OutputShapeBytes {
    uint32_t total_bytes;
    uint32_t valid_bytes;
  };
  std::optional<OutputShapeBytes> output_shape_bytes;
  void stream_in(uint32_t length, const void* data);
  void load_mif_file(const std::string filepath, const bool config, const bool bias_scale);

public:
  std::string master_path = "";
  std::string claimed_issp = "";
  std::vector<uint8_t> data_buffer_stream_out;
  std::mutex device_mutex;

  static bool parse_board_name(const char *board_name_str, uint64_t &obj_id) {
    obj_id = 1;
    return true;
  } // Not implemented

  void assert_reset();
  void write_csr(uint32_t addr, uint32_t data);
  uint32_t read_csr(uint32_t addr);
  void initialize();
  void reset_sgdmas();
  // Stop both ingress/egress SGDMAs by writing 0x20 to CSRs
  void stop_sgdmas();
  // Start both ingress/egress SGDMAs by writing 0x0 to CSRs
  void start_sgdmas();
  // Adding descriptor to egress streaming mSGDMA
  void queue_egress_descriptor(unsigned int size);
  // Adding descriptor to ingress streaming mSGDMA
  void queue_ingress_descriptor(unsigned int size);
  // Read output from on-chip memory
  unsigned int get_inference_count();
  void poll_register(unsigned int register_addr, unsigned int register_val_assert, unsigned int timout_count = 3000);
  void stream_in_data(int length, unsigned int timeout = 30);
  void stream_out_data();
  void get_output_data(void* data);
  void open_fifo(const char *path);
  int set_output_shape(uint64_t channels, uint64_t height, uint64_t width, uint64_t c_vec);
  void online_reconfig(const char* mifs_path);

  int get_mmd_handle() { return mmd_handle; }
  uint64_t get_fpga_obj_id() { return fpga_obj_id; }
  std::string get_bdf() { return ""; } // Not implemented;
  float get_temperature() { return 0.0; } // Not implemented;
  std::string get_dev_name() {return ""; } // Not implemented

  Device(uint64_t obj_id, const char* jtag_path);
  ~Device();
};
