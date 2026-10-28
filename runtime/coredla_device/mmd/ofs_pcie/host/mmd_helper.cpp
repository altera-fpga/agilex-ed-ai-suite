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

#include "mmd_helper.h"
#include <inttypes.h>

namespace mmd_helper {

int read_mmio(fpga_handle mmio_handle, void *host_addr, size_t mmio_addr, size_t size) {
  fpga_result res = FPGA_OK;

  MMD_DEBUG("DEBUG LOG : Device::read_mmio start: host_addr : %p\t mmio_addr : 0x%zx\t size : 0x%zx\n",
            host_addr,
            mmio_addr,
            size);

  if (mmio_addr % 4 != 0) {
    MMD_DEBUG("DEBUG LOG : ead_mmio function doesn't support non 4 Byte aligned mmio_addr due to OPAE\n");
    return -1;
  }

  uint64_t *host_addr64 = static_cast<uint64_t *>(host_addr);

  while (size >= 8) {
    MMD_DEBUG("DEBUG LOG : Using fpgaReadMMIO64()       host_addr : %p\t mmio_addr : 0x%zx\t size : 0x8\n",
              host_addr64,
              mmio_addr);
    res = fpgaReadMMIO64(mmio_handle, 0, mmio_addr, host_addr64);
    if (res != FPGA_OK) {
      MMD_DEBUG(
          "DEBUG LOG : Error in read_mmio() host_addr : %p\t mmio_addr : 0x%zx\t size : 0x8\n", host_addr64, mmio_addr);
      return -1;
    }
    MMD_DEBUG("DEBUG LOG : the host_addr64 value is ");
    MMD_DEBUG("%" PRIu64 "\n", *host_addr64);
    host_addr64 += 1;
    mmio_addr += 8;
    size -= 8;
  }

  uint32_t *host_addr32 = reinterpret_cast<uint32_t *>(host_addr64);
  while (size >= 4) {
    MMD_DEBUG("DEBUG LOG : Using fpgaReadMMIO32()       host_addr : %p\t mmio_addr : 0x%zx\t size : 0x4\n",
              host_addr32,
              mmio_addr);
    res = fpgaReadMMIO32(mmio_handle, 0, mmio_addr, host_addr32);
    if (res != FPGA_OK) {
      MMD_DEBUG(
          "DEBUG LOG : Error in read_mmio() host_addr : %p\t mmio_addr : 0x%zx\t size : 0x4\n", host_addr32, mmio_addr);
      return -1;
    }
    host_addr32 += 1;
    mmio_addr += 4;
    size -= 4;
  }

  if (size > 0) {
    uint32_t read_data;
    MMD_DEBUG("DEBUG LOG : Using fpgaReadMMIO32()       host_addr : %p\t mmio_addr : 0x%zx\t size : 0x%zx\n",
              host_addr,
              mmio_addr,
              size);
    res = fpgaReadMMIO32(mmio_handle, 0, mmio_addr, &read_data);
    if (res != FPGA_OK) {
      MMD_DEBUG("DEBUG LOG : Error in read_mmio() host_addr : %p\t mmio_addr : 0x%zx\t size : 0x%zx\n",
                host_addr,
                mmio_addr,
                size);
      MMD_DEBUG("result is %d \n", res);
      return -1;
    }

    memcpy(host_addr32, &read_data, size);
  }

  return res;
}

int write_mmio(fpga_handle mmio_handle, const void *host_addr, size_t mmio_addr, size_t size) {
  fpga_result res = FPGA_OK;

  MMD_DEBUG("DEBUG LOG : Device::write_mmio start: host_addr : %p\t mmio_addr : 0x%zx\t size : 0x%zx\n",
            host_addr,
            mmio_addr,
            size);

  const uint64_t *host_addr64 = static_cast<const uint64_t *>(host_addr);
  while (size >= 8) {
    MMD_DEBUG("DEBUG LOG : Using fpgaWriteMMIO64()       host_addr : %p\t mmio_addr : 0x%zx\t \n",
              host_addr64,
              mmio_addr);
    res = fpgaWriteMMIO64(mmio_handle, 0, mmio_addr, *host_addr64);
    if (res != FPGA_OK) {
      MMD_DEBUG("DEBUG LOG : Error in write_mmio() host_addr : %p\t mmio_addr : 0x%zx\t \n",
                host_addr64,
                mmio_addr);
      return -1;
    }
    host_addr64 += 1;
    mmio_addr += 8;
    size -= 8;
  }

  const uint32_t *host_addr32 = reinterpret_cast<const uint32_t *>(host_addr64);

  while (size >= 4) {
    MMD_DEBUG("DEBUG LOG : Using fpgaWriteMMIO32()       host_addr : %p\t mmio_addr : 0x%zx\t \n",
              host_addr32,
              mmio_addr);
    res = fpgaWriteMMIO32(mmio_handle, 0, mmio_addr, *host_addr32);
    if (res != FPGA_OK) {
      MMD_DEBUG("DEBUG LOG : Error in write_mmio() host_addr : %p\t mmio_addr : 0x%zx\t\n",
                host_addr32,
                mmio_addr);
      return -1;
    }
    host_addr32 += 1;
    mmio_addr += 4;
    size -= 4;
  }

  while (size > 0) {
    MMD_DEBUG("DEBUG LOG : Using fpgaWriteMMIO32()       host_addr : %p\t mmio_addr : 0x%zx\t size : 0x%zx\n",
              host_addr32,
              mmio_addr,
              size);
    uint32_t tmp_data32 = 0;
    fpgaReadMMIO32(mmio_handle, 0, mmio_addr, &tmp_data32);  // First read the data back
    size_t chunk_size = (size >= 4) ? 4 : size;

    memcpy(&tmp_data32, host_addr32, chunk_size);  // Apply our data overlay

    res = fpgaWriteMMIO32(mmio_handle, 0, mmio_addr, tmp_data32);
    if (res != FPGA_OK) {
      MMD_DEBUG("DEBUG LOG : Error in write_mmio() host_addr : %p\t mmio_addr : 0x%zx\t size : 0x%zx\n",
                host_addr32,
                mmio_addr,
                size);
      return -1;
    }
    host_addr32 += 1;
    mmio_addr += chunk_size;
    size -= chunk_size;
  }

  return 0;
}

};  // namespace mmd_helper
