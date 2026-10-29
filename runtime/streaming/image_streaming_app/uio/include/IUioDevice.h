// Copyright 2023 Altera Corporation.
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

#pragma once
#include <filesystem>
#include <memory>
#include <string>
#include <vector>

namespace UIO {
class DeviceItem {
 public:
  std::string _name;
  uint32_t _index;
  std::string _indexedName;
  std::filesystem::path _rootPath;
};

class IDevice {
 public:
  static std::shared_ptr<IDevice> Load(const std::string& deviceName, uint32_t index = 0);
  static std::vector<DeviceItem> GetDevices();

  virtual uint32_t Read(uint32_t registerIndex) = 0;
  virtual void Write(uint32_t registerIndex, uint32_t value) = 0;
  virtual void ReadBlock(void* host_addr, size_t offset, size_t size) = 0;
  virtual void WriteBlock(const void* host_addr, size_t offset, size_t size) = 0;
};

}  // namespace UIO
