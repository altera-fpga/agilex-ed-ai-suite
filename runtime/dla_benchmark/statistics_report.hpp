// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: The file defines functions to dump inference performance statistics

#pragma once

#include <map>
#include <string>
#include <utility>
#include <vector>

#include <openvino/openvino.hpp>
#include <samples/common.hpp>
#include <samples/csv_dumper.hpp>
#include <samples/slog.hpp>
#include "utils.hpp"
#include "dla_defines.h"

// @brief statistics reports types
static constexpr char noCntReport[] = "no_counters";
static constexpr char averageCntReport[] = "average_counters";
static constexpr char detailedCntReport[] = "detailed_counters";

/// @brief Responsible for collecting of statistics and dumping to .csv file
class StatisticsReport {
 public:
  typedef std::vector<ov::ProfilingInfo> PerformanceCounters;
  typedef std::vector<std::pair<std::string, std::string>> Parameters;

  struct Config {
    bool save_report;
    std::string report_folder;
  };

  enum class Category {
    COMMAND_LINE_PARAMETERS,
    RUNTIME_CONFIG,
    EXECUTION_RESULTS,
  };

  explicit StatisticsReport(Config config) : _config(std::move(config)) {
    _separator = dla::util::path_separator;
    if (_config.report_folder.empty()) _separator = "";
  }

  void addParameters(const Category &category, const Parameters &parameters);

  void dump();

  /// print the performance counters for neural net layers executed on the CPU.
  /// @param perfCounts                vector of map of layer name and ov::ProfilingInfo
  /// @param sortFlag                  One of "sort", "no_sort", "simple_sort".
  ///                                    "sort": sort by execution RealTime. Default value.
  ///                                    "no_sort": no sort.
  ///                                    "simple_sort": sort by execution RealTime after removing nodes with "NOT_RUN"
  ///                                    status.
  void printPerfCountersSort(const std::vector<PerformanceCounters> &perfCounts, std::string sortFlag = "sort");

  /// Helper function used by printPerfCountersSort that prints a row of performance count info.
  /// prints the following info for a layer from left to right:
  /// 0. nodeName: name of the layer
  /// 1. LayerStatus: NOT_RUN, OPTIMIZED_OUT, or EXECUTED
  /// 2. LayerType: type of layer, such as Convolution.
  /// 3. RealTime (ms): The absolute time that the layer ran (in total), including CPU processing time + any potential
  /// wait time.
  /// 4. CPUTime (ms): The net host cpu time that the layer ran, i.e. CPU processing time.
  /// 5. Proportion: RealTime of the node / RealTime in total
  /// 6. ExecType: An execution type of unit. e.g.,  jit_avx2_FP32 (executed using just-in-time (JIT) compilation with
  /// AVX2 instructions for FP32 data)
  /// @param result_list              vector of per-node info, where each per-node info is a vector of formatted string.
  void printDetailResult(std::vector<std::vector<std::string>> result_list);

 private:
  // configuration of current benchmark execution
  const Config _config;

  // parameters
  std::map<Category, Parameters> _parameters;

  // csv separator
  std::string _separator;
};
