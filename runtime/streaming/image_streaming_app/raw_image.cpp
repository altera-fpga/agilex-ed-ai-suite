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

#include "raw_image.h"
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <cassert>

std::vector<int32_t> RawImage::_indexes;

RawImage::RawImage(std::filesystem::path filePath,
                   bool disableExternalLayoutTransform,
                   bool runLayoutTransform,
                   const ILayoutTransform::Configuration& ltConfiguration)
    : _filePath(filePath), _disableExternalLayoutTransform(disableExternalLayoutTransform), _ltConfiguration(ltConfiguration) {
  std::string extension = filePath.extension();
  std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);
  if (extension == ".lt") {
    uintmax_t fileSize = std::filesystem::file_size(filePath);
    size_t elems = fileSize / sizeof(uint16_t);
    // --- Pad to next multiple of 64 bytes ---
    size_t padded_elems = ((elems * sizeof(uint16_t) + 63) / 64) * (64 / sizeof(uint16_t));
    _layoutTransformData.resize(padded_elems, 0);
    std::ifstream layoutFile(filePath, std::fstream::binary);
    layoutFile.read((char*)_layoutTransformData.data(), fileSize);
    // If padded, already zeroed.
  } else {
    bool planar = runLayoutTransform;
    _spBmpFile = std::make_shared<BmpFile>(filePath, disableExternalLayoutTransform, planar);
    if (_runLayoutTransform) LayoutTransform(_ltConfiguration);
  }
}

uint8_t* RawImage::GetData() {
  if (_runLayoutTransform)
    return reinterpret_cast<uint8_t*>(_layoutTransformData.data());
  else
    return _spBmpFile->GetData().data();
}

size_t RawImage::GetSize() {
  if (_runLayoutTransform)
    return _layoutTransformData.size() * sizeof(uint16_t);
  else
    return _spBmpFile->GetData().size();
}

bool RawImage::IsValid()
{
    size_t channels = _disableExternalLayoutTransform ? 3 : 4;
    size_t dlaImageSize = 224 * 224 * channels;

    return (GetSize() == dlaImageSize);
}

  AlignedVecUint16  RawImage::LayoutTransform(uint32_t width,
                                              uint32_t height,
                                              const AlignedVecUint8& sourceData,
                                              const ILayoutTransform::Configuration& ltConfiguration) {
  uint32_t numPixels = width * height;
  AlignedVecUint16 layoutTransformData = LayoutTransform(sourceData, numPixels, ltConfiguration);
  return layoutTransformData;
}

void RawImage::LayoutTransform(const ILayoutTransform::Configuration& ltConfiguration) {
  const AlignedVecUint8& sourceData = _spBmpFile->GetData();
  uint32_t numPixels = _spBmpFile->GetNumPixels();
  _layoutTransformData = LayoutTransform(sourceData, numPixels, ltConfiguration);
}

AlignedVecUint16 RawImage::LayoutTransform(const AlignedVecUint8& sourceData,
                                           uint32_t numPixels,
                                           const ILayoutTransform::Configuration& ltConfiguration) {
  if (_indexes.empty()) GenerateLayoutIndexes(ltConfiguration);

  uint32_t numChannels = 3;
  uint32_t numSamples = numPixels * numChannels;

  AlignedVecUint16 meanAdjustedData(numSamples);
  const uint8_t* pSourceData = sourceData.data();

  const uint8_t* pBlueSourcePlane = pSourceData;
  const uint8_t* pGreenSourcePlane = pBlueSourcePlane + numPixels;
  const uint8_t* pRedSourcePlane = pGreenSourcePlane + numPixels;

  // First adjust by subtracting the means values
  std::vector<float> meanAdjustedFloat32(numSamples);
  float* pBlueFloat32 = &meanAdjustedFloat32[0];
  float* pGreenFloat32 = pBlueFloat32 + numPixels;
  float* pRedFloat32 = pGreenFloat32 + numPixels;

  for (uint32_t i = 0; i < numPixels; i++) {
    *pBlueFloat32++ = static_cast<float>(*pBlueSourcePlane++) + ltConfiguration._blueShift;
    *pGreenFloat32++ = static_cast<float>(*pGreenSourcePlane++) + ltConfiguration._greenShift;
    *pRedFloat32++ = static_cast<float>(*pRedSourcePlane++) + ltConfiguration._redShift;
  }

  pBlueFloat32 = &meanAdjustedFloat32[0];
  pGreenFloat32 = pBlueFloat32 + numPixels;
  pRedFloat32 = pGreenFloat32 + numPixels;
  uint16_t* pBlueDestinationPlane = &meanAdjustedData[0];
  uint16_t* pGreenDestinationPlane = pBlueDestinationPlane + numPixels;
  uint16_t* pRedDestinationPlane = pGreenDestinationPlane + numPixels;

  for (uint32_t i = 0; i < numPixels; i++) {
    *pBlueDestinationPlane++ = Float16(*pBlueFloat32++);
    *pGreenDestinationPlane++ = Float16(*pGreenFloat32++);
    *pRedDestinationPlane++ = Float16(*pRedFloat32++);
  }

  // Now map the data to the layout expected by the DLA
  size_t nLayoutEntries = _indexes.size();
  AlignedVecUint16 layoutTransformData(nLayoutEntries);

  for (size_t outputIndex = 0; outputIndex < nLayoutEntries; outputIndex++) {
    int32_t inputIndex = _indexes[outputIndex];
    if (inputIndex >= 0)
      layoutTransformData[outputIndex] = meanAdjustedData[inputIndex];
    else
      layoutTransformData[outputIndex] = 0;
  }
  // --- Pad to full DMA burst size (data width × max burst count) ---
  constexpr size_t kMaxBurstSize = kMsgDMAMaxBurstBytes;
  size_t elems = layoutTransformData.size();
  size_t padded_bytes = dla::util::nextDivisible(elems * sizeof(uint16_t), kMaxBurstSize);
  size_t padded_elems = padded_bytes / sizeof(uint16_t);
  layoutTransformData.resize(padded_elems, 0);

  // Debug check
  assert(layoutTransformData.size() * sizeof(uint16_t) % kMaxBurstSize == 0 && "layoutTransformData is not full-burst padded!");
  return layoutTransformData;
}

bool RawImage::DumpLayoutTransform() {
  if (!_spBmpFile) return false;

  std::filesystem::path filePath(_filePath);
  filePath.replace_extension("raw");
  std::ofstream rawRgbaFile(filePath, std::fstream::binary);
  if (rawRgbaFile.bad()) return false;

  uint32_t numPixels = _spBmpFile->GetNumPixels();
  uint32_t numChannels = 4;
  uint32_t numSamples = numPixels * numChannels;
  std::vector<uint8_t> buffer(numSamples);
  uint8_t* pSourceData = _spBmpFile->GetData().data();

  uint8_t* pBlueSourcePlane = pSourceData;
  uint8_t* pGreenSourcePlane = pBlueSourcePlane + numPixels;
  uint8_t* pRedSourcePlane = pGreenSourcePlane + numPixels;
  uint8_t* pDestination = buffer.data();

  for (uint32_t i = 0; i < numPixels; i++) {
    *pDestination++ = *pBlueSourcePlane++;
    *pDestination++ = *pGreenSourcePlane++;
    *pDestination++ = *pRedSourcePlane++;
    *pDestination++ = 0;
  }

  rawRgbaFile.write((char*)buffer.data(), buffer.size());

  filePath.replace_extension("lt");
  std::ofstream transformFile(filePath, std::fstream::binary);
  if (transformFile.bad()) return false;

  transformFile.write((char*)GetData(), GetSize());

  return true;
}

// Convert from RGBA to planar BGR
std::vector<uint8_t> RawImage::MakePlanar(uint32_t width, uint32_t height, const std::vector<uint8_t>& data) {
  uint32_t channelSize = width * height;
  std::vector<uint8_t> planarData(channelSize * 3);
  uint8_t* pBPlane = planarData.data();
  uint8_t* pGPlane = pBPlane + channelSize;
  uint8_t* pRPlane = pGPlane + channelSize;
  const uint8_t* pInputRGBA = data.data();

  for (uint32_t i = 0; i < channelSize; i++) {
    *pRPlane++ = *pInputRGBA++;
    *pGPlane++ = *pInputRGBA++;
    *pBPlane++ = *pInputRGBA++;

    // Skip alpha channel
    uint8_t alpha = *pInputRGBA++;
    alpha = alpha;
  }

  return planarData;
}

void RawImage::GenerateLayoutIndexes(const ILayoutTransform::Configuration& ltConfiguration) {
  size_t nEntries = ltConfiguration._width * ltConfiguration._height * ltConfiguration._cVector;

  uint32_t c_vector = ltConfiguration._cVector;
  uint32_t width_stride = 1;
  uint32_t height_stride = 1;
  uint32_t input_width = ltConfiguration._width;
  uint32_t input_height = ltConfiguration._height;
  uint32_t input_channels = 3;
  uint32_t output_width = ltConfiguration._width;
  uint32_t output_width_banked = ltConfiguration._width;
  uint32_t output_height = ltConfiguration._height;
  uint32_t pad_left = 0;
  uint32_t pad_top = 0;

  _indexes.resize(nEntries, -1);

  for (uint32_t c = 0; c < input_channels; c++) {
    for (uint32_t h = 0; h < input_height; h++) {
      for (uint32_t w = 0; w < input_width; w++) {
        uint32_t output_w = (w + pad_left) / width_stride;
        uint32_t output_h = (h + pad_top) / height_stride;
        uint32_t output_d = c * height_stride * width_stride + ((h + pad_top) % height_stride) * width_stride +
                            (w + pad_left) % width_stride;
        uint32_t output_d_c_vector = output_d / c_vector;
        uint32_t cvec = output_d % c_vector;
        uint32_t inIndex = c * input_height * input_width + h * input_width + w;

        uint32_t outIndex = (output_d_c_vector * output_height * output_width_banked * c_vector) +
                            (output_h * output_width_banked * c_vector) + (output_w * c_vector) + cvec;

        if ((output_h < output_height) && (output_w < output_width)) {
          _indexes[outIndex] = static_cast<int32_t>(inIndex);
        }
      }
    }
  }
}
