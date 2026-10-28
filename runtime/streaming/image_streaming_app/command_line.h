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

#pragma once
#include <string>
#include <unordered_map>

class CommandLine {
 public:
  CommandLine(int argumentCount, char* argumentValues[]);

  std::string GetOptionValue(const char* optionName);
  bool GetOption(const char* optionName, std::string& optionValue);
  bool HaveOption(const char* optionName);
  std::string GetExecutableName() { return _executableName; }
  size_t NumOptions();

 private:
  std::string _executableName;
  std::unordered_map<std::string, std::string> _optionMap;
};
