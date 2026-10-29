// (c) 1992-2024 Intel Corporation.
// Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words
// and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.
// and/or other countries. Other marks and brands may be claimed as the property
// of others. See Trademarks on intel.com for full list of Intel trademarks or
// the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera)
// Your use of Intel Corporation's design tools, logic functions and other
// software and tools, and its AMPP partner logic functions, and any output
// files any of the foregoing (including device programming or simulation
// files), and any associated documentation or information are expressly subject
// to the terms and conditions of the Altera Program License Subscription
// Agreement, Intel MegaCore Function License Agreement, or other applicable
// license agreement, including, without limitation, that your use is for the
// sole purpose of programming logic devices manufactured by Intel and sold by
// Intel or its authorized distributors.  Please refer to the applicable
// agreement for further details.
#ifndef MMD_DMA_H_
#define MMD_DMA_H_

#include <opae/fpga.h>
#include <poll.h>

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <mutex>
#include <queue>
#include <thread>
#include <unordered_map>

#include "aocl_mmd.h"
#include "mmd_helper.h"

#define DMA_CSR_IDX_SRC_ADDR 0x5
#define DMA_CSR_IDX_STATUS 0x9
#define MODE_SHIFT 26
#ifdef USE_AGX5_MDK
// For now limits to 8K to avoid DMA transfer hang in hw, further testing required to increase the value.
// This is due to the 256 beat limit of AXI4 bursts (8k bytes = 256 x 256 bits per word)
#define DMA_BUFFER_SIZE (1024 * 8)
#else
// For now limits to 16K to avoid DMA transfer hang in hw, further testing required to increase the value.
// This is due to the 256 beat limit of AXI4 bursts (16k bytes = 256 x 512 bits per word)
#define DMA_BUFFER_SIZE (1024 * 16)
#endif


// AGX7 uses a 512-bit wide data path between PCIe and FPGA DDR (through DMA)
// AGX5 uses a 256-bit wide data path between PCIe and FPGA DDR (through DMA)
#ifdef USE_AGX5_MDK
#define DMA_LINE_SIZE 32
#else
#define DMA_LINE_SIZE 64
#endif

#define DMA_HOST_MASK 0x2000000000000

#define ASE_MMIO_BASE 0x20000
#define ASE_MMIO_CTRL 0x200
#define ASE_MMIO_WINDOW 0x1000

namespace intel_opae_mmd {

enum dma_mode { stand_by = 0x0, host_to_ddr = 0x1, ddr_to_host = 0x2, ddr_to_ddr = 0x3 };

struct dma_descriptor_t {
  uint64_t src_address;
  uint64_t dest_address;
  uint32_t len;
  uint32_t control;
};

class mmd_dma final {
 public:
  mmd_dma(fpga_handle fpga_handle_arg, int mmd_handle);
  ~mmd_dma();

  bool initialized() { return m_initialized; }

  int fpga_to_host(void *host_addr, uint64_t dev_src, size_t size);
  int host_to_fpga(const void *host_addr, uint64_t dev_dest, size_t size);
  int dma_transfer(uint64_t dev_src, uint64_t dev_dest, int len, dma_mode descriptor_mode);
  fpga_result _ase_host_to_fpga(uint64_t dev_dest, const void *src_ptr, uint64_t count);
  fpga_result _ase_fpga_to_host(uint64_t dev_dest, void *host_ptr, uint64_t count);
  mmd_dma(mmd_dma &other) = delete;
  mmd_dma &operator=(const mmd_dma &other) = delete;

 private:
  // Helper functions
  int send_descriptor(uint64_t mmio_dst, dma_descriptor_t desc);
  // Member variables
  bool m_initialized;
  fpga_handle m_fpga_handle;

  // Shared buffer in host memory
  uint64_t *dma_buf_ptr = NULL;
  // Workspace ID used by OPAE to identify buffer
  uint64_t dma_buf_wsid;
  // IO virtual address
  uint64_t dma_buf_iova;
};

};  // namespace intel_opae_mmd

#endif  // MMD_DMA_H_
