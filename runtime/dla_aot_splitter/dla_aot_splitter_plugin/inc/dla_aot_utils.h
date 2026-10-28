// Copyright 2020-2023 Altera Corporation.
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

#ifndef _DLA_AOT_UTILS_H_
#define _DLA_AOT_UTILS_H_

#include <fcntl.h>
#include <sys/stat.h>

#include <iostream>
#include <string>
#include <vector>

#include "dla_aot_structs.h"

// fp16 feature element (in bytes)
// TODO: extract it from arch / compiled result
const uint32_t feature_elem_size = 2;

//////////////////////////////////////////////////////////////////////////////
// Dump DLA input and output to the following files:
// - config_filter.mem: config + filter buffer
// - input_feature.mem: input feature buffer
// - output_feature.mem: output feature buffer (emulation results)
//
// Each .mem file is a text file, with one byte (in hex) per line.
//////////////////////////////////////////////////////////////////////////////

void writeInputOutputToFiles(const std::array<int32_t, ARCH_HASH_WORD_SIZE>& arch_hash,
                             const std::string& build_version,
                             const std::string& arch_name,
                             const DLAInput& input,
                             const DLAOutput& output);

#endif  // _DLA_AOT_UTILS_H_
