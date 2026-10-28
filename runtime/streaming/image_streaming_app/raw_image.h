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
#include <cstdint>
#include <filesystem>
#include <memory>
#include <vector>
#include "ILayoutTransform.h"
#include "bmp_file.h"
#include "float16.h"

#include <cstddef>
#include <cstdlib>
#include <stdexcept>

using AlignedVecUint16 = std::vector<uint16_t, aligned_allocator<uint16_t, kMsgDMAMaxBurstBytes>>;

class RawImage {
 public:
  RawImage(std::filesystem::path filePath,
           bool disableExternalLayoutTransform,
           bool runLayoutTransform,
           const ILayoutTransform::Configuration& ltConfiguration);
  uint8_t* GetData();
  size_t GetSize();
  std::string Filename() { return _filePath; }
  bool DumpLayoutTransform();
  static AlignedVecUint16 LayoutTransform(uint32_t width,
                                          uint32_t height,
                                          const AlignedVecUint8& sourceData,
                                          const ILayoutTransform::Configuration& ltConfiguration);
  static std::vector<uint8_t> MakePlanar(uint32_t width, uint32_t height, const std::vector<uint8_t>& data);
  bool IsValid();

 private:
  static void GenerateLayoutIndexes(const ILayoutTransform::Configuration& ltConfiguration);
  void LayoutTransform(const ILayoutTransform::Configuration& ltConfiguration);
  static AlignedVecUint16 LayoutTransform(const AlignedVecUint8& sourceData,
                                          uint32_t numPixels,
                                          const ILayoutTransform::Configuration& ltConfiguration);

  std::filesystem::path _filePath;
  std::shared_ptr<BmpFile> _spBmpFile;
  AlignedVecUint16 _layoutTransformData;
  static std::vector<int32_t> _indexes;
  bool _runLayoutTransform = false;
  bool _disableExternalLayoutTransform = false;
  ILayoutTransform::Configuration _ltConfiguration;
};
