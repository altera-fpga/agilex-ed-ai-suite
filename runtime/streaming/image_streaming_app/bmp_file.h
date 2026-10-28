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
#include <string>
#include <vector>

#include <cstddef>
#include <cstdlib>
#include <stdexcept>

#include "dla_aligned_allocator.h"
using AlignedVecUint8 = std::vector<uint8_t, aligned_allocator<uint8_t, kMsgDMAMaxBurstBytes>>;

struct BitmapHeader {
  uint32_t _size;
  int32_t _width;
  int32_t _height;
  uint16_t _planes;
  uint16_t _bitCount;
  uint32_t _compression;
  uint32_t _sizeImage;
  int32_t _xPixelsPerMeter;
  int32_t _yPixelsPerMeter;
  uint32_t _colorUsed;
  uint32_t _colorImportant;
};

class BmpFile {
 public:
  BmpFile(const std::string& filename, bool disableExternalLayoutTransform, bool planarBGR);
  AlignedVecUint8& GetData() { return _data; }
  uint32_t GetNumPixels() { return (_width * _height); }

 private:
  bool LoadFile(const std::string& filename, bool disableExternalLayoutTransform, bool planarBGR);
  AlignedVecUint8 _data;
  uint32_t _width = 0;
  uint32_t _height = 0;
  uint32_t _bitsPerPixel = 0;
  uint32_t _stride = 0;
  bool _upsideDown = false;
};
