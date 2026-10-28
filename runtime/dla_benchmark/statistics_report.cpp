// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: The file implements functions to dump inference performance statistics

#include <algorithm>
#include <map>
#include <string>
#include <utility>
#include <vector>

#include "statistics_report.hpp"

static const char* STATUS_NAMES[] = {"NOT_RUN", "OPTIMIZED_OUT", "EXECUTED"};

void StatisticsReport::addParameters(const Category& category, const Parameters& parameters) {
  if (_parameters.count(category) == 0)
    _parameters[category] = parameters;
  else
    _parameters[category].insert(_parameters[category].end(), parameters.begin(), parameters.end());
}

void StatisticsReport::dump() {
  CsvDumper dumper(true, _config.report_folder + _separator + "dla_benchmark_run_summary.csv");

  auto dump_parameters = [&dumper](const Parameters& parameters) {
    for (auto& parameter : parameters) {
      dumper << parameter.first << parameter.second;
      dumper.endLine();
    }
  };
  if (_parameters.count(Category::COMMAND_LINE_PARAMETERS)) {
    dumper << "Command line parameters";
    dumper.endLine();

    dump_parameters(_parameters.at(Category::COMMAND_LINE_PARAMETERS));
    dumper.endLine();
  }

  if (_parameters.count(Category::RUNTIME_CONFIG)) {
    dumper << "Configuration setup";
    dumper.endLine();

    dump_parameters(_parameters.at(Category::RUNTIME_CONFIG));
    dumper.endLine();
  }

  if (_parameters.count(Category::EXECUTION_RESULTS)) {
    dumper << "Execution results";
    dumper.endLine();

    dump_parameters(_parameters.at(Category::EXECUTION_RESULTS));
    dumper.endLine();
  }

  slog::info << "Run summary is saved to " << dumper.getFilename() << slog::endl;
}

void StatisticsReport::printPerfCountersSort(const std::vector<PerformanceCounters>& perfCounts, std::string sortFlag) {
  for (size_t ni = 0; ni < perfCounts.size(); ni++) {
    const auto& perf_counts = perfCounts[ni];
    double total_time(0);
    double total_time_cpu(0);
    std::cout << "Performance counts sorted for " << ni << "-th infer request" << std::endl;
    for (auto&& pi : perf_counts) {
      total_time += pi.real_time.count();
      total_time_cpu += pi.cpu_time.count();
    }
    auto total_real_time_proportion = 0.0;
    std::vector<std::vector<std::string>> total_detail_data;
    for (auto&& pi : perf_counts) {
      auto node_name = pi.node_name;
      std::string layer_status_str =
          ((int)pi.status < (int)(sizeof(STATUS_NAMES) / sizeof(STATUS_NAMES[0])) ? STATUS_NAMES[(int)pi.status]
                                                                                  : "INVALID_STATUS");

      auto layer_type = pi.node_type;
      auto real_time = pi.real_time.count();
      auto cpu_time = pi.cpu_time.count();
      auto real_proportion = real_time / total_time;
      auto execType = pi.exec_type;
      std::vector<std::string> tmp_data{node_name,
                                        layer_status_str,
                                        std::string(layer_type),
                                        std::to_string(real_time),
                                        std::to_string(cpu_time),
                                        std::to_string(real_proportion),
                                        std::string(execType)};
      total_detail_data.push_back(tmp_data);
      total_real_time_proportion += real_proportion;
    }
    // sorted by read_time
    if (sortFlag == "sort") {
      std::sort(total_detail_data.begin(), total_detail_data.end(), [](const auto& a, const auto& b) {
        return std::stod(a[3]) > std::stod(b[3]);
      });
    } else if (sortFlag == "no_sort") {
      total_detail_data = total_detail_data;
    } else if (sortFlag == "simple_sort") {
      std::sort(total_detail_data.begin(), total_detail_data.end(), [](const auto& a, const auto& b) {
        return std::stod(a[3]) > std::stod(b[3]);
      });
      total_detail_data.erase(
          std::remove_if(
              total_detail_data.begin(), total_detail_data.end(), [](const auto& a) { return a[1] == "NOT_RUN"; }),
          total_detail_data.end());
    }
    printDetailResult(total_detail_data);
    // Save the current state of std::cout. This is to avoid coverity error.
    std::ios_base::fmtflags f(std::cout.flags());

    std::cout << "Total time:       " << total_time / 1000 << " milliseconds" << std::endl;
    std::cout << "Total CPU time:   " << total_time_cpu / 1000 << " milliseconds" << std::endl;
    std::cout << "Total proportion: " << std::fixed << std::setprecision(2) << round(total_real_time_proportion * 100)
              << " % \n"
              << std::endl;

    // Restore the original state
    std::cout.flags(f);
  }
}

void StatisticsReport::printDetailResult(std::vector<std::vector<std::string>> result_list) {
  const int max_layer_name_len = 50;
  for (auto&& tmp_result : result_list) {
    std::string node_name = tmp_result[0];
    std::string node_name_truncated = node_name.substr(0, max_layer_name_len - 4);
    if (node_name.length() >= max_layer_name_len) {
      node_name_truncated += "...";
    }
    std::string layerStatus = tmp_result[1];
    std::string layerType = tmp_result[2];
    float real_time = std::stof(tmp_result[3]);
    float cpu_time = std::stof(tmp_result[4]);
    float proportion = std::stof(tmp_result[5]);
    std::string execType = tmp_result[6];

    std::printf(
        "node: %-50s LayerStatus: %-15s LayerType: %-30s RealTime: %-20.3f CPUTime: %-20.3f Proportion: %-30.3f "
        "ExecType: %-20s\n",
        node_name_truncated.c_str(),
        layerStatus.c_str(),
        layerType.substr(0, max_layer_name_len).c_str(),
        real_time / 1000.0,  // ms
        cpu_time / 1000.0,   // ms
        proportion * 100,
        std::string(execType).substr(0, max_layer_name_len).c_str());
  }
}
