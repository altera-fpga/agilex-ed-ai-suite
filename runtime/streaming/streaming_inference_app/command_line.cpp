// Copyright 2021-2023 Altera Corporation.
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

#include "command_line.h"
#include <algorithm>

static void TrimString(std::string& trimString) {
  trimString.erase(0, trimString.find_first_not_of(" \n\r\t"));
  trimString.erase(trimString.find_last_not_of(" \n\r\t") + 1);
}

static void MakeLower(std::string& stringValue) {
  std::transform(stringValue.begin(), stringValue.end(), stringValue.begin(), ::tolower);
}

// Program -option=value
CommandLine::CommandLine(int argumentCount, char* argumentValues[]) {
  if (argumentCount > 0) _executableName = argumentValues[0];

  for (int i = 1; i < argumentCount; i++) {
    std::string inputString(argumentValues[i]);
    std::string nextChar = inputString.substr(0, 1);
    if ((nextChar == "-") or (nextChar == "/")) {
      inputString = inputString.substr(1);
      size_t equals = inputString.find("=");
      std::string option;
      std::string value;

      if (equals == std::string::npos) {
        option = inputString;
      } else {
        option = inputString.substr(0, equals);
        value = inputString.substr(equals + 1);
      }

      TrimString(option);
      TrimString(value);
      MakeLower(option);
      _optionMap[option] = value;
    }
  }
}

std::string CommandLine::GetOptionValue(const char* optionName) {
  auto i = _optionMap.find(optionName);
  if (i != _optionMap.end())
    return i->second;
  else
    return "";
}

bool CommandLine::HaveOption(const char* optionName) { return (_optionMap.find(optionName) != _optionMap.end()); }

bool CommandLine::GetOption(const char* optionName, std::string& optionValue) {
  auto i = _optionMap.find(optionName);
  if (i == _optionMap.end()) return false;

  optionValue = i->second;
  return true;
}

size_t CommandLine::NumOptions() { return _optionMap.size(); }
