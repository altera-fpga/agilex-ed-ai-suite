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

#include <memory.h>
#include <sys/mman.h>
#include <cassert>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <unordered_map>

#include <inttypes.h>
#include <sstream>

#include "mmd_device.h"
#include "mmd_dma.h"
#include "mmd_helper.h"

namespace intel_opae_mmd {

/** mmd_dma class constructor
 */
mmd_dma::mmd_dma(fpga_handle fpga_handle_arg, int mmd_handle) : m_initialized(false), m_fpga_handle(fpga_handle_arg) {
  MMD_DEBUG("DEBUG LOG : Constructing DMA \n");
  // Initialize shared buffer
  auto res = fpgaPrepareBuffer(m_fpga_handle, DMA_BUFFER_SIZE, (void **)&dma_buf_ptr, &dma_buf_wsid, 0);

  assert(FPGA_OK == res && "Allocating DMA Buffer failed");

  memset((void *)dma_buf_ptr, 0x0, DMA_BUFFER_SIZE);

  // Store virtual address of IO registers
  res = fpgaGetIOAddress(m_fpga_handle, dma_buf_wsid, &dma_buf_iova);
  assert(FPGA_OK == res && "getting dma DMA_BUF_IOVA failed");

  m_initialized = true;
}

/** mmd_dma destructor
 *  free-ing , releasing various resources created during object construction is a good idea
 *  it helps with system stability and reduces code bugs
 */
mmd_dma::~mmd_dma() {
  MMD_DEBUG("DEBUG LOG : Destructing DMA \n");
  auto res = fpgaReleaseBuffer(m_fpga_handle, dma_buf_wsid);
  assert(FPGA_OK == res && "Release DMA Buffer failed");
  m_initialized = false;
}

// Called in dma_transfer() to send DMA descriptor
int mmd_dma::send_descriptor(uint64_t mmio_dst, dma_descriptor_t desc) {
  // mmio requires 8 byte alignment
  assert(mmio_dst % 8 == 0);

  fpgaWriteMMIO64(m_fpga_handle, 0, mmio_dst, desc.src_address);
  MMD_DEBUG("Writing %lX to address %lX\n", desc.src_address, mmio_dst);
  mmio_dst += 8;
  fpgaWriteMMIO64(m_fpga_handle, 0, mmio_dst, desc.dest_address);
  MMD_DEBUG("Writing %lX to address %lX\n", desc.dest_address, mmio_dst);
  mmio_dst += 8;
  fpgaWriteMMIO64(m_fpga_handle, 0, mmio_dst, desc.len);
  MMD_DEBUG("Writing %X to address %lX\n", desc.len, mmio_dst);
  mmio_dst += 8;
  fpgaWriteMMIO64(m_fpga_handle, 0, mmio_dst, desc.control);
  MMD_DEBUG("Writing %X to address %lX\n", desc.control, mmio_dst);

  return 0;
}

// Use ASE to handle unaligned transfer and DMA to do aligned transfer.
int mmd_dma::fpga_to_host(void *host_addr, uint64_t dev_src, size_t size) {
  fpga_result res = FPGA_OK;
  uint64_t count_left = size;
  uint64_t aligned_addr = 0;
  uint64_t align_bytes = 0;
  uint64_t curr_dev_src = dev_src;
  void *curr_host_addr = host_addr;

  if (dev_src % DMA_LINE_SIZE != 0) {
    // We use ASE to handle unaligned DMA transfer
    MMD_DEBUG("DEBUG LOG : mmd_dma::fpga_to_host dev_src is non %dB aligned\n", DMA_LINE_SIZE);
    if (count_left < DMA_LINE_SIZE) {
      MMD_DEBUG("DEBUG LOG : mmd_dma::fpga_to_host dev_src count < %d\n", DMA_LINE_SIZE);
      res = _ase_fpga_to_host(curr_dev_src, curr_host_addr, count_left);
      assert(FPGA_OK == res && "_ase_fpga_to_host failed");
      return res;
    } else {
      aligned_addr = ((curr_dev_src / DMA_LINE_SIZE) + 1) * DMA_LINE_SIZE;
      align_bytes = aligned_addr - curr_dev_src;
      res = _ase_fpga_to_host(curr_dev_src, curr_host_addr, align_bytes);
      assert(FPGA_OK == res && "_ase_fpga_to_host failed");

      // Update the processed data
      count_left -= align_bytes;
      curr_dev_src += align_bytes;
      curr_host_addr = (void *)(static_cast<char *>(curr_host_addr) + align_bytes);
    }
  }

  if (count_left) {
    uint64_t dma_chunks = count_left / DMA_BUFFER_SIZE;
    for (uint64_t i = 0; i < dma_chunks; i++) {
      // constant size transfer

      uint64_t dev_dest = dma_buf_iova | DMA_HOST_MASK;
      int len = ((DMA_BUFFER_SIZE - 1) / DMA_LINE_SIZE) + 1;  // Ceiling of test_buffer_size / DMA_LINE_SIZE

      dma_transfer(curr_dev_src, dev_dest, len, ddr_to_host);

      // Copy data from shared buffer to host addr
      memcpy(curr_host_addr, (void *)dma_buf_ptr, DMA_BUFFER_SIZE);

      memset((void *)dma_buf_ptr, 0x0, DMA_BUFFER_SIZE);

      // Update the curr source and dest
      curr_host_addr = (void *)(static_cast<char *>(curr_host_addr) + DMA_BUFFER_SIZE);
      curr_dev_src += DMA_BUFFER_SIZE;
    }

    // Updated the count_left for the for loop
    count_left -= (dma_chunks * DMA_BUFFER_SIZE);

    if (count_left) {
      uint64_t dma_tx_bytes = (count_left / DMA_LINE_SIZE) * DMA_LINE_SIZE;
      if (dma_tx_bytes != 0) {
        assert(dma_tx_bytes <= DMA_BUFFER_SIZE && "Illegal transfer size\n");

        uint64_t dev_dest = dma_buf_iova | DMA_HOST_MASK;
        int len = ((dma_tx_bytes - 1) / DMA_LINE_SIZE) + 1;  // Ceiling of test_buffer_size / DMA_LINE_SIZE

        dma_transfer(curr_dev_src, dev_dest, len, ddr_to_host);

        // Copy data from shared buffer to host addr
        memcpy(curr_host_addr, (void *)dma_buf_ptr, dma_tx_bytes);

        memset((void *)dma_buf_ptr, 0x0, DMA_BUFFER_SIZE);

        // Update the address
        curr_host_addr = (void *)(static_cast<char *>(curr_host_addr) + dma_tx_bytes);
        curr_dev_src += dma_tx_bytes;
        count_left -= dma_tx_bytes;
      }
      if (count_left) {
        MMD_DEBUG("DEBUG LOG : mmd_dma::fpga_to_host count_left after DMA transfer is ");
        MMD_DEBUG("%" PRIu64 "\n", count_left);
        // Handle the rest unaligned transfer using ASE
        res = _ase_fpga_to_host(curr_dev_src, curr_host_addr, count_left);
        if (FPGA_OK != res) {
          MMD_DEBUG("DEBUG LOG : mmd_dma::_ase_fpga_to_host failed\n");
          return -1;
        }
        count_left = 0;

        // No need to update address as the transaction is done.
      }
    }
  }
  assert(count_left==0 && "fpga_to_host failed");
  return 0;
}

// Use ASE to handle unaligned transfer and DMA to do aligned transfer.
int mmd_dma::host_to_fpga(const void *host_addr, uint64_t dev_dest, size_t size) {
  fpga_result res = FPGA_OK;
  uint64_t count_left = size;
  uint64_t aligned_addr = 0;
  uint64_t align_bytes = 0;
  uint64_t curr_dest = dev_dest;
  const void *curr_host_addr = host_addr;

  if (dev_dest % DMA_LINE_SIZE != 0) {
    // We use ASE to handle unaligned DMA transfer
    MMD_DEBUG("DEBUG LOG : mmd_dma::host_to_fpga dev_dest is non %dB aligned\n", DMA_LINE_SIZE);
    if (count_left < DMA_LINE_SIZE) {
      res = _ase_host_to_fpga(dev_dest, host_addr, count_left);
      assert(FPGA_OK == res && "_ase_host_to_fpga failed");
      return res;
    } else {
      aligned_addr = ((dev_dest / DMA_LINE_SIZE) + 1) * DMA_LINE_SIZE;
      align_bytes = aligned_addr - dev_dest;
      res = _ase_host_to_fpga(dev_dest, host_addr, align_bytes);
      assert(FPGA_OK == res && "_ase_host_to_fpga failed");

      // Update the processed data
      count_left -= align_bytes;
      curr_dest += align_bytes;
      curr_host_addr = (const void *)(static_cast<const char *>(curr_host_addr) + align_bytes);
    }
  }

  if (count_left) {
    uint64_t dma_chunks = count_left / DMA_BUFFER_SIZE;
    for (uint64_t i = 0; i < dma_chunks; i++) {
      // constant size transfer
      // Copy host_src value to the shared buffer
      memcpy((void *)dma_buf_ptr, curr_host_addr, DMA_BUFFER_SIZE);
      uint64_t dev_src = dma_buf_iova | DMA_HOST_MASK;

      int len = ((DMA_BUFFER_SIZE - 1) / DMA_LINE_SIZE) + 1;  // Ceiling of test_buffer_size / DMA_LINE_SIZE

      dma_transfer(dev_src, curr_dest, len, host_to_ddr);

      memset((void *)dma_buf_ptr, 0x0, DMA_BUFFER_SIZE);

      // Update the curr source and dest
      curr_host_addr = (const void *)(static_cast<const char *>(curr_host_addr) + DMA_BUFFER_SIZE);
      curr_dest += DMA_BUFFER_SIZE;
    }

    // Updated the count_left for the for loop
    count_left -= (dma_chunks * DMA_BUFFER_SIZE);

    if (count_left) {
      uint64_t dma_tx_bytes = (count_left / DMA_LINE_SIZE) * DMA_LINE_SIZE;
      if (dma_tx_bytes != 0) {
        assert(dma_tx_bytes <= DMA_BUFFER_SIZE && "Illegal transfer size\n");

        // Copy host_src value to the shared buffer
        memcpy((void *)dma_buf_ptr, curr_host_addr, dma_tx_bytes);
        uint64_t dev_src = dma_buf_iova | DMA_HOST_MASK;

        int len = ((dma_tx_bytes - 1) / DMA_LINE_SIZE) + 1;  // Ceiling of dma_tx_bytes / DMA_LINE_SIZE
        dma_transfer(dev_src, curr_dest, len, host_to_ddr);

        memset((void *)dma_buf_ptr, 0x0, DMA_BUFFER_SIZE);
      }

      // Update the address
      curr_host_addr = (const void *)(static_cast<const char *>(curr_host_addr) + dma_tx_bytes);
      curr_dest += dma_tx_bytes;
      count_left -= dma_tx_bytes;

      if (count_left) {
        MMD_DEBUG("DEBUG LOG : mmd_dma::host_to_fpga count_left after DMA transfer is ");
        MMD_DEBUG("%" PRIu64 "\n", count_left);
        // Handle the rest unaligned transfer using ASE
        res = _ase_host_to_fpga(curr_dest, curr_host_addr, count_left);
        assert(FPGA_OK == res && "_ase_host_to_fpga failed");
        count_left = 0;
      }
    }
  }
  assert(count_left==0 && "host_to_fpga failed");
  return 0;
}

int mmd_dma::dma_transfer(uint64_t dev_src, uint64_t dev_dest, int len, dma_mode descriptor_mode) {

  // Get debug information for thread id
  std::stringstream ss;
  ss << std::this_thread::get_id();
  uint64_t id = std::stoull(ss.str());
  MMD_DEBUG("dma_transfer start current thread_id is %04lX\n", id);

  // Native DMA transfer requires DMA_LINE_SIZE byte alignment
  assert(dev_src % DMA_LINE_SIZE == 0);
  assert(dev_dest % DMA_LINE_SIZE == 0);

  const uint64_t MASK_FOR_35BIT_ADDR = 0x7FFFFFFFF;

  dma_descriptor_t desc;

  MMD_DEBUG("DEBUG LOG : mmd_dma::dma_transfer starts\n");
  MMD_DEBUG("DEBUG LOG dev_dest = %04lX\n", dev_dest);

  desc.src_address = dev_src & MASK_FOR_35BIT_ADDR;
  desc.dest_address = dev_dest & MASK_FOR_35BIT_ADDR;
  desc.len = len;
  desc.control = 0x80000000 | (descriptor_mode << MODE_SHIFT);

  const uint64_t DMA_DESC_BASE = 8 * DMA_CSR_IDX_SRC_ADDR;
  const uint64_t DMA_STATUS_BASE = 8 * DMA_CSR_IDX_STATUS;
  uint64_t mmio_data = 0;

  int desc_size = sizeof(desc);

  MMD_DEBUG("Descriptor size   = %d\n", desc_size);
  MMD_DEBUG("desc.src_address  = %04lX\n", desc.src_address);
  MMD_DEBUG("desc.dest_address = %04lX\n", desc.dest_address);
  MMD_DEBUG("desc.len          = %d\n", desc.len);
  MMD_DEBUG("desc.control      = %04X\n", desc.control);
  MMD_DEBUG("descriptor_mode   = %04X\n", descriptor_mode);

  // send descriptor
  send_descriptor(DMA_DESC_BASE, desc);

  fpga_result r;
  r = fpgaReadMMIO64(m_fpga_handle, 0, DMA_STATUS_BASE, &mmio_data);
  MMD_DEBUG("DMA_STATUS_BASE before = %04lX\n", mmio_data);
  if (FPGA_OK != r) return -1;

  // If the busy bit is empty, then we are done.
  while ((mmio_data & 0x1) == 0x1) {
    r = fpgaReadMMIO64(m_fpga_handle, 0, DMA_STATUS_BASE, &mmio_data);
    assert(FPGA_OK == r);
  }
  MMD_DEBUG("dma_transfer end current thread_id is %04lX\n", id);
  return 0;
}

// Transfer "count" bytes from HOST to FPGA using Address span expander(ASE)- will internally make
// calls to handle unaligned and aligned MMIO writes.
fpga_result mmd_dma::_ase_host_to_fpga(uint64_t dev_dest, const void *src_ptr, uint64_t count) {
  MMD_DEBUG("DEBUG LOG: _ase_host_to_fpga is being called\n ");

  MMD_DEBUG("DEBUG LOG : dev_dest is ");
  MMD_DEBUG("%" PRIu64 "\n", dev_dest);

  assert(count < DMA_LINE_SIZE);  // DLA only uses ASE transfer with less than DMA_LINE_SIZE Byte transfer.

  fpga_result res = FPGA_OK;
  uint64_t count_left = count;
  uint64_t unaligned_size = 0;

  // For ASE window
  uint64_t ase_window;
  uint64_t ase_addr;
  uint64_t dev_addr;

  const void *curr_src_ptr = src_ptr;

  if (count == 0) return res;

  if (dev_dest % 8 == 0) {
    while (count > 0) {
      ase_window = dev_dest & ~(0xfff);
      ase_addr = (dev_dest & 0xfff);  // only keep the lower 12 bits.

      uint64_t mmio_base_control = ASE_MMIO_BASE + ASE_MMIO_CTRL;

      MMD_DEBUG("DEBUG LOG : ase_window is ");
      MMD_DEBUG("%" PRIu64 "\n", ase_window);

      // Write to ASE control
      res = fpgaWriteMMIO64(m_fpga_handle, 0, mmio_base_control, ase_window);
      assert(res == FPGA_OK && "Write to ASE control failed");

      // Set final dev_addr
      // dev_addr will be 8 byte aligned as long as dev_dest is 8 byte aligned.
      dev_addr = ASE_MMIO_BASE + ASE_MMIO_WINDOW + ase_addr;

      assert(dev_addr % 8 == 0);

      MMD_DEBUG("DEBUG LOG  : _ase_host_to_fpga count is ");
      MMD_DEBUG("%" PRIu64 "\n", count);

      MMD_DEBUG("DEBUG LOG : dev addr is ");
      MMD_DEBUG("%" PRIu64 "\n", dev_addr);

      size_t size = (count > 8) ? 8 : count;
      mmd_helper::write_mmio(m_fpga_handle, curr_src_ptr, dev_addr, size);

      count -= size;
      dev_dest += size;
      curr_src_ptr = (const void *)(static_cast<const char *>(curr_src_ptr) + size);
    }

    assert(count == 0);

  } else {
    // First we need to handle the non byte aligned transfer

    MMD_DEBUG("DEBUG LOG  :  _ase_host_to_fpga count is ");
    MMD_DEBUG("%" PRIu64 "\n", count);

    // Aligns address to 8 byte using dst masking method
    unaligned_size = 8 - (dev_dest % 8);
    if (unaligned_size > count_left) unaligned_size = count_left;

    // Write to the unaligned address
    assert(unaligned_size < 8);
    uint64_t shift = dev_dest % 8;

    // Write to ASE control to switch page.
    ase_window = dev_dest & ~(0xfff);

    MMD_DEBUG("DEBUG LOG  : ase_window in non-aligned is ");
    MMD_DEBUG("%" PRIu64 "\n", ase_window);

    fpgaWriteMMIO64(m_fpga_handle, 0, ASE_MMIO_BASE + ASE_MMIO_CTRL, ase_window);

    // Get aligned dest address
    uint64_t dev_aligned_addr = dev_dest - shift;
    assert(dev_aligned_addr % 8 == 0);

    // read data from device memory with aligned dev dest
    ase_addr = (dev_aligned_addr & 0xfff);
    dev_addr = ASE_MMIO_BASE + ASE_MMIO_WINDOW + ase_addr;
    uint64_t read_tmp = 0;
    fpgaReadMMIO64(m_fpga_handle, 0, dev_addr, &read_tmp);

    // overlay our data, check if the shift is correct here
    memcpy((reinterpret_cast<char *>(&read_tmp) + shift), src_ptr, unaligned_size);

    // Write back data to the device
    fpgaWriteMMIO64(m_fpga_handle, 0, dev_addr, read_tmp);

    count_left -= unaligned_size;

    // Check if there is any byte left
    if (count_left == 0) {
      return res;
    }

    // Now the dest address should be byte aligned now
    // Start the regular ASE transfer

    const void *curr_src_ptr = (const void *)(static_cast<const char *>(src_ptr) + unaligned_size);
    uint64_t next_dev_dest = dev_dest + unaligned_size;

    while (count_left > 0) {
      ase_window = next_dev_dest & ~(0xfff);
      ase_addr = (next_dev_dest & 0xfff);  // only keep the lower 12 bits.

      MMD_DEBUG("DEBUG LOG  : ase_window in non-aligned loop is ");
      MMD_DEBUG("%" PRIu64 "\n", ase_window);

      // Write to ASE control
      fpgaWriteMMIO64(m_fpga_handle, 0, ASE_MMIO_BASE + ASE_MMIO_CTRL, ase_window);

      // Set final dev_addr
      dev_addr = ASE_MMIO_BASE + ASE_MMIO_WINDOW + ase_addr;

      assert(dev_addr % 8 == 0);

      size_t size = (count_left > 8) ? 8 : count_left;
      mmd_helper::write_mmio(m_fpga_handle,
                             curr_src_ptr,
                             dev_addr,
                             size);

      count_left -= size;
      next_dev_dest += size;
      curr_src_ptr = (const void *)(static_cast<const char *>(curr_src_ptr) + size);
    }
    assert(count_left == 0);
  }

  return FPGA_OK;
}

// Transfer "count" bytes from FPGA to HOST using Address span expander(ASE)- will internally make
// calls to handle unaligned and aligned MMIO reads.
fpga_result mmd_dma::_ase_fpga_to_host(uint64_t dev_dest, void *host_ptr, uint64_t count) {
  MMD_DEBUG("DEBUG LOG  : _ase_fpga_to_host is being called\n ");

  assert(count < DMA_LINE_SIZE);

  fpga_result res = FPGA_OK;
  uint64_t count_left = count;
  uint64_t unaligned_size = 0;

  // For ASE window

  uint64_t ase_window;
  uint64_t ase_addr;
  uint64_t dev_addr;

  if (count == 0) return res;

  void *curr_host_ptr = host_ptr;

  if (dev_dest % 8 == 0) {
    while (count > 0) {
      ase_window = dev_dest & ~(0xfff);
      ase_addr = (dev_dest & 0xfff);  // only keep the lower 12 bits.

      MMD_DEBUG("DEBUG LOG : ase_window is ");
      MMD_DEBUG("%" PRIu64 "\n", ase_window);

      // Write to ASE control to switch page.
      fpgaWriteMMIO64(m_fpga_handle, 0, ASE_MMIO_BASE + ASE_MMIO_CTRL, ase_window);

      // Set final dev_addr
      // dev_addr will be 8 byte aligned as long as dev_dest is 8 byte aligned.
      dev_addr = ASE_MMIO_BASE + ASE_MMIO_WINDOW + ase_addr;

      assert(dev_addr % 8 == 0);

      size_t size = (count > 8) ? 8 : count;

      mmd_helper::read_mmio(m_fpga_handle, curr_host_ptr, dev_addr, size);

      count -= size;
      dev_dest += size;
      curr_host_ptr = (void *)(static_cast<char *>(curr_host_ptr) + size);
    }

  } else {
    // First we need to handle the non byte aligned transfer

    // Aligns address to 8 byte using dst masking method
    unaligned_size = 8 - (dev_dest % 8);
    if (unaligned_size > count_left) unaligned_size = count_left;

    // Write to the unaligned address
    assert(unaligned_size < 8);
    uint64_t shift = dev_dest % 8;

    // Write to ASE control to switch page.
    ase_window = dev_dest & ~(0xfff);

    MMD_DEBUG("DEBUG LOG : ase_window is ");
    MMD_DEBUG("%" PRIu64 "\n", ase_window);

    fpgaWriteMMIO64(m_fpga_handle, 0, ASE_MMIO_BASE + ASE_MMIO_CTRL, ase_window);

    // Get aligned dest address
    uint64_t dev_aligned_addr = dev_dest - shift;
    assert(dev_aligned_addr % 8 == 0);

    // read data from device memory with aligned dev dest
    ase_addr = (dev_aligned_addr & 0xfff);
    dev_addr = ASE_MMIO_BASE + ASE_MMIO_WINDOW + ase_addr;

    uint64_t read_tmp = 0;
    fpgaReadMMIO64(m_fpga_handle, 0, dev_addr, &read_tmp);

    // overlay our data
    memcpy(host_ptr, (reinterpret_cast<char *>(&read_tmp) + shift), unaligned_size);

    count_left -= unaligned_size;

    // Check if there is any byte left
    if (count_left == 0) {
      return res;
    }

    // Now the dest address should be byte aligned now
    // Start the regular ASE transfer
    curr_host_ptr = (void *)(static_cast<char *>(host_ptr) + unaligned_size);
    uint64_t next_dev_dest = dev_dest + unaligned_size;

    while (count_left > 0) {
      ase_window = next_dev_dest & ~(0xfff);
      ase_addr = (next_dev_dest & 0xfff);  // only keep the lower 12 bits.

      // Write to ASE control to switch page.
      fpgaWriteMMIO64(m_fpga_handle, 0, ASE_MMIO_BASE + ASE_MMIO_CTRL, ase_window);

      // Set final dev_addr
      dev_addr = ASE_MMIO_BASE + ASE_MMIO_WINDOW + ase_addr;

      assert(dev_addr % 8 == 0);

      size_t size = (count_left > 8) ? 8 : count_left;
      mmd_helper::read_mmio(m_fpga_handle, curr_host_ptr, dev_addr, size);

      count_left -= size;
      next_dev_dest += size;
      curr_host_ptr = (void *)(static_cast<char *>(curr_host_ptr) + size);
    }

    assert(count_left == 0);
  }
  return FPGA_OK;
}
}  // namespace intel_opae_mmd
