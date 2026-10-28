// Copyright 2023 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Intel's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

/*
Copyright (C) 2009 Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
 * This file helps with conversion to/from fp16.  The contents of this file are duplicated
 * in at least four places, just to ensure they are not accidentally lost:
 *
 * 1) runtime/plugin/io_transformations/dlia_fp.hpp.
 * 3) runtime/streaming/image_streaming_app/float16.h
 * 4) util/inc/dla_element.h (internal)
 *
 * The algorithm for conversion to fp16 is described in this 2008 paper by Jeroen van der Zijp
 * http://www.fox-toolkit.org/ftp/fasthalffloatconversion.pdf
 *
 * We received this code, I am told, by way of OpenVINO.  As best as I can infer from
 * the copyright header and available bits of discussion on the web, OpenVINO seems to have
 * copied this from Webkit.
 */

#pragma once

#include <cstdint>
#include <cstring>

class Float16 {
 public:
  Float16(float value) {
    // This method is used by the CoreDLA plugin, it is not binary equivalent
    // to f32to16 (below) used by OpenVino
    union FloatAndUint32 {
      float _floatValue;
      uint32_t _uint32Value;
    };
    FloatAndUint32 convertType;
    convertType._floatValue = value;

    uint32_t floatBits = convertType._uint32Value;
    uint32_t shiftIndex = (floatBits >> 23) & 0x1ff;
    _uintValue = base[shiftIndex] + ((floatBits & 0x007fffff) >> shift[shiftIndex]);
  }

  Float16() {}
  operator uint16_t() { return _uintValue; }
  uint16_t _uintValue;

  const uint16_t base[512] = {
      0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      0,     0,     0,     0,     0,     0,     0,     1,     2,     4,     8,     16,    32,    64,    128,   256,
      512,   1024,  2048,  3072,  4096,  5120,  6144,  7168,  8192,  9216,  10240, 11264, 12288, 13312, 14336, 15360,
      16384, 17408, 18432, 19456, 20480, 21504, 22528, 23552, 24576, 25600, 26624, 27648, 28672, 29696, 30720, 31744,
      31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744,
      31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744,
      31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744,
      31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744,
      31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744,
      31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744,
      31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744, 31744,
      32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768,
      32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768,
      32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768,
      32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768,
      32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768,
      32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768, 32768,
      32768, 32768, 32768, 32768, 32768, 32768, 32768, 32769, 32770, 32772, 32776, 32784, 32800, 32832, 32896, 33024,
      33280, 33792, 34816, 35840, 36864, 37888, 38912, 39936, 40960, 41984, 43008, 44032, 45056, 46080, 47104, 48128,
      49152, 50176, 51200, 52224, 53248, 54272, 55296, 56320, 57344, 58368, 59392, 60416, 61440, 62464, 63488, 64512,
      64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512,
      64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512,
      64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512,
      64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512,
      64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512,
      64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512,
      64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512, 64512};

  const uint8_t shift[512] = {
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 23, 22, 21, 20, 19,
      18, 17, 16, 15, 14, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
      13, 13, 13, 13, 13, 13, 13, 13, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 13, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 13, 13, 13, 13, 13, 13, 13, 13,
      13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 13};

// Function to convert F32 into F16
// F32: exp_bias:127 SEEEEEEE EMMMMMMM MMMMMMMM MMMMMMMM.
// F16: exp_bias:15  SEEEEEMM MMMMMMMM
#define EXP_MASK_F32 0x7F800000U
#define EXP_MASK_F16 0x7C00U

  // small helper function to represent uint32_t value as float32
  inline float asfloat(uint32_t v) {
    // Both type-punning casts and unions are UB per C++ spec
    // But compilers usually only break code with casts
    union {
      float f;
      uint32_t i;
    };
    i = v;
    return f;
  }

  uint16_t f32tof16_OpenVino(float x) {
    // create minimal positive normal f16 value in f32 format
    // exp:-14,mantissa:0 -> 2^-14 * 1.0
    static float min16 = asfloat((127 - 14) << 23);

    // create maximal positive normal f16 value in f32 and f16 formats
    // exp:15,mantissa:11111 -> 2^15 * 1.(11111)
    static float max16 = asfloat(((127 + 15) << 23) | 0x007FE000);
    static uint32_t max16f16 = ((15 + 15) << 10) | 0x3FF;

    // define and declare variable for intermediate and output result
    // the union is used to simplify representation changing
    union {
      float f;
      uint32_t u;
    } v;
    v.f = x;

    // get sign in 16bit format
    uint32_t s = (v.u >> 16) & 0x8000;  // sign 16:  00000000 00000000 10000000 00000000

    // make it abs
    v.u &= 0x7FFFFFFF;  // abs mask: 01111111 11111111 11111111 11111111

    // check NAN and INF
    if ((v.u & EXP_MASK_F32) == EXP_MASK_F32) {
      if (v.u & 0x007FFFFF) {
        return s | (v.u >> (23 - 10)) | 0x0200;  // return NAN f16
      } else {
        return s | EXP_MASK_F16;  // return INF f16
      }
    }

    // to make f32 round to nearest f16
    // create halfULP for f16 and add it to origin value
    float halfULP = asfloat(v.u & EXP_MASK_F32) * asfloat((127 - 11) << 23);
    v.f += halfULP;

    // if input value is not fit normalized f16 then return 0
    // denormals are not covered by this code and just converted to 0
    if (v.f < min16 * 0.5F) {
      return s;
    }

    // if input value between min16/2 and min16 then return min16
    if (v.f < min16) {
      return s | (1 << 10);
    }

    // if input value more than maximal allowed value for f16
    // then return this maximal value
    if (v.f >= max16) {
      return max16f16 | s;
    }

    // change exp bias from 127 to 15
    v.u -= ((127 - 15) << 23);

    // round to f16
    v.u >>= (23 - 10);

    return v.u | s;
  }
};
