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
#include <memory>

class ILayoutTransform {
 public:
  class Configuration {
   public:
    uint32_t _width;
    uint32_t _height;
    uint32_t _cVector;
    float _blueVariance;
    float _greenVariance;
    float _redVariance;
    float _blueShift;
    float _greenShift;
    float _redShift;
  };

  virtual ~ILayoutTransform() {}
  virtual void SetConfiguration(Configuration& configuration) = 0;

  static std::shared_ptr<ILayoutTransform> Create();
};
