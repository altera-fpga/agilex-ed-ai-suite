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

#include "bmp_file.h"
#include <cstdlib>
#include <cstring>
#include <fstream>

BmpFile::BmpFile(const std::string& filename, bool disableExternalLayoutTransform, bool planarBGR) {
  bool loaded = LoadFile(filename, disableExternalLayoutTransform, planarBGR);
  (void)loaded;
}

bool BmpFile::LoadFile(const std::string& filename, bool disableExternalLayoutTransform, bool planarBGR) {
  std::ifstream inputFile(filename, std::fstream::binary);
  if (inputFile.bad()) {
    return false;
  }

  // Read signature
  uint16_t fileSignature = 0;
  if (!inputFile.read((char*)&fileSignature, sizeof(fileSignature))) {
    return false;
  }

  if (fileSignature != 0x4d42) {
    return false;
  }

  // Read file size
  uint32_t fileSize = 0;
  if (!inputFile.read((char*)&fileSize, sizeof(fileSize))) {
    return false;
  }

  if (fileSize > (8192 * 4320 * 3)) { // Check excessive file size
    return false;
  }

  // Reserved
  uint32_t unused = 0;
  if (!inputFile.read((char*)&unused, sizeof(unused))) {
    return false;
  }

  // Read data offset
  uint32_t dataOffset = 0;
  if (!inputFile.read((char*)&dataOffset, sizeof(dataOffset))) {
    return false;
  }

  if ((dataOffset >= fileSize) or (dataOffset == 0)) {
    return false;
  }

  // Read bitmap header
  BitmapHeader infoHeader{};
  if (!inputFile.read((char*)&infoHeader, sizeof(infoHeader))) {
    return false;
  }

  uint32_t headerSize = sizeof(infoHeader);
  uint32_t header4Size = 108;  // sizeof(BITMAPV4HEADER);
  uint32_t header5Size = 124;  // sizeof(BITMAPV5HEADER);
  if ((infoHeader._size != headerSize) and (infoHeader._size != header4Size) and (infoHeader._size != header5Size)) {
    return false;
  }

  int palletteSize = infoHeader._colorUsed;
  std::vector<uint32_t> pallette;
  if ((infoHeader._bitCount < 16) and (infoHeader._colorUsed == 0) and (infoHeader._bitCount != 1)) {
    palletteSize = 1 << infoHeader._bitCount;
  }

  if (palletteSize > 0) {
    // V3 Pallette follows 4 bytes per entry
    pallette.resize(palletteSize);
    if (!inputFile.read((char*)pallette.data(), pallette.size())) {
      return false;
    }
  }

  inputFile.seekg(dataOffset);

  uint32_t height = static_cast<uint32_t>(std::abs(infoHeader._height));
  size_t dataSize = static_cast<size_t>(infoHeader._sizeImage);
  uint32_t nPixels = height * static_cast<uint32_t>(infoHeader._width);

  if (infoHeader._bitCount == 32) {
    dataSize = height * infoHeader._width * 4;
  } else if (infoHeader._bitCount == 16) {
    dataSize = height * infoHeader._width * 2;
  } else if (infoHeader._bitCount == 8) {
    if (dataSize == 0) dataSize = height * infoHeader._width;  // 8 bit data - through pallette
  } else {
    uint32_t line_length = infoHeader._width;
    if ((infoHeader._bitCount == 24) and ((infoHeader._width % 4) != 0)) {
      line_length = (infoHeader._width + 4) & ~3;
    }
    dataSize = height * line_length * 3;
  }

  std::vector<uint8_t> _temporaryBuffer;
  bool useTemporaryBuffer = (infoHeader._bitCount == 16) or (infoHeader._bitCount == 1) or (palletteSize > 0);

  if (useTemporaryBuffer) {
    _temporaryBuffer.resize(dataSize);
    if (!inputFile.read((char*)_temporaryBuffer.data(), dataSize)) return false;
  } else {
    _data.resize(dataSize);
    if (!inputFile.read((char*)_data.data(), dataSize)) return false;
  }

  if (infoHeader._bitCount == 16) {
    int inputStride = infoHeader._sizeImage / height;

    dataSize = nPixels * 4;
    _data.resize(dataSize);
    uint32_t* pOutputScan = reinterpret_cast<uint32_t*>(_data.data());

    for (uint32_t y = 0; y < height; y++) {
      uint8_t* pInputLineStart = _temporaryBuffer.data() + (y * inputStride);
      uint16_t* pInputScan = (uint16_t*)pInputLineStart;

      for (int x = 0; x < infoHeader._width; x++) {
        uint16_t inputValue = *pInputScan++;
        uint32_t r = ((inputValue & 0x7C00) >> 10) * 8;
        uint32_t g = ((inputValue & 0x3E0) >> 5) * 8;
        uint32_t b = ((inputValue & 0x1f) * 8);

        *pOutputScan++ = 0xff000000 | r << 16 | g << 8 | b;
      }
    }

    infoHeader._bitCount = 32;
  } else if (infoHeader._bitCount == 1) {
    int inputStride = infoHeader._sizeImage / height;

    dataSize = nPixels * 4;
    _data.resize(dataSize);
    uint32_t* pOutputScan = reinterpret_cast<uint32_t*>(_data.data());

    for (uint32_t y = 0; y < height; y++) {
      uint8_t* pInputLineStart = _temporaryBuffer.data() + (y * inputStride);
      uint8_t* pInputScan = pInputLineStart;

      uint16_t inputValue = *pInputScan++;
      for (int x = 0; x < infoHeader._width; x++) {
        int bit = x % 8;
        if (bit == 0) {
          inputValue = *pInputScan++;
        }

        int bit_mask = 1 << (7 - bit);

        if ((inputValue & bit_mask) == 0)
          *pOutputScan++ = 0xff000000;
        else
          *pOutputScan++ = 0xffffffff;
      }
    }

    infoHeader._bitCount = 32;
  }

  if (palletteSize > 0) {
    // we're using a pallette - convert _buffer using pallette
    _data.resize(dataSize * sizeof(uint32_t));
    uint32_t* pOutputScan = reinterpret_cast<uint32_t*>(_data.data());
    infoHeader._bitCount = 32;  // pretend were now 32 bits as that is format of Pallette
    for (size_t i = 0; i < dataSize; i++) {
      *pOutputScan++ = pallette[_temporaryBuffer[i]];
    }
  }

  _height = height;
  _width = infoHeader._width;
  _bitsPerPixel = infoHeader._bitCount;

  uint32_t lineLengthBytes = (_width * _bitsPerPixel) / 8;

  if ((_bitsPerPixel == 24) and ((lineLengthBytes % 4) != 0)) {
    _stride = (lineLengthBytes + 4) & ~3;
  } else {
    _stride = lineLengthBytes;
  }

  _upsideDown = (infoHeader._height > 0);

  // BMP channel order is BGR, as required by ResNet
  if (_upsideDown) {
    AlignedVecUint8 flippedData(_data.size());
    for (uint32_t y = 0; y < _height; y++) {
      uint8_t* pDestinationLine = flippedData.data() + (y * _stride);
      uint8_t* pSourceLine = _data.data() + ((_height - y - 1) * _stride);

      std::memcpy(pDestinationLine, pSourceLine, _stride);
    }

    _data = flippedData;
  }

  if (!disableExternalLayoutTransform) {
    // This preprocessing is only needed for the external LT which expects an alpha channel.
    if (planarBGR) {
      uint32_t channelSize = _width * _height;
      AlignedVecUint8 planarData(_data.size());
      uint8_t* pBPlane = planarData.data();
      uint8_t* pGPlane = pBPlane + channelSize;
      uint8_t* pRPlane = pGPlane + channelSize;
      uint8_t* pInputBGR = _data.data();

      for (uint32_t i = 0; i < channelSize; i++) {
        *pBPlane++ = *pInputBGR++;
        *pGPlane++ = *pInputBGR++;
        *pRPlane++ = *pInputBGR++;

        // Skip alpha channel
        if (infoHeader._bitCount == 32) {
          pInputBGR++;
        }
      }

      _data = planarData;
    } else {
      uint32_t channelSize = _width * _height;

      // Must be 32bpp
      if (infoHeader._bitCount == 32) {
        // Swap endianness
        uint8_t* pInputBGR = _data.data();

        for (uint32_t i = 0; i < channelSize; i++) {
          uint8_t b = pInputBGR[0];
          uint8_t g = pInputBGR[1];
          uint8_t r = pInputBGR[2];
          uint8_t a = pInputBGR[3];

          pInputBGR[0] = a;
          pInputBGR[1] = r;
          pInputBGR[2] = g;
          pInputBGR[3] = b;

          pInputBGR += 4;
        }
      } else {
        AlignedVecUint8 newData(channelSize * 4);
        uint8_t* pInputBGR = _data.data();
        uint8_t* pOutputBGRA = newData.data();
        for (uint32_t i = 0; i < channelSize; i++) {
          uint8_t b = pInputBGR[0];
          uint8_t g = pInputBGR[1];
          uint8_t r = pInputBGR[2];

          pOutputBGRA[0] = 0;
          pOutputBGRA[1] = r;
          pOutputBGRA[2] = g;
          pOutputBGRA[3] = b;

          pInputBGR += 3;
          pOutputBGRA += 4;
        }

        _data = newData;
      }
    }
  }

  return true;
}
