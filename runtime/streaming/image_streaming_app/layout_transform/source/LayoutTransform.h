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
#include <memory>
#include "ILayoutTransform.h"
#include "IUioDevice.h"

enum class RegisterMap : uint32_t {
  RESET = 0,
  C_VECT,
  WIDTH,
  HEIGHT,
  VARIANCES = 0x10,  // to 0x1f
  SHIFTS = 0x20,     // to 0x2f
};

class LayoutTransform : public ILayoutTransform {
 public:
  LayoutTransform();

  // ILayoutTransform interface
  void SetConfiguration(Configuration& configuration) override;

 private:
  ILayoutTransform::Configuration _configuration = {};
  std::shared_ptr<UIO::IDevice> _spUioDevice;
};
