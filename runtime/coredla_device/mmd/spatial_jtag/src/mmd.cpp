// Copyright 2026 Altera Corporation.
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

#include "mmd.h"

#include "address_map.h"
#include "fpga.h"
#include "spatial_port_config.h"

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <thread>
#include <utility>
#include <vector>

// `fs` is boost::filesystem aliased by system_console_wrapper.h

namespace {

// Number of 10 ms Tcl polls before a transfer is declared hung
constexpr unsigned kTransferTimeoutCount = 3000;

constexpr int kDispatcherResetSettleMs = 10;

// Largest slice of a weight file held in host memory at once when the file has
// to be split across window pages
constexpr uint64_t kStagingChunkBytes = 8u << 20;

// The 1GB page each bank's JTAG window currently covers. Cleared on reset()
std::map<uint32_t, uint64_t> g_window_page;

std::string to_hex(uint32_t value) {
  char buffer[16];
  std::snprintf(buffer, sizeof(buffer), "0x%08x", value);
  return buffer;
}

// Geometry and address map of one io port
struct Port {
  const char* label;
  bool is_input;
  unsigned dw;                    // Data Width
  unsigned num_lanes;
  unsigned sub_vectors;
  unsigned packets;
  // Following addresses are in the JTAG to Avalon MM
  uint32_t dma_csr_addr;
  uint32_t dma_descriptor_addr;
  uint64_t ddr_base_addr;

  unsigned subvector_bits() const { return dw * num_lanes; }
  unsigned subvectors_per_beat() const { return design::subvectors_per_beat(dw, num_lanes); }
  unsigned beats_per_packet() const {
    return design::beats_per_packet(dw, num_lanes, sub_vectors);
  }
  unsigned beat_bytes() const { return design::kDdrBeatBytes; }
  unsigned tensor_elems() const { return packets * sub_vectors * num_lanes; }
  uint64_t tensor_bytes() const {
    return static_cast<uint64_t>(packets) * beats_per_packet() * beat_bytes();
  }
};

Port make_port(bool is_input) {
  Port port;
  port.label = is_input ? "input" : "output";
  port.is_input = is_input;
  const SpatialPortConfig& cfg = spatial_port_config();
  port.dw = is_input ? cfg.input_data_width : cfg.output_data_width;
  port.num_lanes = is_input ? cfg.input_lanes : cfg.output_lanes;
  port.sub_vectors = is_input ? cfg.input_subvectors : cfg.output_subvectors;
  port.packets = is_input ? cfg.input_packets : cfg.output_packets;
  port.dma_csr_addr = design::dma_csr_addr(is_input);
  port.dma_descriptor_addr = design::dma_descriptor_addr(is_input);
  port.ddr_base_addr = design::ddr_base_addr(is_input);
  return port;
}

// Ensure that the fpga is actually connected
JtagSession& require_session() {
  JtagSession* session = spatial_jtag_session();
  if (session == nullptr) {
    throw std::runtime_error("connect_to_fpga must be called first.");
  }
  if (!spatial_port_config().loaded()) {
    throw std::runtime_error("load_port_config must be called first.");
  }
  return *session;
}

// ---------------------------------------------------------------------------
// Bit packing. Each 256-bit beat holds as many contiguous subvectors as possible
// starting from LSB. Leftover MSBs are padding in the case that 256 does not
// evenely divide the size of a subvector. Because mSGDMA presents memory as
// big-endian Avalon-ST, each beat is byte-reversed
// ---------------------------------------------------------------------------

// Return the byte holding bit `position` of the beat, little endian layout
uint32_t beat_byte_index(uint32_t position) { return position / 8; }

void swap_beat_bytes(uint8_t* beat) {
  for (unsigned i = 0; i < design::kDdrBeatBytes / 2; i++) {
    std::swap(beat[i], beat[design::kDdrBeatBytes - 1 - i]);
  }
}

// Write a subvector of the io port into the emif beat array. Raw data is stored in `elements`
// `slot` is the subvector index of a total emif beat that is being written to
void write_subvector(const Port& port, const uint64_t* elements, uint8_t* beat,
                     unsigned slot) {
  const uint32_t bit_base = slot * port.subvector_bits();
  for (uint32_t lane = 0; lane < port.num_lanes; lane++) {
    // Write bit by bit
    for (uint32_t bit = 0; bit < port.dw; bit++) {
      if (((elements[lane] >> bit) & 1) == 0) {
        continue;
      }
      // Bit position within the subvector
      const uint32_t bit_position = bit_base + lane * port.dw + bit;
      beat[beat_byte_index(bit_position)] |= static_cast<uint8_t>(1u << (bit_position % 8));
    }
  }
}

// Recover one subvector from slot `slot` of little-endian emif `beat`, ignoring
// padding. The inverse of write_subvector(...)
void read_subvector(const Port& port, const uint8_t* beat, uint64_t* elements,
                    unsigned slot) {
  const uint32_t bit_base = slot * port.subvector_bits();
  for (uint32_t lane = 0; lane < port.num_lanes; lane++) {
    uint64_t value = 0;
    for (uint32_t bit = 0; bit < port.dw; bit++) {
      // Bit position within the subvector
      const uint32_t position = bit_base + lane * port.dw + bit;
      const uint8_t byte = beat[beat_byte_index(position)];
      value |= static_cast<uint64_t>((byte >> (position % 8)) & 1) << bit;
    }
    elements[lane] = value;
  }
}

// Pack tensor `elements` into DDR staging buffer `staged`. Each packet is
// packed on its own so a short last beat does not spill into the next packet
void pack_tensor(const Port& port, const uint64_t* elements, uint8_t* staged) {
  const unsigned sv_per_beat = port.subvectors_per_beat();
  const unsigned beats_per_pkt = port.beats_per_packet();
  const unsigned beat_bytes = port.beat_bytes();
  for (unsigned packet = 0; packet < port.packets; packet++) {
    // Write one emif beat at a time
    for (unsigned beat = 0; beat < beats_per_pkt; beat++) {
      uint8_t logical[design::kDdrBeatBytes] = {};
      // Fill each emif beat with subvectors
      for (unsigned slot = 0; slot < sv_per_beat; slot++) {
        // Subvector position within the emif beat
        const unsigned sv = beat * sv_per_beat + slot;
        if (sv >= port.sub_vectors) {  // port.sub_vectors is the number of subvectors in a packet
          break;
        }
        const unsigned elem = (packet * port.sub_vectors + sv) * port.num_lanes;
        write_subvector(port, &elements[elem], logical, slot);
      }
      swap_beat_bytes(logical);
      std::memcpy(&staged[(packet * beats_per_pkt + beat) * beat_bytes], logical, beat_bytes);
    }
  }
}

// Undo pack_tensor(...) on data read back out of DDR
void unpack_tensor(const Port& port, const uint8_t* staged, uint64_t* elements) {
  const unsigned sv_per_beat = port.subvectors_per_beat();
  const unsigned beats_per_pkt = port.beats_per_packet();
  const unsigned beat_bytes = port.beat_bytes();
  for (unsigned packet = 0; packet < port.packets; packet++) {
    for (unsigned beat = 0; beat < beats_per_pkt; beat++) {
      uint8_t logical[design::kDdrBeatBytes] = {};
      std::memcpy(logical, &staged[(packet * beats_per_pkt + beat) * beat_bytes], beat_bytes);
      swap_beat_bytes(logical);
      for (unsigned slot = 0; slot < sv_per_beat; slot++) {
        const unsigned sv = beat * sv_per_beat + slot;
        if (sv >= port.sub_vectors) {
          break;
        }
        const unsigned elem = (packet * port.sub_vectors + sv) * port.num_lanes;
        read_subvector(port, logical, &elements[elem], slot);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// DDR access. A bank is only visible one window page at a time
// ---------------------------------------------------------------------------

// Check if ddr address range [ddr_addr, ddr_addr + bytes] falls into
// the DDR bank's capacity
void check_in_bank(uint32_t bank, uint64_t ddr_addr, uint64_t bytes,
                   const std::string& what) {
  if (bytes > design::kDdrBankCapacityBytes ||
      ddr_addr > design::kDdrBankCapacityBytes - bytes) {
    throw std::runtime_error(what + " covers " + std::to_string(bytes) +
                             " bytes from byte " + std::to_string(ddr_addr) +
                             " of DDR bank " + std::to_string(bank) +
                             ", which only holds " +
                             std::to_string(design::kDdrBankCapacityBytes) + ".");
  }
}

// Refuse a feature transfer that runs past the region reserved for that port
void check_in_region(const Port& port, uint64_t bytes, const std::string& what) {
  if (bytes == 0) {
    throw std::runtime_error(what + " for the " + port.label + " port is empty.");
  }
  if (bytes > design::kFeatureRegionBytes) {
    throw std::runtime_error(what + " for the " + std::string(port.label) + " port needs " +
                             std::to_string(bytes) + " bytes, more than the " +
                             std::to_string(design::kFeatureRegionBytes) +
                             " byte DDR region reserved for it.");
  }
}

void read_ddr(JtagSession& session, uint32_t bank, uint64_t ddr_addr, void* data,
              uint64_t bytes);

// Write `bytes` of `data` to DDR `bank` at local DDR address `ddr_addr`
void write_ddr(JtagSession& session, uint32_t bank, uint64_t ddr_addr, const void* data,
               uint64_t bytes);

// Point `bank`'s window at the page holding local DDR address `ddr_addr`
// and return the JTAG to Avalon host address that byte now appears at
uint32_t open_window(JtagSession& session, uint32_t bank, uint64_t ddr_addr) {
  // Get 1GB page aligned address
  const uint64_t page = ddr_addr & ~(design::kDdrWindowSize - 1);

  const auto current = g_window_page.find(bank);
  // When miss is true, it means that the span extender for the DDR bank
  // does not point at the correct DDR window
  const bool miss = current == g_window_page.end() || current->second != page;
  if (miss) {
    // Point span extender to the appropriate base address
    const uint32_t cntl = design::window_cntl_addr(bank);
    session.write_32(session.master_path(), cntl + span_extender::kWindowBaseLow,
                     static_cast<uint32_t>(page));
    session.write_32(session.master_path(), cntl + span_extender::kWindowBaseHigh,
                     static_cast<uint32_t>(page >> 32));
    g_window_page[bank] = page;
  }

  return static_cast<uint32_t>(design::window_base_addr(bank) + (ddr_addr - page));
}

void write_ddr(JtagSession& session, uint32_t bank, uint64_t ddr_addr, const void* data,
               uint64_t bytes) {
  check_in_bank(bank, ddr_addr, bytes, "Write to DDR");

  const uint8_t* cursor = static_cast<const uint8_t*>(data);
  while (bytes > 0) {
    const uint32_t host_addr = open_window(session, bank, ddr_addr);
    // Stop at the end of the page; the next pass moves the window along.
    const uint64_t page_left =
        design::kDdrWindowSize - (ddr_addr & (design::kDdrWindowSize - 1));
    const uint64_t chunk = std::min(bytes, page_left);

    session.write(session.master_path(), host_addr, static_cast<unsigned>(chunk), cursor);

    cursor += chunk;
    ddr_addr += chunk;
    bytes -= chunk;
  }
}

void read_ddr(JtagSession& session, uint32_t bank, uint64_t ddr_addr, void* data,
              uint64_t bytes) {
  check_in_bank(bank, ddr_addr, bytes, "Read from DDR");

  uint8_t* cursor = static_cast<uint8_t*>(data);
  while (bytes > 0) {
    const uint32_t host_addr = open_window(session, bank, ddr_addr);
    const uint64_t page_left =
        design::kDdrWindowSize - (ddr_addr & (design::kDdrWindowSize - 1));
    const uint64_t chunk = std::min(bytes, page_left);

    session.read(session.master_path(), host_addr, static_cast<unsigned>(chunk), cursor);

    cursor += chunk;
    ddr_addr += chunk;
    bytes -= chunk;
  }
}

// Write weights from a binary file into ddr `bank` starting at local DDR address `ddr_addr`
// The weights .bin file has `bytes` size
void write_ddr_from_file(JtagSession& session, uint32_t bank, uint64_t ddr_addr,
                         const std::string& path, uint64_t bytes) {
  check_in_bank(bank, ddr_addr, bytes, path);

  // How many bytes remain from ddr_addr to the end of the current 1GB window
  // being written to
  const uint64_t page_left =
      design::kDdrWindowSize - (ddr_addr & (design::kDdrWindowSize - 1));
  if (bytes <= page_left) {
    // The whole file lands in one page
    session.send_command("master_write_from_file", session.master_path(), path,
                         to_hex(open_window(session, bank, ddr_addr)));
    return;
  }

  std::ifstream file(path, std::ios::in | std::ios::binary);
  if (!file) {
    throw std::runtime_error("Could not open " + path + " to stage it into DDR.");
  }

  std::vector<uint8_t> buffer;
  uint64_t remaining = bytes;
  while (remaining > 0) {
    const uint64_t in_page =
        design::kDdrWindowSize - (ddr_addr & (design::kDdrWindowSize - 1));
    const uint64_t chunk = std::min({remaining, in_page, kStagingChunkBytes});

    buffer.resize(static_cast<size_t>(chunk));
    if (!file.read(reinterpret_cast<char*>(buffer.data()),
                   static_cast<std::streamsize>(chunk))) {
      throw std::runtime_error("Unexpected end of " + path + " while staging it into DDR.");
    }
    write_ddr(session, bank, ddr_addr, buffer.data(), chunk);

    ddr_addr += chunk;
    remaining -= chunk;
  }
}

// ---------------------------------------------------------------------------
// mSGDMA descriptors
// ---------------------------------------------------------------------------

// Wait until emif calibration has completed. The inference timer is placed on the
// ip_reset_gen reset controller which takes the emif calibration resets as input.
// Reads to the inference timer should be blocked until the clock crossing from
// JTAG domain to kernel domain is ready (also on ip_reset_gen)
void wait_until_ddr_reachable(JtagSession& session) {
  session.read_32(session.master_path(), design::kDmaIngressBaseAddr);
  session.read_32(session.master_path(), design::kTimerBaseAddr);
}

// The first JTAG write after a hung transaction reports success and leaves
// zeros in DDR. Compare the head of the file against the bank before claiming
// the load worked.
void verify_weight_write(JtagSession& session, uint32_t bank, uint64_t offset,
                         const std::string& path, uint64_t bytes) {
  if (bytes == 0) {
    return;
  }
  const uint64_t check = std::min<uint64_t>(bytes, 8);
  std::ifstream file(path, std::ios::in | std::ios::binary);
  if (!file) {
    throw std::runtime_error("Could not reopen " + path + " to verify the DDR write.");
  }
  uint8_t expected[8] = {};
  uint8_t observed[8] = {};
  if (!file.read(reinterpret_cast<char*>(expected), static_cast<std::streamsize>(check))) {
    throw std::runtime_error("Could not read " + path + " to verify the DDR write.");
  }
  read_ddr(session, bank, offset, observed, check);
  if (std::memcmp(expected, observed, static_cast<size_t>(check)) != 0) {
    throw std::runtime_error(
        path + " wrote to DDR bank " + std::to_string(bank) +
        " but the first bytes read back do not match. The window is still in "
        "reset or the JTAG write did not land.");
  }
}

// Initialize the ingress and egress msgdmas. Write reset byte to csr, sleep
// for 10ms to let things settle, and then restore running state
void initialize_dmas(JtagSession& session) {
  const uint32_t csr_bases[] = {design::kDmaIngressBaseAddr, design::kDmaEgressBaseAddr};
  for (uint32_t base : csr_bases) {
    session.write_32(session.master_path(), base + msgdma::kCsrControl, msgdma::kControlReset);
  }

  std::this_thread::sleep_for(std::chrono::milliseconds(kDispatcherResetSettleMs));

  for (uint32_t base : csr_bases) {
    session.write_32(session.master_path(), base + msgdma::kCsrControl, msgdma::kControlRun);
  }
}

// Program msgdma descriptor and enable
void queue_descriptor(JtagSession& session, const Port& port, uint64_t bytes) {
  check_in_region(port, bytes, port.is_input ? "Ingress transfer" : "Egress transfer");

  const uint32_t descriptor = port.dma_descriptor_addr;
  // Ingress reads the feature region. Egress writes it. The unused address
  // is 0 because that side of the dispatcher is an Avalon-ST port
  const uint64_t read_addr = port.is_input ? port.ddr_base_addr : 0;
  const uint64_t write_addr = port.is_input ? 0 : port.ddr_base_addr;

  session.write_32(session.master_path(), descriptor + msgdma::kDescriptorReadAddress,
                   static_cast<uint32_t>(read_addr));
  session.write_32(session.master_path(), descriptor + msgdma::kDescriptorReadAddressHigh,
                   static_cast<uint32_t>(read_addr >> 32));
  session.write_32(session.master_path(), descriptor + msgdma::kDescriptorWriteAddress,
                   static_cast<uint32_t>(write_addr));
  session.write_32(session.master_path(), descriptor + msgdma::kDescriptorWriteAddressHigh,
                   static_cast<uint32_t>(write_addr >> 32));
  session.write_32(session.master_path(), descriptor + msgdma::kDescriptorLength,
                   static_cast<uint32_t>(bytes));
  session.write_32(session.master_path(), descriptor + msgdma::kDescriptorControl,
                   msgdma::kDescriptorGo);
}

bool transfer_finished(JtagSession& session, const Port& port) {
  const uint32_t status = port.dma_csr_addr + msgdma::kCsrStatus;
  const uint32_t observed =
      session.poll_register(status, msgdma::kStatusTransferDone, kTransferTimeoutCount);
  return observed == msgdma::kStatusTransferDone;
}

void wait_for_transfer(JtagSession& session, const Port& port) {
  if (transfer_finished(session, port)) {
    return;
  }
  throw std::runtime_error("The " + std::string(port.label) +
                           " port did not complete its transfer. Status register " +
                           to_hex(port.dma_csr_addr + msgdma::kCsrStatus) +
                           " did not read " + to_hex(msgdma::kStatusTransferDone) + ".");
}

// Pop the response the dispatcher parks after each completed descriptor, so the
// next transfer starts from a known status value.
void clear_dma_responses(JtagSession& session, const Port& port) {
  const uint32_t response =
      port.dma_descriptor_addr + msgdma::kResponseOffsetFromDescriptor;
  session.send_command("master_read_32", session.master_path(), to_hex(response),
                       msgdma::kResponseWords);
}

// Weight dumps are named weights_ddr_<bank>_<byte offset>.bin. Returns false for
// any other file
bool parse_weight_file_name(const std::string& name, uint32_t& bank, uint64_t& offset) {
  unsigned long parsed_bank = 0;
  unsigned long long parsed_offset = 0;
  int consumed = 0;
  if (std::sscanf(name.c_str(), "weights_ddr_%lu_%llu.bin%n", &parsed_bank,
                  &parsed_offset, &consumed) != 2) {
    return false;
  }
  // sscanf stops at the first mismatch
  if (consumed != static_cast<int>(name.size())) {
    return false;
  }
  bank = static_cast<uint32_t>(parsed_bank);
  offset = static_cast<uint64_t>(parsed_offset);
  return true;
}

// The frequency the fitter actually reached, which generate_sof.tcl records once
// the bitstream is assembled. Returns 0 when the file is not there
double read_kernel_clk_mhz() {
  for (const char* candidate : {"kernel_clk.json", "../kernel_clk.json"}) {
    std::ifstream file(candidate);
    if (!file) {
      continue;
    }
    // The file holds one key, so a targeted scan beats pulling in a parser
    std::string text((std::istreambuf_iterator<char>(file)),
                     std::istreambuf_iterator<char>());
    const size_t key = text.find("\"kernel_clk_mhz\"");
    if (key == std::string::npos) {
      continue;
    }
    const size_t colon = text.find(':', key);
    if (colon == std::string::npos) {
      continue;
    }
    try {
      const double mhz = std::stod(text.substr(colon + 1));
      if (mhz > 0.0) {
        return mhz;
      }
    } catch (const std::exception&) {
      // Fall through to the next candidate
    }
  }
  return 0.0;
}

}  // namespace

int reset(void) {
  try {
    JtagSession& session = require_session();
    session.assert_reset();  // ISSP global reset
    // Every span extender comes out of reset pointing at page 0
    g_window_page.clear();
    initialize_dmas(session);
    // EMIF calibration runs after reset
    wait_until_ddr_reachable(session);
  } catch (const std::exception& e) {
    std::cerr << "[reset] Error: " << e.what() << std::endl;
    return -1;
  }
  return 0;
}

int run_inference(const std::vector<uint64_t>& input_data,
                  std::vector<uint64_t>& output_data) {
  try {
    JtagSession& session = require_session();

    const Port input = make_port(true);
    const Port output = make_port(false);
    if (input.subvectors_per_beat() == 0 || output.subvectors_per_beat() == 0) {
      throw std::runtime_error(
          "A port subvector is wider than the 256-bit EMIF beat.");
    }

    // The packet counts describe one tensor, so the length of the input
    // divided by this is the number of inferences to run
    const unsigned elems_per_tensor = input.tensor_elems();
    if (elems_per_tensor == 0 || input_data.empty() ||
        input_data.size() % elems_per_tensor != 0) {
      throw std::runtime_error(
          "Input holds " + std::to_string(input_data.size()) +
          " elements, which is not a whole number of " +
          std::to_string(elems_per_tensor) + " element tensors.");
    }
    const unsigned tensors = static_cast<unsigned>(input_data.size() / elems_per_tensor);

    // These are padded
    const uint64_t input_bytes = tensors * input.tensor_bytes();
    const uint64_t output_bytes = tensors * output.tensor_bytes();

    // The IP sees one continuous stream, so a batch is just more packets
    std::vector<uint8_t> staged_input(static_cast<size_t>(input_bytes), 0);
    for (unsigned tensor = 0; tensor < tensors; tensor++) {
      pack_tensor(input, &input_data[static_cast<size_t>(tensor) * elems_per_tensor],
                  &staged_input[static_cast<size_t>(tensor) * input.tensor_bytes()]);
    }

    check_in_region(input, input_bytes, "Input staging");
    // Write all the input tensors to DDR
    write_ddr(session, design::kFeatureBank, input.ddr_base_addr, staged_input.data(),
              input_bytes);

    // Enable output before input
    queue_descriptor(session, output, output_bytes);
    queue_descriptor(session, input, input_bytes);
    wait_for_transfer(session, input);
    wait_for_transfer(session, output);

    std::vector<uint8_t> staged_output(static_cast<size_t>(output_bytes), 0);
    check_in_region(output, output_bytes, "Output readback");
    read_ddr(session, design::kFeatureBank, output.ddr_base_addr, staged_output.data(),
             output_bytes);

    output_data.assign(static_cast<size_t>(tensors) * output.tensor_elems(), 0);
    for (unsigned tensor = 0; tensor < tensors; tensor++) {
      unpack_tensor(output, &staged_output[static_cast<size_t>(tensor) * output.tensor_bytes()],
                    &output_data[static_cast<size_t>(tensor) * output.tensor_elems()]);
    }

    clear_dma_responses(session, input);
    clear_dma_responses(session, output);
  } catch (const std::exception& e) {
    std::cerr << "[run_inference] Error: " << e.what() << std::endl;
    return -1;
  }
  return 0;
}

int load_weights_buffer(const uint64_t* weights_data, size_t weights_bytes,
                        uint64_t start_addr, uint64_t bank_number) {
  try {
    JtagSession& session = require_session();
    write_ddr(session, static_cast<uint32_t>(bank_number), start_addr, weights_data,
              weights_bytes);
  } catch (const std::exception& e) {
    std::cerr << "[load_weights_buffer] Error: " << e.what() << std::endl;
    return -1;
  }
  return 0;
}

int load_weights_from_file(const char* filepath) {
  if (filepath == nullptr) {
    return -1;
  }
  try {
    JtagSession& session = require_session();

    const fs::path path(filepath);
    uint32_t bank = 0;
    uint64_t offset = 0;
    if (!parse_weight_file_name(path.filename().string(), bank, offset)) {
      throw std::runtime_error(std::string(filepath) +
                               " is not named weights_ddr_<bank>_<offset>.bin.");
    }

    // The offset in the file name is where the IP will read from, so the window
    // needs to move accordingly. This offset is also called the local DDR address
    const uint64_t bytes = static_cast<uint64_t>(fs::file_size(path));

    // Check limits on weights in the feature bank
    if (bank == design::kFeatureBank &&
        (bytes > design::kFeatureBankWeightLimit ||
         offset > design::kFeatureBankWeightLimit - bytes)) {
      throw std::runtime_error(
          std::string(filepath) + " would write " + std::to_string(bytes) +
          " bytes at offset " + std::to_string(offset) +
          " of DDR bank " + std::to_string(bank) +
          ", which overlaps the input and output tensor regions that start at byte " +
          std::to_string(design::kFeatureBankWeightLimit) + ".");
    }
    write_ddr_from_file(session, bank, offset, path.string(), bytes);
    verify_weight_write(session, bank, offset, path.string(), bytes);

    std::cout << "Loaded " << path.filename().string() << " (" << bytes
              << " bytes) into DDR bank " << bank << " at byte " << offset << std::endl;
  } catch (const std::exception& e) {
    std::cerr << "[load_weights_from_file] Error: " << e.what() << std::endl;
    return -1;
  }
  return 0;
}

int load_weights(const char* dir_path) {
  if (dir_path == nullptr) {
    return -1;
  }
  try {
    require_session();

    if (!fs::is_directory(dir_path)) {
      throw std::runtime_error("Weight directory " + std::string(dir_path) +
                               " does not exist. It is the dump_files directory the "
                               "compiler wrote next to the IP.");
    }

    std::vector<fs::path> paths;
    for (const auto& entry : fs::directory_iterator(dir_path)) {
      if (fs::is_regular_file(entry.path())) {
        paths.push_back(entry.path());
      }
    }
    std::sort(paths.begin(), paths.end());

    // A model whose weights all fit in MIF ROMs has no dumps here, and that is
    // the only signal the runtime gets that this bitstream has no weight bank
    for (const fs::path& path : paths) {
      uint32_t bank = 0;
      uint64_t offset = 0;
      if (!parse_weight_file_name(path.filename().string(), bank, offset)) {
        continue;
      }
      if (load_weights_from_file(path.string().c_str()) != 0) {
        return -1;
      }
    }
  } catch (const std::exception& e) {
    std::cerr << "[load_weights] Error: " << e.what() << std::endl;
    return -1;
  }
  return 0;
}

double read_timer_us(void) {
  JtagSession& session = require_session();
  const unsigned cycles = session.read_32(session.master_path(), design::kTimerBaseAddr);

  const double mhz = read_kernel_clk_mhz();
  if (mhz <= 0.0) {
    std::cerr << "Warning: no kernel_clk.json, reporting " << cycles
              << " cycles as microseconds" << std::endl;
    return cycles;
  }
  return cycles / mhz;
}
