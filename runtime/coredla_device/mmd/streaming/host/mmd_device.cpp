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

#include "mmd_device.h"
#include "tcl_functions.h"
#include "dla_dma_constants.h"

#include <limits>

namespace {
// All egress output elements are FP16; one element occupies this many bytes.
// Used by set_output_shape() to size the egress transfer and by
// get_output_data() to step through the byte-flipped stream.
constexpr size_t kFp16Bytes = 2;
}  // namespace

#if defined(_WIN32) || defined(_WIN64)
#else
#include <unistd.h>
#include <sys/select.h>
#include <fcntl.h>
#endif

int Device::next_mmd_handle = 1;

void Device::assert_reset() {
  if (claimed_issp.empty()) {
    claimed_issp = claim_service("issp", "*", " mylib");
  }
  send_command("issp_write_source_data", claimed_issp, "0x0");
  send_command("issp_write_source_data", claimed_issp, "0x1");
}

void Device::write_csr(uint32_t addr, uint32_t data) {
  std::lock_guard<std::mutex> lock(device_mutex);
  write_32(master_path, DLA_IP_0_CSR_ADDR + addr, data);
}

uint32_t Device::read_csr(uint32_t addr) {
  std::lock_guard<std::mutex> lock(device_mutex);
  return read_32(master_path, DLA_IP_0_CSR_ADDR + addr);
}

void Device::initialize() {
  // write_csr(DLA_DMA_CSR_OFFSET_IP_RESET, 1);
  write_csr(DLA_DMA_CSR_OFFSET_INTERMEDIATE_BASE_ADDR, 0);
  write_csr(DLA_DMA_CSR_OFFSET_INTERRUPT_MASK, 0);
  write_csr(DLA_DMA_CSR_OFFSET_INTERRUPT_CONTROL, 3);
  // Writing 0x1 to this register will instruct DLA to accept input until register is cleared
  write_csr(DLA_CSR_OFFSET_READY_STREAMING_IFACE, 1);
  read_csr(DLA_CSR_OFFSET_READY_STREAMING_IFACE);
  // Reset egress SGDMA
  write_32(master_path, EGRESS_SGDMA_CSR_ADDR + 0x4, 0x2);
  // Reset ingress SGDMA
  write_32(master_path, INGRESS_SGDMA_CSR_ADDR + 0x4, 0x2);
}

void Device::reset_sgdmas() {
  // Reset egress SGDMA
  write_32(master_path, EGRESS_SGDMA_CSR_ADDR + 0x4, 0x2);
  // Reset ingress SGDMA
  write_32(master_path, INGRESS_SGDMA_CSR_ADDR + 0x4, 0x2);
}

// Stop both ingress/egress SGDMAs by writing 0x20 to CSRs
void Device::stop_sgdmas() {
  // Stop egress SGDMA
  write_32(master_path, EGRESS_SGDMA_CSR_ADDR + 0x4, 0x20);
  // Stop ingress SGDMA
  write_32(master_path, INGRESS_SGDMA_CSR_ADDR + 0x4, 0x20);
}

// Start both ingress/egress SGDMAs by writing 0x0 to CSRs
void Device::start_sgdmas() {
  // Start egress SGDMA
  write_32(master_path, EGRESS_SGDMA_CSR_ADDR + 0x4, 0x00);
  // Start ingress SGDMA
  write_32(master_path, INGRESS_SGDMA_CSR_ADDR + 0x4, 0x00);
}

// Adding descriptor to egress streaming mSGDMA
void Device::queue_egress_descriptor(unsigned int size) {
  // Destination addr
  write_32(master_path, EGRESS_SGDMA_DESCRIPTOR_ADDR + 0x4, 0x00280000);
  // Transfer length in bytes (output size)
  write_32(master_path, EGRESS_SGDMA_DESCRIPTOR_ADDR + 0x8, size);
  // Queue descriptor (Writing 0x8000_0000)
  write_32(master_path, EGRESS_SGDMA_DESCRIPTOR_ADDR + 0xc, 0x80000000);
}

// Adding descriptor to ingress streaming mSGDMA
void Device::queue_ingress_descriptor(unsigned int size) {
  // Source addr
  write_32(master_path, INGRESS_SGDMA_DESCRIPTOR_ADDR, 0x00200000);
  // Transfer length in bytes (input size)
  write_32(master_path, INGRESS_SGDMA_DESCRIPTOR_ADDR + 0x8, size);
  // Queue descriptor
  write_32(master_path, INGRESS_SGDMA_DESCRIPTOR_ADDR + 0xc, 0x80000000);
}

// Read output from on-chip memory
unsigned int Device::get_inference_count() {
  // Check what completion counter CSR in HW is set to
  return read_csr(DLA_DMA_CSR_OFFSET_COMPLETION_COUNT);
}

void Device::poll_register(unsigned int register_addr, unsigned int register_val_assert, unsigned int timout_count) {
  auto res = send_command("poll_register", master_path, register_addr, register_val_assert, timout_count);
  unsigned int register_val = std::stoul(remove_non_alphanumeric(res), nullptr, 16);
  if (register_val != register_val_assert) {
    throw std::runtime_error("Register polling timeout. CSR addr: " + std::to_string(register_addr) + " = " + std::to_string(register_val) + "\nRegister should be = " + std::to_string(register_val_assert));
  }
}

void Device::stream_in(uint32_t length, const void* data) {
  if (data == nullptr) {
    throw std::runtime_error("stream_in: data must be a valid pointer");
  }
  write(master_path, 0x00200000, length, data);
  queue_ingress_descriptor(length);
  // Poll SGDMA register to check if input data streaming is complete
  poll_register(INGRESS_SGDMA_CSR_ADDR, 2);
}

// read data from fifo and stream in to device
void Device::stream_in_data(int length, unsigned int timeout) {
  assert(fifo_reader.has_value() && "FIFO not opened. Call open_fifo() first.");
  std::lock_guard<std::mutex> dev_lock(device_mutex);
  static std::vector<unsigned char> ingress_buffer(INGRESS_ON_CHIP_MEMORY_SIZE_BYTES);

  auto lock = fifo_reader->lock();
  int offset = 0;
  while (offset < length) {
    int to_read = std::min(static_cast<int>(INGRESS_ON_CHIP_MEMORY_SIZE_BYTES), length - offset);
    int read_bytes = 0;
    while (!lock->read(ingress_buffer, read_bytes, to_read, timeout)) {
      // keep trying to read until requested amount is read or timeout occurs
    }
    assert(read_bytes == to_read && "Did not read expected number of bytes from fifo.");
    stream_in(read_bytes, ingress_buffer.data());
    offset += read_bytes;
  }
}

void Device::stream_out_data() {
  std::lock_guard<std::mutex> lock(device_mutex);

  // copy out EGRESS_ON_CHIP_MEMORY_SIZE_BYTES chunks
  // by reading from a file which system-console writes to
  unsigned int total_size = data_buffer_stream_out.size();
  unsigned int offset = 0;
  while (offset < total_size) {
    unsigned int chunk_size = std::min(EGRESS_ON_CHIP_MEMORY_SIZE_BYTES, total_size - offset);
    // Queue chunks of EGRESS_ON_CHIP_MEMORY_SIZE_BYTES at a time to ensure a fit in egress on-chip memory
    queue_egress_descriptor(chunk_size);
    // Poll SGDMA register to check if output data streaming is complete
    poll_register(EGRESS_SGDMA_CSR_ADDR, 2);
    // Write a partition of the inference result to the partition file
    read(master_path, 0x00280000, chunk_size, data_buffer_stream_out.data() + offset);
    offset += chunk_size;
  }
  //save data to file for debugging
  std::ofstream ofs("stream_out_data.bin", std::ios::out | std::ios::binary);
  if (!ofs) {
    throw std::runtime_error("stream_out_data: failed to open file for writing stream out data");
  }
  ofs.write(reinterpret_cast<const char *>(data_buffer_stream_out.data()), data_buffer_stream_out.size());
  ofs.close();
}

void Device::get_output_data(void* data) {
  std::lock_guard<std::mutex> lock(device_mutex);
  if (data == nullptr) {
    throw std::runtime_error("get_output_data: data must be a valid pointer");
  }
  if (!output_shape_bytes.has_value()) {
    throw std::runtime_error(
        "get_output_data: set_output_shape() must be called before get_output_data()");
  }
  // Flip endianness on each AXI_STREAM_DATA_WIDTH_BYTES word (the egress SGDMA
  // writes big-endian).  The AXI-to-Avalon-ST bridge already strips invalid
  // bytes in hardware, so no 0xFFFF padding remains in the packed stream.  The
  // bridge does zero-pad the final beat up to AXI_STREAM_DATA_WIDTH_BYTES
  // alignment, so total_bytes >= valid_bytes; we copy only the valid bytes so
  // the caller's buffer (sized to the model's logical output) is never
  // overflowed.
  //
  // Loop bound is in whole FP16 elements: valid_bytes is a multiple of
  // kFp16Bytes by construction (set_output_shape multiplies by kFp16Bytes),
  // so we never need to copy a half-element.
  const auto& shape = *output_shape_bytes;
  const size_t total_bytes = data_buffer_stream_out.size();   // == shape.total_bytes
  const size_t valid_bytes = shape.valid_bytes;               // <= total_bytes
  auto u8_data = static_cast<uint8_t *>(data);
  size_t offset = 0;
  for (size_t i = AXI_STREAM_DATA_WIDTH_BYTES - kFp16Bytes;
       i < total_bytes && offset < valid_bytes;
       i += AXI_STREAM_DATA_WIDTH_BYTES) {
    for (size_t j = 0; j < AXI_STREAM_DATA_WIDTH_BYTES && offset < valid_bytes; j += kFp16Bytes) {
      u8_data[offset++] = data_buffer_stream_out[i - j + 1];
      u8_data[offset++] = data_buffer_stream_out[i - j];
    }
  }
}

void Device::open_fifo(const char *path) {
  std::lock_guard<std::mutex> lock(device_mutex);
  fifo_reader.emplace(std::string(path), dla::sequential_fifo::Mode::READ, true); // read multiple
}

int Device::set_output_shape(uint64_t C, uint64_t H, uint64_t W, uint64_t CVEC) {
  std::lock_guard<std::mutex> lock(device_mutex);
  (void)CVEC;  // No longer needed: the HW bridge packs valid bytes itself, so
               // the per-pixel-padding term that previously needed CVEC is gone.

  // The AXI-to-Avalon-ST bridge in hardware packs only the valid bytes and
  // zero-pads the final beat up to AXI_STREAM_DATA_WIDTH_BYTES alignment, so
  // the egress SGDMA transfers a multiple of AXI_STREAM_DATA_WIDTH_BYTES per
  // inference:
  //
  //   valid_bytes = H * W * C * kFp16Bytes              (logical output size)
  //   total_bytes = ceil(valid_bytes / W) * W           (W = AXI bytes/beat)
  //
  // We hand total_bytes to the SGDMA descriptor and the staging buffer; only
  // valid_bytes are exposed to callers in get_output_data().  All math is
  // done in uint64_t to avoid overflow on adversarial shapes; the eventual
  // cast down to int (the legacy return type / API surface) is range-checked.
  const uint64_t valid_bytes_64 = H * W * C * kFp16Bytes;
  const uint64_t total_bytes_64 =
      ((valid_bytes_64 + AXI_STREAM_DATA_WIDTH_BYTES - 1) / AXI_STREAM_DATA_WIDTH_BYTES) *
      AXI_STREAM_DATA_WIDTH_BYTES;

  // The legacy API returns int (negative on error in the dla_mmd_* layer), so
  // total_bytes must fit in a non-negative int.  In practice this caps at
  // INT_MAX (~2 GB), which is well above any realistic single-inference
  // output and well above the on-chip memory limit.
  if (valid_bytes_64 == 0 ||
      total_bytes_64 > static_cast<uint64_t>(std::numeric_limits<int>::max())) {
    throw std::runtime_error(
        "Error with egress byte calculation. Please check your output shape size arguments (C H W)");
  }

  output_shape_bytes = OutputShapeBytes{
      static_cast<uint32_t>(total_bytes_64),
      static_cast<uint32_t>(valid_bytes_64),
  };
  data_buffer_stream_out.resize(output_shape_bytes->total_bytes);
  return static_cast<int>(total_bytes_64);
}

void Device::online_reconfig(const char* mifs_path) {
  {
    std::lock_guard<std::mutex> lock(device_mutex);
    assert_reset();

    fs::path mifs_filepath(mifs_path);

    fs::path filepath = mifs_filepath / "ddrfree_filter_hw_reconfig.mif";
    if (!fs::exists(filepath)) {
      throw std::runtime_error("MIF file not found: " + filepath.native());
    }
    // Set timeout to 500 seconds for loading large MIF files
    auto old_timeout = set_timeout_ms(500000);
    send_command("load_mif_file", filepath.native(), master_path, DLA_IP_0_CSR_ADDR, 0, 0);
    set_timeout_ms(old_timeout);
    filepath = mifs_filepath / "ddrfree_bias_scale_hw_reconfig.mif";
    if (!fs::exists(filepath)) {
      throw std::runtime_error("MIF file not found: " + filepath.native());
    }
    send_command("load_mif_file", filepath.native(), master_path, DLA_IP_0_CSR_ADDR, 0, 1);
    filepath = mifs_filepath / "ddrfree_config.mif";
    if (!fs::exists(filepath)) {
      throw std::runtime_error("MIF file not found: " + filepath.native());
    }
    send_command("load_mif_file", filepath.native(), master_path, DLA_IP_0_CSR_ADDR, 1, 0);

    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    assert_reset();
  }
  initialize();
  reset_sgdmas();
}

Device::Device(uint64_t obj_id, const char* jtag_path): SystemConsoleWrapper(), fpga_obj_id(obj_id) {
  mmd_handle = next_mmd_handle;
  if (next_mmd_handle == std::numeric_limits<int>::max())
    next_mmd_handle = 1;
  else
    next_mmd_handle++;

  auto sys_con_fns = temp_dir().append("system_console_functions.tcl");
  std::ofstream scf(sys_con_fns);
  if (!scf) {
    throw std::runtime_error("failed to open temporary file for writing system-console functions");
  }
  scf << load_mif_fn << std::endl;
  scf.close();
  send_command("source", sys_con_fns.string());

  std::string jtag_glob = jtag_path != nullptr ? std::string(jtag_path) : "";
  if (jtag_glob.empty()) {
    jtag_glob = "*";
  }

  master_path = claim_service("master", jtag_glob, "\"\"");

  assert_reset();
  initialize();
}

Device::~Device() {
  send_command("close_service master", master_path);
  if (!claimed_issp.empty()) {
    send_command("close_service issp", claimed_issp);
  }
}
