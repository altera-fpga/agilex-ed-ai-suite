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

#include "LayoutTransform.h"
#include <thread>

std::shared_ptr<ILayoutTransform> ILayoutTransform::Create() { return std::make_shared<LayoutTransform>(); }

LayoutTransform::LayoutTransform() { _spUioDevice = UIO::IDevice::Load("layout_transform"); }

static uint32_t FloatToUint32(float value) {
  union FloatAndUint32 {
    float _floatValue;
    uint32_t _uint32Value;
  };
  FloatAndUint32 convertType;
  convertType._floatValue = value;
  return convertType._uint32Value;
}

void LayoutTransform::SetConfiguration(Configuration& configuration) {
  _configuration = configuration;

  if (_spUioDevice) {
    _spUioDevice->Write((uint32_t)RegisterMap::RESET, 1u);
    std::this_thread::sleep_for(std::chrono::milliseconds(1));
    _spUioDevice->Write((uint32_t)RegisterMap::RESET, 0u);

    _spUioDevice->Write((uint32_t)RegisterMap::C_VECT, _configuration._cVector);
    _spUioDevice->Write((uint32_t)RegisterMap::WIDTH, _configuration._width);
    _spUioDevice->Write((uint32_t)RegisterMap::HEIGHT, _configuration._height);

    _spUioDevice->Write((uint32_t)RegisterMap::VARIANCES + 0, FloatToUint32(_configuration._blueVariance));
    _spUioDevice->Write((uint32_t)RegisterMap::VARIANCES + 1, FloatToUint32(_configuration._greenVariance));
    _spUioDevice->Write((uint32_t)RegisterMap::VARIANCES + 2, FloatToUint32(_configuration._redVariance));

    _spUioDevice->Write((uint32_t)RegisterMap::SHIFTS + 0, FloatToUint32(_configuration._blueShift));
    _spUioDevice->Write((uint32_t)RegisterMap::SHIFTS + 1, FloatToUint32(_configuration._greenShift));
    _spUioDevice->Write((uint32_t)RegisterMap::SHIFTS + 2, FloatToUint32(_configuration._redShift));
  }
}
