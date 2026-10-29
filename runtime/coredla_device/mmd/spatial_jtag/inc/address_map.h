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

#ifndef SPATIAL_JTAG_ADDRESS_MAP_H
#define SPATIAL_JTAG_ADDRESS_MAP_H

#include <cstdint>


// This example design builds one input and one output only, so the Avalon memory
// mapped region below is fixed. This same comment is found in setup_project.py
//
// Timer (16 bytes) at 0x00000000
//   |_ Cycle count, latched when the inference ends (4 bytes)
//   |_ Status (4 bytes)
//   |_ Live cycle count, while an inference is running (4 bytes)
//   |_ 0 (4 bytes)
//
// mSGDMA (128 bytes total). The 64 byte ingress msgdma descriptor begins at
// 0x00000020 and the 64 byte egress msgdma at 0x00000060. Both are 256 bits
// wide, matching the EMIF beat and the spatial IP I/O ports
//   Each descriptor:
//   CSR (32 bytes)
//   |_ CSR status (4 bytes)
//   |_ CSR Control (4 bytes)
//   |_ reserved (24 bytes)
//   Descriptor (32 bytes)
//   |_ Descriptor read address, low word (4 bytes)
//   |_ Descriptor write address, low word (4 bytes)
//   |_ Descriptor length (4 bytes)
//   |_ Descriptor sequence number and burst counts (4 bytes)
//   |_ Descriptor read and write stride (4 bytes)
//   |_ Descriptor read address, high word (4 bytes)
//   |_ Descriptor write address, high word (4 bytes)
//   |_ Descriptor control (4 bytes)
//
// Address span extender control (32 bytes total). DDR bank 0 begins
// at 0x00000100 and bank 1 begins at 0x00000110 -> 16 bytes per bank
// Per bank:
//   |_ Window byte base, low word (4 bytes)
//   |_ Window byte base, high word (4 bytes)
//
// DDR windows (2GB windows total) at 0x40000000 for bank 0 and 0x80000000 for bank 1.
// Bank 0 carries weights and the input and output tensors. Bank 1 carries
// weights only. A design with no DDR-offloaded weights still brings up bank 0
// so the mSGDMAs have somewhere to stage features.

// ===========================================================================
// THE CONSTANTS IN THIS NAMESPACE MUST MATCH setup_project.py EXACTLY.
//
// setup_project.py lays the Avalon map and the DDR regions out, then renders
// them into system.qsys through system.tcl. It hands the runtime only the port
// geometry, in port_config.json, so every base address the host drives is
// declared here instead and nothing checks that the two agree
//
// ANY EDIT HERE MUST BE MADE IN
// external/platform/agx5e_modular_spatial_jtag/setup_project.py IN THE SAME
// CHANGE, AND THE OTHER WAY AROUND. The comment beside each value names its
// counterpart.
// ===========================================================================
namespace design {

                                                          // constant name in setup_project.py
constexpr uint32_t kTimerBaseAddr = 0x00000000;           // TIMER_BASE_ADDR
constexpr uint32_t kDmaIngressBaseAddr = 0x00000020;      // DMA_INGRESS_BASE_ADDR
constexpr uint32_t kDmaEgressBaseAddr = 0x00000060;       // DMA_EGRESS_BASE_ADDR
constexpr uint32_t kDmaDescriptorOffset = 0x00000020;     // DMA_DESCRIPTOR_OFFSET
constexpr uint32_t kSpanExtenderCntlBase = 0x00000100;    // SPAN_EXTENDER_CNTL_BASE
constexpr uint32_t kSpanExtenderCntlStride = 0x00000010;  // SPAN_EXTENDER_CNTL_STRIDE
constexpr uint32_t kDdrBankBaseAddr = 0x40000000;         // DDR_BANK_BASE_ADDR

constexpr unsigned kDdrChannelWidth = 256;                // DDR_CHANNEL_WIDTH
constexpr unsigned kDdrBeatBytes = kDdrChannelWidth / 8;
// Host datapath, both mSGDMAs, and the spatial IP I/O ports are one EMIF beat
constexpr unsigned kStreamWidth = kDdrChannelWidth;

constexpr uint32_t kFeatureBank = 0;                      // FEATURE_BANK
constexpr uint64_t kDdrWindowSize = 0x40000000;           // DDR_WINDOW_SIZE
constexpr uint64_t kDdrBankCapacityBytes = 8ULL << 30;    // DDR_BANK_CAPACITY_BYTES

constexpr uint64_t kFeatureRegionBytes = 1ULL << 30;      // FEATURE_REGION_BYTES
constexpr uint64_t kInputFeatureBase =
    kDdrBankCapacityBytes - 2 * kFeatureRegionBytes;      // INPUT_FEATURE_BASE
constexpr uint64_t kOutputFeatureBase =
    kDdrBankCapacityBytes - kFeatureRegionBytes;          // OUTPUT_FEATURE_BASE
constexpr uint64_t kFeatureBankWeightLimit = kInputFeatureBase;  // FEATURE_BANK_WEIGHT_LIMIT

// The following functions return addresses in the JTAG-to-Avalon map

// Get the start of `bank` 1GB window
constexpr uint32_t window_base_addr(uint32_t bank) {
  return kDdrBankBaseAddr + bank * static_cast<uint32_t>(kDdrWindowSize);
}

// Get the span extender for `bank`
constexpr uint32_t window_cntl_addr(uint32_t bank) {
  return kSpanExtenderCntlBase + bank * kSpanExtenderCntlStride;
}

// Get the csr address for the input or output port
constexpr uint32_t dma_csr_addr(bool is_input) {
  return is_input ? kDmaIngressBaseAddr : kDmaEgressBaseAddr;
}

// Get the descriptor address for the input or output port
constexpr uint32_t dma_descriptor_addr(bool is_input) {
  return dma_csr_addr(is_input) + kDmaDescriptorOffset;
}

// Byte address inside the feature DDR bank where the port's tensors are staged
constexpr uint64_t ddr_base_addr(bool is_input) {
  return is_input ? kInputFeatureBase : kOutputFeatureBase;
}

// Whole subvectors that fit in one 256-bit beat. Leftover MSBs are padding.
// Returns 0 when the subvector is wider than the beat, which setup_project.py
// should have already rejected
constexpr unsigned subvectors_per_beat(unsigned dw, unsigned num_lanes) {
  const unsigned subvector_bits = dw * num_lanes;
  if (subvector_bits == 0 || subvector_bits > kStreamWidth) {
    return 0;
  }
  return kStreamWidth / subvector_bits;
}

// Number of emif beats to transport an entire tensor packet
constexpr unsigned beats_per_packet(unsigned dw, unsigned num_lanes, unsigned sub_vectors) {
  const unsigned per_beat = subvectors_per_beat(dw, num_lanes);
  if (per_beat == 0) {
    return 0;
  }
  // ceil(number of subvectors in packet / subvectors in one emif beat)
  return (sub_vectors + per_beat - 1) / per_beat;
}

}  // namespace design

namespace msgdma {

// Offsets into the CSR slave, relative to design::dma_csr_addr()
constexpr uint32_t kCsrStatus = 0x0;
constexpr uint32_t kCsrControl = 0x4;

// mSGDMA CSR values to control the dispatcher
constexpr uint32_t kControlReset = 0x2;
constexpr uint32_t kControlStop = 0x20;
constexpr uint32_t kControlRun = 0x0;

// Value of the msgdma CSR when a transfer has completed
constexpr uint32_t kStatusTransferDone = 0x2;

// Offsets into the msgdma descriptor, relative to design::dma_descriptor_addr()
constexpr uint32_t kDescriptorReadAddress = 0x0;
constexpr uint32_t kDescriptorWriteAddress = 0x4;
constexpr uint32_t kDescriptorLength = 0x8;
constexpr uint32_t kDescriptorReadAddressHigh = 0x14;
constexpr uint32_t kDescriptorWriteAddressHigh = 0x18;
constexpr uint32_t kDescriptorControl = 0x1C;

// Start transfer bit written to descriptor control address
constexpr uint32_t kDescriptorGo = 1u << 31;

// Offset from design::dma_descriptor_addr()
constexpr uint32_t kResponseOffsetFromDescriptor = 0x10;
constexpr unsigned kResponseWords = 2;

}  // namespace msgdma

namespace span_extender {

// Offsets into a bank's cntl slave, relative to design::window_cntl_addr()
constexpr uint32_t kWindowBaseLow = 0x0;
constexpr uint32_t kWindowBaseHigh = 0x4;

}  // namespace span_extender

#endif  // SPATIAL_JTAG_ADDRESS_MAP_H
