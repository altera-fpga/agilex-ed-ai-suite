// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: Main file of DLA benchmark. Entry point of DLA for just in time, ahead of time execution
//              and any use case of DLA performing inference. This file is responsible for the end to end flow of DLA,
//              from reading user input arguments, creating input tensors, compiling models, running inference
//              dumping results. DLA benchmark is loosely based off of OpenVINO's sample benchmark app.
//              For future OpenVINO uplifts viewing their sample app is a good place to start.
//              Ref: [openvinotoolkit/openvino › samples/cpp/benchmark_app/main.cpp]

#include <algorithm>
#include <chrono>
#include <cstddef>
#include <map>
#include <memory>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>
#include <cctype>
#include <cstring>
#include <sstream>
#if defined(_WIN32) || defined(_WIN64)
#include <io.h>
#define NOMINMAX
#include <Windows.h>
#else
#include <dirent.h>
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>
#include <cerrno>
#endif
#include <stdio.h>
#include <sys/stat.h>
#include <fstream>
#include <regex>
#include <filesystem>
#include <thread>
#include <condition_variable>
#include <mutex>

namespace fs = std::filesystem;

#include <samples/args_helper.hpp>
#include <samples/common.hpp>
#include <samples/slog.hpp>
#include <nlohmann/json.hpp>
#include <openvino/op/constant.hpp>
#include <openvino/op/transpose.hpp>

// DLA utils
#include "dla_stl_utils.h"
#include "dla_defines.h"
#include "dla_ov_frontend_utils.h"
#include "dla_fifo_pipe.h"
#include "dla_formatted_print.h"
#include "dla_exception.h"
#include "dla_error_log.h"

// DLA benchmark
#include "average_precision.hpp"
#include "dla_benchmark.hpp"
#include "dla_plugin_config.hpp"
#include "dla_performance_profiler.hpp"
#include "infer_request_wrap.hpp"
#include "inputs_filling.hpp"
#include "progress_bar.hpp"
#include "spatial_benchmark.hpp"
#include "statistics_report.hpp"
#include "top1_top5.hpp"
#include "utils.hpp"

using DebugNetworkData = std::map<std::string, uint64_t>;
using LSUCounterData   = std::map<std::string, uint64_t>;

static const size_t progressBarDefaultTotalCount = 1000;

namespace {

std::string ToLowerCopy(std::string value) {
  std::transform(value.begin(), value.end(), value.begin(),
                 [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
  return value;
}

#if !defined(_WIN32) && !defined(_WIN64)
bool ReadIntegerFromFile(const std::string& path, long long& out) {
  std::ifstream file(path);
  if (!file.good()) return false;
  file >> out;
  return !file.fail();
}

// Read the ARM MIDR_EL1 part number (bits [15:4]) for a CPU from sysfs.
// Returns -1 if the file is not present (non-ARM or older kernel).
static long long ReadMidrPartNumber(long cpu) {
  const std::string path = "/sys/devices/system/cpu/cpu" + std::to_string(cpu) +
                           "/regs/identification/midr_el1";
  std::ifstream file(path);
  if (!file.good()) return -1;
  unsigned long long midr = 0;
  file >> std::hex >> midr;
  if (file.fail()) return -1;
  return static_cast<long long>((midr >> 4) & 0xFFF);
}

// Returns a relative performance score for known ARM core part numbers.
// Higher value means stronger core. Unknown parts return 0.
static long long MidrPartPerformanceScore(long long part_num) {
  switch (part_num) {
    // LITTLE / efficiency cores
    case 0xD03: return 10;  // Cortex-A53
    case 0xD05: return 20;  // Cortex-A55
    case 0xD46: return 30;  // Cortex-A510
    case 0xD80: return 35;  // Cortex-A520

    // Big/performance cores
    case 0xD07: return 60;  // Cortex-A57
    case 0xD08: return 65;  // Cortex-A72
    case 0xD09: return 70;  // Cortex-A73
    case 0xD0A: return 75;  // Cortex-A75
    case 0xD0B: return 80;  // Cortex-A76
    case 0xD0D: return 85;  // Cortex-A77
    case 0xD41: return 90;  // Cortex-A78
    case 0xD47: return 95;  // Cortex-A710
    case 0xD81: return 100;  // Cortex-A720

    // X-series (highest perf)
    case 0xD44: return 120;  // Cortex-X1
    case 0xD48: return 125;  // Cortex-X2
    case 0xD4E: return 130;  // Cortex-X3
    default: return 0;
  }
}

std::vector<int> DetectHighestCapacityCpus() {
  long cpu_count = sysconf(_SC_NPROCESSORS_CONF);
  if (cpu_count <= 0) return {};

  // On ARM big-little SoCs, rely on cpu_capacity and MIDR sysfs only.
  // This avoids cpufreq dependencies, which are not consistently available
  // on Yocto deployments.
  std::vector<long long> midr_part(static_cast<size_t>(cpu_count), -1);
  bool has_midr = false;
  for (long cpu = 0; cpu < cpu_count; ++cpu) {
    long long part = ReadMidrPartNumber(cpu);
    if (part >= 0) {
      midr_part[static_cast<size_t>(cpu)] = part;
      has_midr = true;
    }
  }

  bool midr_heterogeneous = false;
  if (has_midr) {
    long long first_part = -1;
    for (auto p : midr_part) {
      if (p >= 0) {
        if (first_part < 0) {
          first_part = p;
        } else if (p != first_part) {
          midr_heterogeneous = true;
          break;
        }
      }
    }
  }

  std::vector<long long> metric(static_cast<size_t>(cpu_count), -1);

  // Always try cpu_capacity first.
  bool has_capacity_metric = false;
  for (long cpu = 0; cpu < cpu_count; ++cpu) {
    long long capacity = -1;
    const std::string path = "/sys/devices/system/cpu/cpu" + std::to_string(cpu) + "/cpu_capacity";
    if (ReadIntegerFromFile(path, capacity)) {
      metric[static_cast<size_t>(cpu)] = capacity;
      has_capacity_metric = true;
    }
  }

  if (midr_heterogeneous) {
    // Heterogeneous MIDR means true big-little. If cpu_capacity is missing or
    // flat, fall back to MIDR part-number ranking.
    if (has_capacity_metric) {
      long long max_capacity = -1;
      long long min_capacity = -1;
      for (auto value : metric) {
        if (value < 0) continue;
        if (max_capacity < 0 || value > max_capacity) max_capacity = value;
        if (min_capacity < 0 || value < min_capacity) min_capacity = value;
      }
      if (max_capacity == min_capacity) {
        has_capacity_metric = false;
      }
    }
    if (!has_capacity_metric) {
      for (long cpu = 0; cpu < cpu_count; ++cpu) {
        metric[static_cast<size_t>(cpu)] = MidrPartPerformanceScore(midr_part[static_cast<size_t>(cpu)]);
      }
    }
  } else {
    // Homogeneous MIDR (or unavailable): keep cpu_capacity if present,
    // otherwise there is no reliable metric to pin by.
    if (!has_capacity_metric) {
      return {};
    }
  }

  long long max_metric = -1;
  for (auto value : metric) {
    if (value > max_metric) max_metric = value;
  }
  if (max_metric <= 0) return {};

  // On a homogeneous system every core has the same metric value; no pinning needed.
  if (!midr_heterogeneous) {
    bool all_equal = true;
    for (auto value : metric) {
      if (value >= 0 && value != max_metric) { all_equal = false; break; }
    }
    if (all_equal) return {};
  }

  std::vector<int> selected;
  for (long cpu = 0; cpu < cpu_count; ++cpu) {
    if (metric[static_cast<size_t>(cpu)] == max_metric) {
      selected.push_back(static_cast<int>(cpu));
    }
  }
  return selected;
}

std::string CpuListToString(const std::vector<int>& cpus) {
  std::ostringstream os;
  for (size_t i = 0; i < cpus.size(); ++i) {
    if (i) os << ",";
    os << cpus[i];
  }
  return os.str();
}

bool PinProcessToCpus(const std::vector<int>& cpus, std::string& error) {
  cpu_set_t set;
  CPU_ZERO(&set);
  for (int cpu : cpus) {
    if (cpu >= 0 && cpu < CPU_SETSIZE) {
      CPU_SET(cpu, &set);
    }
  }
  if (sched_setaffinity(0, sizeof(set), &set) != 0) {
    error = std::strerror(errno);
    return false;
  }
  return true;
}
#endif

void ConfigureCpuAffinity() {
  const std::string mode = ToLowerCopy(FLAGS_cpu_affinity);
  if (mode != "auto" && mode != "big" && mode != "off") {
    throw std::logic_error("Incorrect -cpu_affinity value. Please use auto, big, or off.");
  }

#if !defined(_WIN32) && !defined(_WIN64)
  bool should_pin_big = false;
#if defined(__aarch64__)
  should_pin_big = (mode == "auto" || mode == "big");
#else
  should_pin_big = (mode == "big");
#endif

  if (!should_pin_big) {
    if (mode == "off") {
      slog::info << "CPU affinity pinning is disabled (-cpu_affinity=off)." << slog::endl;
    }
    return;
  }

  const std::vector<int> cpus = DetectHighestCapacityCpus();
  if (cpus.empty()) {
    slog::warn << "Could not detect a highest-capacity CPU cluster for -cpu_affinity=" << mode
               << ". Continuing without process pinning." << slog::endl;
    return;
  }

  std::string error;
  if (!PinProcessToCpus(cpus, error)) {
    slog::warn << "Failed to apply process CPU affinity for -cpu_affinity=" << mode
               << " (" << error << "). Continuing without process pinning." << slog::endl;
    return;
  }

  slog::info << "Pinned benchmark process to highest-capacity CPUs: " << CpuListToString(cpus) << slog::endl;
#else
  if (mode == "big") {
    slog::warn << "-cpu_affinity=big is not supported on this platform. Continuing without process pinning." << slog::endl;
  }
#endif
}

}  // namespace

// Get value from env variable named 'name', if it exists.
// If not, returns provided default value.
template <class T>
T GetEnvOrDefault(const char* name, T default_value) {
  char* str_val = std::getenv(name);
  T result = default_value;
  if (str_val != NULL) {
    std::stringstream ss;
    ss << str_val;
    ss >> result;
  }
  return result;
}

// Define a custom comparison function to sort based on ASCII names
bool CompareOutputNodeNames(const ov::Output<const ov::Node>& node1, const ov::Output<const ov::Node>& node2) {
  return node1.get_any_name() < node2.get_any_name();
}

void ParseCommandLine(int argc, char** argv) {
  // preprocess arguments to handle cases not supported by gflags
  std::vector<std::string> new_args;
  std::vector<char*> arguments(argc, nullptr);
  for (int i = 0; i < argc; ++i) {
    if (strstr(argv[i], "-online-reconfig") && !strstr(argv[i], "=") && (i + 1 == argc || strstr(argv[i + 1], "-") == argv[i + 1])) {
      // turn "-online-reconfig" into "-online-reconfig=" to emulate optional value behavior
      new_args.push_back("-online-reconfig=");
      arguments[i] = &new_args.back()[0];
      continue;
    }
    arguments[i] = argv[i];
  }
  // the parse function is modifying the arguments point so we need to keep
  // a copy of the original pointer value to delete it properly
  char** args = arguments.data();
  gflags::ParseCommandLineNonHelpFlags(&argc, &args, true);
}

bool CheckAndSetPluginsPath(const char* coredla_root) {
  // plugins_xml_file should probably be removed in the future
  if (!FLAGS_plugins_xml_file.empty()) {
    FLAGS_plugins = FLAGS_plugins_xml_file;
    slog::warn << "====================================================================" << slog::endl;
    slog::warn << "Warning: -plugins_xml_file option is deprecated, please use -plugins." << slog::endl;
    slog::warn << "====================================================================" << slog::endl;
  }

  const char* coredla_work = std::getenv("COREDLA_WORK");
  std::string coredla_root_str = coredla_root;
  if (FLAGS_plugins.empty()) {
    if (coredla_work == nullptr) {
      FLAGS_plugins = coredla_root_str + "/runtime/plugins.xml";
      #ifdef DEFAULT_PLUGINS_PATH
      FLAGS_plugins = DEFAULT_PLUGINS_PATH;
      #endif

    } else {
      std::string coredla_work_str = coredla_work;
      FLAGS_plugins = coredla_work_str + "/runtime/plugins.xml";
      #ifdef DEFAULT_PLUGINS_PATH
      FLAGS_plugins = DEFAULT_PLUGINS_PATH;
      #endif
    }

    if (ExistsTest(FLAGS_plugins)) {
      slog::info << "Using default plugins xml file - " << FLAGS_plugins << slog::endl;
      return true;
    }
  }

  if (ExistsTest(FLAGS_plugins) && isFile(FLAGS_plugins)) {
    slog::info << "Using custom plugins xml file - " << FLAGS_plugins << slog::endl;
    return true;
  }
  // Check if user wants a shortcut to software emulation xml file if a path does not exist
  if (FLAGS_plugins.find("emulation") != std::string::npos) {
    // Potential paths for the plugins_emulation.xml file
    std::string deployed_loc_plugins = coredla_root_str + "/lib/plugins_emulation.xml";
    std::string developer_loc_plugins = coredla_root_str + "/build/coredla/dla/lib/plugins_emulation.xml";

    if (ExistsTest(deployed_loc_plugins))
      FLAGS_plugins = deployed_loc_plugins;
    else if (ExistsTest(developer_loc_plugins))
      FLAGS_plugins = developer_loc_plugins;
  } else {
    // if user didn't specify emulation and user did not pass any xml file, raise an error
    throw std::invalid_argument("Invalid argument for -plugins. Use 'emulation' or a path to custom xml file");
  }

  if (ExistsTest(FLAGS_plugins)) {
    slog::info << "Using custom emulation xml file - " << FLAGS_plugins << slog::endl;
    return true;
  }

  return false;
}

bool ParseAndCheckCommandLine(int argc, char* argv[], size_t& net_size) {
  // ---------------------------Parsing and validating input arguments--------------------------------------
  slog::info << "Parsing input parameters" << slog::endl;

  // Check for any flags that are missing their preceding dashes
  // GFlags quietly ignores any flags missing their dashes, which can cause
  // dla_benchmark to run with settings other than what the user intended

  // GFlags supports two different styles of flag:
  // 1. --<flag>
  // 2. -<flag>
  // It also supports two different ways of specifying values for flags which
  // take values:
  // 1. --<flag>=<value>
  // 2. --<flag> <value>

  // If we are not expecting a flag, we are expecting a value for the
  // preceding flag
  bool expecting_flag = true;
  // Start at 1 to skip the command itself
  for (int i = 1; i < argc; i++) {
    if (expecting_flag) {
      // A flag is always denoted by the first char being '-'
      if (argv[i][0] != '-') {
        slog::err << "Argument " << argv[i] << " is invalid. You"
                  << " may have forgotten a preceding '-'." << slog::endl;
        throw std::logic_error("One or more invalid arguments");
      }

      char* flag_name_start = (argv[i][1] == '-') ? &argv[i][2] : &argv[i][1];
      std::string flag_name;

      gflags::CommandLineFlagInfo flag_info;
      if (strstr(flag_name_start, "=")) {
        flag_name = std::string(flag_name_start, size_t(strstr(flag_name_start, "=") - flag_name_start));
      } else {
        flag_name = std::string(flag_name_start);
      }

      // We expect a flag in the next argv if the current flag is a bool,
      // because bool flags do not take a value.
      // If GetCommandLineFlagInfo returns false, we assume the current
      // flag is a boolean because boolean flags can be specified as
      // -no<flag>, which is equivalent to -<flag>=false, or the flag
      // simply being omitted. However, "no<flag>" is not recognized by
      // GetCommandLineFlagInfo.
      // Therefore, if the name is not recognized either the flag is a
      // boolean flag or doesn't exist. In the latter case, gflags errors
      // when we call ParseCommandLine so we can assume here it's a bool.
      if (flag_name == "online-reconfig" && (i + 1 == argc || strstr(argv[i + 1], "-") == argv[i + 1])) {
        // special case: -online-reconfig is an optional value flag
        expecting_flag = true;
      } else if (!GetCommandLineFlagInfo(flag_name.c_str(), &flag_info) || strstr(argv[i], "=") || flag_info.type == "bool") {
        expecting_flag = true;
      } else {
        expecting_flag = false;
      }
    } else {
      // If we were expecting a value, doesn't matter what it is
      // gflags will check all values are the correct type, and
      // dla_benchmark checks if the values received are sane
      expecting_flag = true;
    }
  }

  ParseCommandLine(argc, argv);


  if (FLAGS_help || FLAGS_h) {
    ShowUsage();
    // CoreDLA: Version 2020.3 of OpenVINO assumes that the PAC board with OPAE on it
    // is an OpenCL/DLAv1 device.  Since it is not, it then errors-out when the device
    // does not response as expected to the OpenCL query.
    // showAvailableDevices();
    std::cout << "\n";
    return false;
  }

  if (FLAGS_hidden_help) {
    PrintHiddenHelp();
    return false;
  }

  if (FLAGS_cm.empty()) {
    std::string network_file_flag;
    if (!FLAGS_m.empty()) {
      if (!FLAGS_network_file.empty()) {
        throw std::invalid_argument(
            "Both --network-file and -m are specified. Please only use one of the two arguments.");
      }
      network_file_flag = FLAGS_m;
    } else if (!FLAGS_network_file.empty()) {
      network_file_flag = FLAGS_network_file;
    } else {
      throw std::logic_error("Model is required but not set. Please set -m option.");
    }

    std::vector<std::string> m_paths = split(network_file_flag, MULTIGRAPH_SEP);
    net_size = m_paths.size();
    slog::info << "Found " << net_size << " graph" << (net_size == 1 ? "" : "s") << slog::endl;
    for (auto& m_path : m_paths) {
      if (!ExistsTest(m_path)) {
        slog::err << "network file: " << m_path << " doesn't exist. Please provide a valid path with -m." << slog::endl;
        throw std::logic_error("Model file path does not exist.");
      }
    }
  } else {
    std::vector<std::string> m_paths = split(FLAGS_cm, MULTIGRAPH_SEP);
    net_size = m_paths.size();
    slog::info << "Found " << net_size << " compiled graph" << (net_size == 1 ? "" : "s") << slog::endl;
    for (auto& m_path : m_paths) {
      if (!ExistsTest(m_path)) {
        slog::err << "compiled model file: " << FLAGS_cm << " doesn't exist. Please provide a valid path with -cm."
                  << slog::endl;
        throw std::logic_error("Compiled model file path does not exist.");
      }
      if (!dla::util::str_ends_with(m_path, ".aot")) {
        slog::err << "compiled model file: " << FLAGS_cm << " does not end with a .aot extension"
                  << slog::endl;
        throw std::logic_error("Compiled model file path does not appear to be a binary file.");
      }
    }
  }

  if (FLAGS_api != "async" && FLAGS_api != "sync") {
    throw std::logic_error("Incorrect API. Please set -api option to `sync` or `async` value.");
  }

  // allow online reconfig with niter=0 for just reconfiguration and no inference
  if (FLAGS_niter <= 0 && FLAGS_online_reconfig == "none") {
    throw std::logic_error("-niter is a required flag and its value must be positive");
  }

  const char* coredla_root = std::getenv("COREDLA_ROOT");
  if (coredla_root == nullptr) {
    slog::err << "ERROR: COREDLA_ROOT environment variable is not set." << slog::endl;
    throw std::logic_error("Please set up correct environment variables first");
  }

  if (!CheckAndSetPluginsPath(coredla_root)) {
    slog::err << "plugins_xml file: " << FLAGS_plugins_xml_file << " doesn't exist. Please provide a valid path."
              << slog::endl;
    throw std::logic_error("plugins_xml file path does not exist.");
  }

  // Checks required arguments for the mAP calculation subroutine.
  if (FLAGS_enable_object_detection_ap) {
    if (!FLAGS_yolo_version.size() || !is_yolo_supported(FLAGS_yolo_version)) {
      slog::err << "Please specify the version of your YOLO graph by setting the -yolo_version option to "
                   "`yolo-v3-tiny-tf`, `yolo-v3-tf` or `yolo-v8` value."
                << slog::endl;
      throw std::logic_error("Incorrect YOLO version.");
    }
  }

  // Checks if output directory exists and can be opened
  if (!FLAGS_output_dir.empty()) {
    CreateDir(FLAGS_output_dir);
    // Test whether the path can be opened if it's a directory
    DirOpenTest(FLAGS_output_dir);
  }

  if (FLAGS_dump_additional_perf_est && !FLAGS_perf_est) {
    slog::err << "Please specify perf_est to enable additional dumping of performance estimates"  << slog::endl;
    throw std::logic_error("Cannot dump additional performance estimates without enabling performance estimates");
  }

  if (FLAGS_enable_performance_profiler) {
#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
    SET_PERFORMANCE_PROFILING(true);
#else
    slog::err << "Performance profiling is not supported because the runtime was built without performance analysis enabled." << slog::endl;
    throw std::logic_error("Performance profiling not supported without performance analysis enabled in the runtime build.");
#endif
  }

  return true;
}

static void next_step(const std::string additional_info = "") {
  static size_t step_id = 0;
  static const std::map<size_t, std::string> step_names = {{1, "Parsing and validating input arguments"},
                                                           {2, "Loading OpenVINO Runtime"},
                                                           {3, "Setting device configuration"},
                                                           {4, "Reading the Intermediate Representation network"},
                                                           {5, "Resizing network to match image sizes and given batch"},
                                                           {6, "Configuring input of the model"},
                                                           {7, "Loading the model to the device"},
                                                           {8, "Setting optimal runtime parameters"},
                                                           {9, "Creating infer requests and preparing input tensors"},
                                                           {10, "Measuring performance"},
                                                           {11, "Dumping statistics report"},
                                                           {12, "Dumping the output values"}};

  step_id++;
  if (step_names.count(step_id) == 0)
    OPENVINO_THROW("Step ID ", step_id, " is out of total steps number ", step_names.size());

  std::cout << "[Step " << step_id << "/" << step_names.size() << "] " << step_names.at(step_id)
            << (additional_info.empty() ? "" : " (" + additional_info + ")") << std::endl;
}

template <typename T>
T GetMedianValue(const std::vector<T>& vec) {
  std::vector<T> sorted_vec(vec);
  std::sort(sorted_vec.begin(), sorted_vec.end());
  return (sorted_vec.size() % 2 != 0)
             ? sorted_vec[sorted_vec.size() / 2ULL]
             : (sorted_vec[sorted_vec.size() / 2ULL] + sorted_vec[sorted_vec.size() / 2ULL - 1ULL]) /
                   static_cast<T>(2.0);
}

void ReadDebugNetworkInfo(ov::Core core) {
  if (FLAGS_debug_network) {
    // On hardware timeout exception, fetch Debug CSR values from all modules attached to the Debug Network
    std::vector<DebugNetworkData> debug_csr_return =
        CoreGetPropertyFPGA(core, "COREDLA_DEBUG_NETWORK_INFO").as<std::vector<DebugNetworkData>>();
    slog::info << "Dumping Debug Network profiling counters" << slog::endl;
    for (auto i = 0U; i < debug_csr_return.size(); i++) {
      std::cout << "---------- CoreDLA instance " << i << " ----------" << std::endl;
      // Print debug info for all instances
      for (auto& instance_csr_return : debug_csr_return[i]) {
        std::cout << instance_csr_return.first << ": " << instance_csr_return.second << std::endl;
      }
    }
  }
}

void PrintLSUCounterInfo(ov::Core core) {
  std::vector<LSUCounterData> lsu_counter_vec =
    CoreGetPropertyFPGA(core, "COREDLA_LSU_ACCESS_COUNT").as<std::vector<LSUCounterData>>();
    slog::info << "Dumping LSU memory access counters" << slog::endl;
    for (auto i = 0U; i < lsu_counter_vec.size(); i++) {
      std::cout << "---------- CoreDLA instance " << i << " ----------" << std::endl;
      for (const auto& entry : lsu_counter_vec.at(i)) {
        std::cout << entry.first <<": " << entry.second << std::endl;
      }
    }
}

// Returns true if last char of csv is a comma
bool is_last_char_comma(FILE* file) {
  if (file == nullptr) return 0;

  int i = -1;
  std::vector<char> white_space_chars = {'\n', ' ', '\t', '\r', '\f', '\v'};
  char last_char[1];
  do {
    if (std::fseek(file, i, SEEK_END) != 0) {
      return 0;
    }
    if (std::fread(last_char, 1, 1, file) == 0) {
      return 0;
    }
    i--;
  } while (std::count(white_space_chars.begin(), white_space_chars.end(), last_char[0]) != 0);

  return last_char[0] == ',';
}

bool fileExists(std::string& path) {
  struct stat buffer;
  return (stat(path.c_str(), &buffer) == 0);
}

void append_value_if_incomplete_to_csv(std::string path, double value) {
  try {
    if (!fileExists(path)) {
      return;
    }

    FILE* data_file = fopen(path.c_str(), "rb");
    if (data_file == nullptr) {
      return;
    }
    bool is_comma = is_last_char_comma(data_file);
    fclose(data_file);

    if (is_comma) {
      FILE* append_file = fopen(path.c_str(), "a");
      if (append_file == nullptr) {
        return;
      }
      fprintf(append_file, "%f\n", value);
      fclose(append_file);
    }
  } catch (...) {
    return;
  }
}

/**
 * @brief The entry point of the dla benchmark
 */
int main(int argc, char* argv[]) {
  // Parse command line arguments
  ParseCommandLine(argc, argv);

  // Spatial mode: run simplified inference flow and exit
  if (FLAGS_spatial) {
    try {
      return dla_benchmark::run_spatial_benchmark();
    } catch (const dla::error& ex) {
      slog::err << "Spatial mode error: " << ex.user_message() << slog::endl;
      return 3;
    } catch (const std::exception& ex) {
      slog::err << "Spatial mode error: " << dla::user_facing_message(ex) << slog::endl;
      return 3;
    }
  }

  std::shared_ptr<StatisticsReport> statistics;
  try {
    // Declaring the CompiledModel object as a pointer to workaround the segfault
    // that occurs when destructing the object. Now that it's declared as a pointer
    // the complier won't automatically call the destructor of the object at the end
    // of this scope and we won't delete the allocated memory either
    std::vector<ov::CompiledModel*> compiled_models;
    size_t net_size = 0;  // parse the size of networks for arguments check

    size_t return_code = 0;  // universal return code, return this value after dumping out Debug info

    // ----------------- 1. Parsing and validating input arguments -------------------------------------------------
    next_step();

    if (!ParseAndCheckCommandLine(argc, argv, net_size)) {
      return 0;
    }

    // Apply process affinity before creating runtime objects so worker
    // threads inherit the selected CPU mask.
    ConfigureCpuAffinity();

    bool is_model_compiled = !FLAGS_cm.empty();
    if (is_model_compiled) {
      slog::info << "Model is compiled" << slog::endl;
    }

    std::string arch_file_flag;
    if (!FLAGS_arch_file.empty()) {
      if (!FLAGS_arch.empty()) {
        throw std::invalid_argument(
            "Both --arch and -arch_file are specified. Please only use one of the two arguments.");
      }
      arch_file_flag = FLAGS_arch_file;
    } else if (!FLAGS_arch.empty()) {
      arch_file_flag = FLAGS_arch;
    }

    bool flag_b_default = gflags::GetCommandLineFlagInfoOrDie("b").is_default;
    bool flag_batch_size_default = gflags::GetCommandLineFlagInfoOrDie("batch_size").is_default;

    size_t batch_size_flag;
    if (!flag_b_default) {
      if (!flag_batch_size_default) {
        throw std::invalid_argument(
            "Both --batch-size and -b are specified. Please only use one of the two arguments.");
      }
      batch_size_flag = FLAGS_b;
    } else {
      batch_size_flag = FLAGS_batch_size;
    }

    if (batch_size_flag > 10000 || batch_size_flag <= 0) {
      throw std::invalid_argument(
          "Batch size is too big (>10000) or not a postive number (<=0). Specify the batch size within the specified "
          "range.");
    }

    std::string network_file_flag;
    if (!FLAGS_m.empty()) {
      if (!FLAGS_network_file.empty()) {
        throw std::invalid_argument(
            "Both --network-file and -m are specified. Please only use one of the two arguments.");
      }
      network_file_flag = FLAGS_m;
    } else if (!FLAGS_network_file.empty()) {
      network_file_flag = FLAGS_network_file;
    }

    // langsu: ideally use boost to create a sub-folder for ddrfree files
    // but ed4 toolchain doesn't have boost yet.
    std::string base_output_dir;
    std::string separator = dla::util::path_separator;
    if (!FLAGS_output_dir.empty()) {
      base_output_dir = FLAGS_output_dir;
      // Ensure trailing separator
      if (base_output_dir.back() != separator[0]) {
        base_output_dir += separator;
      }
    } else {
      base_output_dir = "." + separator;
    }

    // The set of arguments printed is meant to be a useful summary to the
    // user, rather than all of the arguments to dla_benchmark
    slog::info << "Printing summary of arguments being used by dla_benchmark" << slog::endl
               << "API (-api) ........................... " << FLAGS_api << slog::endl
               << "Device (-d) .......................... " << FLAGS_d << slog::endl
               << "Batch size (-b) ...................... " << batch_size_flag << slog::endl
               << (!FLAGS_cm.empty() ? "Compiled model (-cm) ................. "
                                     : "Model (-m) ........................... ")
               << (!FLAGS_cm.empty() ? FLAGS_cm : network_file_flag) << slog::endl
               << "Num iterations (-niter) .............. "
               << (FLAGS_niter > 0 ? std::to_string(FLAGS_niter) : "Not specified") << slog::endl
               << "Input images directory (-i) .......... "
               << (!FLAGS_i.empty() ? FLAGS_i : "Not specified, will use randomly-generated images") << slog::endl
               << "Num CPU threads (-nthreads) .......... "
               << (FLAGS_nthreads > 0 ? std::to_string(FLAGS_nthreads) : "Not specified") << slog::endl
               << "Architecture file (-arch_file) ....... " << arch_file_flag << slog::endl
               << "Num inference requests (-nireq) ...... "
               << (FLAGS_nireq > 0 ? std::to_string(FLAGS_nireq) : "Not specified") << slog::endl
               << "Plugins file (-plugins) ..... " << FLAGS_plugins << slog::endl
               << "Groundtruth file (-groundtruth_loc) .. "
               << (!FLAGS_groundtruth_loc.empty() ? FLAGS_groundtruth_loc : "Not specified") << slog::endl
               << "Reverse input image channels (-bgr) .. " << (FLAGS_bgr ? "True" : "False") << slog::endl
               << "EA features " << (FLAGS_enable_early_access ? "enabled." : "disabled.") << slog::endl;

    if (FLAGS_save_run_summary) {
      std::vector<gflags::CommandLineFlagInfo> flags;
      StatisticsReport::Parameters command_line_arguments;
      gflags::GetAllFlags(&flags);

      for (auto& flag : flags) {
        if (!flag.is_default) {
          command_line_arguments.push_back({flag.name, flag.current_value});
        }
      }

      if (!FLAGS_pcsort.empty() &&
          (FLAGS_pcsort != "simple_sort" && FLAGS_pcsort != "sort" && FLAGS_pcsort != "no_sort")) {
        slog::err << "Invalid -pcsort option: " << FLAGS_pcsort << ". Please use one of sort, simple_sort, no_sort."
                  << slog::endl;
        return 1;
      }

      statistics =
          std::make_shared<StatisticsReport>(StatisticsReport::Config{FLAGS_save_run_summary, FLAGS_report_folder});
      statistics->addParameters(StatisticsReport::Category::COMMAND_LINE_PARAMETERS, command_line_arguments);
    }

    /** This vector stores paths to the processed images **/
    auto multi_input_files = VectorMap<std::vector<std::string>>(
        SplitMultiInputFilesArguments(net_size),  // get input directory list
        [&](const std::vector<std::string>& input_args) mutable {
          std::vector<std::string> files;
          for (auto& input_arg : input_args) {
            // Test if the path exists
            if (!ExistsTest(input_arg)) {
              slog::err << "Specified image path: " << input_arg << " does not exist" << slog::endl;
              throw std::logic_error("Image path does not exist");
            }
            // Test whether the path can be opened if it's a directory
            DirOpenTest(input_arg);
            readInputFilesArguments(files, input_arg);
          }
          return files;
        });

    if (multi_input_files.size() == 0) {
      // failed to read input files
      slog::err << "Failed to read input files" << slog::endl;
      return 1;
    }

    if (FLAGS_nstreams.empty()) {
      slog::warn << "-nstreams default value is determined automatically for a device. " << slog::endl;
      std::cout << "\tAlthough the automatic selection usually provides a reasonable performance, \n"
                << "\tbut it still may be non-optimal for some cases, for more information look at README."
                << std::endl;
    }

#ifdef DISABLE_JIT
    if (!network_file_flag.empty()) {
      slog::err << "Runtime compiled without support for Just-in-Time (JIT) execution!" << slog::endl
                << "Either specify a compiled model using -cm <compiled_model.aot> "
                << "or recompile the runtime without the -disable_jit flag." << slog::endl;
      return 1;
    }
#endif

    uint32_t num_batches = 1;

    // ----------------- 2. Loading OpenVINO Runtime/Inference Engine
    // -----------------------------------------------------------
    next_step();

    // Get optimal runtime parameters for device
    std::string device_name = FLAGS_d;
    if (!device_name.empty() && device_name.find("HETERO") == std::string::npos) {
      throw std::logic_error("Must specify HETERO:FPGA,CPU or HETERO:FPGA, or HETERO:CPU in dla_benchmark.");
    }
    if (is_model_compiled) {
      auto compiled_graph_paths = split(FLAGS_cm, MULTIGRAPH_SEP);  // separate each AOT file path
      for (auto& compiled_graph : compiled_graph_paths) {
        std::filebuf obj_file_buf;
        // There does not seem to be a way to get the device from the OpenVINO executable network
        // Instead we manually read through the xml header in the AOT graph to get the device name (an ugly hack
        // unfortunately)
        obj_file_buf.open(compiled_graph.c_str(), std::ios::in | std::ios::binary);
        std::istream obj_istream(&obj_file_buf);

        std::string current_device;
        {
          char c;
          while (obj_istream.get(c) && c != '\0') {
            current_device += c;
          }
        }

        if (device_name.empty()) {  // device flag not specified in AOT flow
          device_name = current_device;
        } else {
          if (current_device != device_name) {  // print error for non-matching devices
            throw std::logic_error(
                "The AOT file does not target the expected device: " + device_name + ". "
                "The AOT file is compiled for device: " + current_device + ". "
                "The device specified to dla_benchmark using the -d flag must be the same as the "
                "device specified to dla_compiler using the --fplugin flag.");
          }
        }
      }
    } else {
      if (device_name.empty()) device_name = "HETERO:CPU";  // default device for JIT flow is CPU
    }
    ov::Core core(FLAGS_plugins);
    bool CPU_used = device_name.find("CPU") != std::string::npos;
    bool FPGA_used = device_name.find("FPGA") != std::string::npos;
    if (FPGA_used) {
      CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::cpu_used.name(), CPU_used}});
    }

    if (FPGA_used) {
      if (arch_file_flag != "" && FLAGS_cm.empty()) {
        CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::arch_path.name(), arch_file_flag}});
        if (!ExistsTest(arch_file_flag)) {
          slog::err << "architecture file: " << arch_file_flag << " doesn't exist. Please provide a valid path."
                    << slog::endl;
          throw std::logic_error("architecture file path does not exist.");
        }
      }
      if (FLAGS_min_subgraph_layers < 1) {
        slog::err << "-min-subgraph-layers must be >= 1" << slog::endl;
        return 1;
      }
      CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::min_subgraph_layers.name(), FLAGS_min_subgraph_layers}});
      CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::enable_mmd_log_name.name(), FLAGS_dump_csr}});
    }

    if (CPU_used && !FLAGS_l.empty()) {
      // CPU extensions is loaded as a shared library and passed as a pointer to base extension
      core.add_extension(FLAGS_l);
      slog::info << "CPU extensions is loaded " << FLAGS_l << slog::endl;
    }

    slog::info << "OpenVINO: " << ov::get_openvino_version() << slog::endl;
    slog::info << "Device info: " << core.get_versions(device_name) << slog::endl;

    // ----------------- 3. Setting device configuration -----------------------------------------------------------
    next_step();

    auto devices = ParseDevices(device_name);
    std::map<std::string, uint32_t> device_nstreams = ParseNStreamsValuePerDevice(devices, FLAGS_nstreams);
    for (auto& pair : device_nstreams) {
      auto key = std::string(pair.first + "_THROUGHPUT_STREAMS");
      std::vector<ov::PropertyName> supported_config_keys = core.get_property(pair.first, ov::supported_properties);
      if (std::find(supported_config_keys.begin(), supported_config_keys.end(), key) == supported_config_keys.end()) {
        throw std::logic_error(
            "Device " + pair.first + " doesn't support config key '" + key + "'! " +
            "Please specify -nstreams for correct devices in format  <dev1>:<nstreams1>,<dev2>:<nstreams2>");
      }
    }

    // pc is for CPU only at the moment
    bool perf_count = FLAGS_pc;
    std::string perf_count_sort = FLAGS_pcsort;
    for (auto& device : devices) {
      if (device == "FPGA") {
        // limit threading for emulator inference, will not affect hardware inference
        if (FLAGS_nthreads != 0)
          core.set_property(device, ov::inference_num_threads(FLAGS_nthreads));
      } else if (device == "CPU") {  // CPU supports few special performance-oriented keys
#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
          // Force OV CPU profiling to be on if OPT_ENABLE_PERFORMANCE_PROFILER is set,
          // to ensure performance counters are collected for CPU execution if needed in hetero setups.
          core.set_property("CPU", ov::enable_profiling(true));
#endif
        if (perf_count || !perf_count_sort.empty()) {
          core.set_property("CPU", ov::enable_profiling(true));
        }
        // limit threading for CPU portion of inference
        if (FLAGS_nthreads != 0)
          core.set_property(device, ov::inference_num_threads(FLAGS_nthreads));
        // Set CPU to optimize throughput
        core.set_property(device, ov::hint::performance_mode(ov::hint::PerformanceMode::THROUGHPUT));
        // for CPU execution, more throughput-oriented execution via streams
        if (FLAGS_api == "async") {
          core.set_property(
              device,
              ov::streams::num(device_nstreams.count(device) > 0 ? ov::streams::Num(device_nstreams.at(device))
                                                                 : ov::streams::AUTO));
        }
        device_nstreams[device] = core.get_property(device, ov::streams::num);
      } else if (device == ("GPU")) {
        if (FLAGS_api == "async") {
          core.set_property(
              device,
              ov::streams::num(device_nstreams.count(device) > 0 ? ov::streams::Num(device_nstreams.at(device))
                                                                 : ov::streams::AUTO));
        }
        device_nstreams[device] = core.get_property(device, ov::streams::num);
      }
    }

    auto double_to_string = [](const double number) {
      std::stringstream ss;
      ss << std::fixed << std::setprecision(4) << number;
      return ss.str();
    };
    auto get_total_ms_time = [](Time::time_point& start_time) {
      return std::chrono::duration_cast<ns>(Time::now() - start_time).count() * 0.000001;
    };

    bool feed_fifo = FLAGS_streaming_input_pipe.empty();
    if (feed_fifo) {
      // the compiled model will create the fifo if it doesn't exist,
      // so we just need to set the name here
      std::string fifo_filename = "dla_benchmark_fifo_" + std::to_string(getpid());
      #if defined(_WIN32) || defined(_WIN64)
      FLAGS_streaming_input_pipe = std::string("\\\\.\\pipe\\LOCAL\\") + fifo_filename;
      #else
      fs::path temp_path;
      try {
        temp_path = fs::temp_directory_path();
      } catch (const fs::filesystem_error& e) {
        slog::warn << "Failed to get temporary directory path: " << e.what() << slog::endl;
        slog::info << "Using current working directory for FIFO file." << slog::endl;
        temp_path = fs::current_path();
      }
      fs::path fifo_path = temp_path / fs::path(fifo_filename);
      FLAGS_streaming_input_pipe = fifo_path.string();
      #endif
    } else {
      slog::info << "Using input streamed from pipe: " << FLAGS_streaming_input_pipe << slog::endl;
    }

    if (!FLAGS_jtag_path.empty()) {
      slog::info << "Using JTAG path " << FLAGS_jtag_path << " for system console runtimes. Will not be used for other runtimes." << slog::endl;
      CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::jtag_path.name(), FLAGS_jtag_path}});
    }

    size_t batch_size = batch_size_flag;
    std::vector<std::string> topology_names;
    ov::element::Type precision = ov::element::dynamic;
    // Vector stores which model (multigraph), InputsInfo is a map of input names and its respctive
    // input information
    std::vector<dla_benchmark::InputsInfo> input_infos;
    std::unordered_map<std::string, int> folder_name_counts;
    std::vector<std::string> network_directory_names;  // Track directory names for network_directories.txt
    if (!is_model_compiled) {
#ifndef DISABLE_JIT
      // We choose to ifdef out this block of code because it's more readable than
      // pulling the block in the "else" out using ifdefs
      // ----------------- 4. Reading the Intermediate Representation network ----------------------------------------
      next_step();

      LOG_AND_PRINT(Logger::INFO, "Loading network files\n");

      auto start_time_read = Time::now();
      // get list of graphs
      std::vector<std::shared_ptr<ov::Model>> models =
          VectorMap<std::shared_ptr<ov::Model>>(split(network_file_flag, MULTIGRAPH_SEP), [&](const std::string& m) {
            std::shared_ptr<ov::Model> model = core.read_model(m);
            model->set_friendly_name(
                dla::util::sanitizeModelFriendlyNameForFilesystem(model->get_friendly_name()));

            // Assign rt info IMMEDIATELY when DLA benchmark reads the model.
            // Applying transformations or reshaping may change node names.
            for (auto&& node : model->get_ops()) {
              if (dla::util::NodeTypeUsesPE(node->get_type_name())) {
                node->get_rt_info()[DLA_PE_PRECISION_MODE] =
                    dla::util::ParseNodeForRTInfo(node->get_friendly_name(), DLA_PE_PRECISION_MODE);
              }
            }

            printInputAndOutputsInfoShort(*model);
            return model;
          });

      auto duration_ms = double_to_string(get_total_ms_time(start_time_read));
      slog::info << "Read network(s) took " << duration_ms << " ms" << slog::endl;
      if (statistics)
        statistics->addParameters(StatisticsReport::Category::EXECUTION_RESULTS,
                                  {{"read network time (ms)", duration_ms}});
      // ----------------- 5. Resizing network to match image sizes and given batch ----------------------------------
      next_step();

      for (size_t i = 0; i < models.size(); i++) {
        const auto& model_inputs = std::const_pointer_cast<const ov::Model>(models[i])->inputs();
        bool reshape = false;
        input_infos.push_back(
            GetInputsInfo(batch_size, model_inputs, reshape, FLAGS_bin_data, FLAGS_mean_values, FLAGS_scale_values));
        if (reshape) {
          dla_benchmark::PartialShapes shapes = {};
          for (auto& item : input_infos.back()) shapes[item.first] = item.second.partial_shape;
          slog::info << "Reshaping model to batch: " << batch_size << slog::endl;
          models[i]->reshape(shapes);
        }
        topology_names.push_back(models[i]->get_friendly_name());
      }

      // ----------------- 6. Configuring input and output
      // ----------------------------------------------------------------------
      next_step();
      // Set input layouts for all models and their inputs
      size_t input_info_idx = 0;
      for (std::shared_ptr<ov::Model> model : models) {
        auto preproc = ov::preprocess::PrePostProcessor(model);
        const auto& inputs = model->inputs();
        for (size_t i = 0; i < inputs.size(); i++) {
          ov::preprocess::InputInfo& input_info = preproc.input(i);
          const size_t input_rank = inputs[i].get_partial_shape().size();
          const ov::Layout& layout = ov::Layout(dla::util::getTensorLayout(input_rank));
          const ov::element::Type_t type = input_infos[input_info_idx].at(inputs[i].get_any_name()).type;
          input_info.tensor().set_element_type(type).set_layout(layout);
        }

        const auto& outputs = model->outputs();
        for (size_t i = 0; i < outputs.size(); i++) {
          const size_t output_rank = outputs[i].get_partial_shape().size();
          const ov::Layout& layout = ov::Layout(dla::util::getTensorLayout(output_rank));
          auto& output_info = preproc.output(i);

          // There is a Transpose before the final output of the model.
          // Set the meta data to be NHWC so that the final result knows to insert a NHWC -> NCHW conversion
          // with the preproc.build() call.
          const auto output_transpose =
              dynamic_cast<const ov::op::v1::Transpose*>(outputs[i].get_node()->get_input_node_ptr(0));
          if (output_transpose) {
            const auto transpose_order =
                dynamic_cast<const ov::op::v0::Constant*>(output_transpose->get_input_node_ptr(1));
            // N=0,C=1,H=2,W=3
            // N=0,H=1,W=2,C=3
            const std::vector<int64_t> NHWC_ORDER = {0, 2, 3, 1};
            if (transpose_order && transpose_order->cast_vector<int64_t>() == NHWC_ORDER) {
              output_info.model().set_layout("NHWC");
            }
          }

          // Force output type to fp32
          // Force it to also be NC, NCHW, NCDHW depending on the rank.
          output_info.tensor().set_element_type(ov::element::f32).set_layout(layout);
        }
        // Once the build() method is called, the pre(post)processing steps
        // for layout and precision conversions are inserted automatically
        model = preproc.build();
        input_info_idx++;
      }
      // ----------------- 7. Loading the model to the device --------------------------------------------------------
      next_step();

      // Get the value from the command line arguments (if the command line argument wasn't
      // used by the user the default value set in dla_benchmark.hpp will be used)
      int folding_option = FLAGS_folding_option;
      bool fold_preprocessing = FLAGS_fold_preprocessing;
      bool estimate_per_layer = FLAGS_estimate_per_layer_latencies;
      bool enable_early_access = FLAGS_enable_early_access;
      // TODO(arooney): Remove this once LT hang is fixed.
      bool multi_infer_req = false;
      if (FLAGS_nireq > 1 && FLAGS_api == "async") {
        multi_infer_req = true;
      }
      CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::folding_option.name(), std::to_string(folding_option)}});
      CoreSetPropertyFPGA(core,
                        {{DLIAPlugin::properties::fold_preprocessing.name(), fold_preprocessing}});
      CoreSetPropertyFPGA(core,
                        {{DLIAPlugin::properties::per_layer_estimation.name(), estimate_per_layer}});
      CoreSetPropertyFPGA(core,
                        {{DLIAPlugin::properties::enable_early_access.name(), enable_early_access}});
      CoreSetPropertyFPGA(core,
                        {{DLIAPlugin::properties::multiple_inferences.name(), multi_infer_req}});

      CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::streaming_input_pipe.name(), FLAGS_streaming_input_pipe}});

      CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::dump_additional_perf_est.name(), FLAGS_dump_additional_perf_est}});

      auto start_time = Time::now();
      auto individual_start_time = Time::now();  // timer for each individual graph loading

      compiled_models = VectorMap<ov::CompiledModel*>(models, [&](std::shared_ptr<ov::Model> model) {
        // Apply Low Precision transformations to handle quantized graphs
        // Mohamed_I: currently, this only works if the entire graph fits on the FPGA
        // because the CPU plugin calls common_optimizations again which has some transformations
        // that cause the graph to fail (I suspect it's the ConvolutionMultiplyFusion, but I
        // cannot disable it from the CPU)
        std::string network_name = model->get_friendly_name();
        std::string final_network_name = network_name;  // Track the final name used

        std::string network_subdir = base_output_dir + network_name + separator;
        std::string report_subdir = network_subdir + "reports" + separator;

        // Check if this folder name has been used before
        if (folder_name_counts.find(network_name) != folder_name_counts.end()) {
          // Duplicate found - append "_N" suffix
          int count = folder_name_counts[network_name];
          std::string unique_name = network_name + "_" + std::to_string(count);
          final_network_name = unique_name;
          network_subdir = base_output_dir + unique_name + separator;
          report_subdir = network_subdir + "reports" + separator;
          folder_name_counts[network_name]++;
        } else {
          // First occurrence of this name
          folder_name_counts[network_name] = 1;
        }

        network_directory_names.push_back(final_network_name);

        std::string on_chip_parameters_subdir = dla::util::get_on_chip_parameters_dumpdir(network_subdir);
        ov::AnyMap config;
        CreateDir(network_subdir);
        // Create directories
        if (FPGA_used) {
          CreateDir(report_subdir);
          CreateDir(on_chip_parameters_subdir);
          config.emplace(DLIAPlugin::properties::cpu_used.name(), CPU_used);
          config.emplace(DLIAPlugin::properties::export_dir.name(), network_subdir);
          config.emplace(DLIAPlugin::properties::on_chip_parameters_export_dir.name(), on_chip_parameters_subdir);
        }

        for (auto&& node : model->get_ops()) {
          if (std::string("FakeQuantize") == node->get_type_name()) {
            config.emplace(DLIAPlugin::properties::apply_low_precision_transforms.name(), true);
            if (CPU_used && FPGA_used) {
              std::cerr << "ERROR: Quantized graphs only supported through HETERO:FPGA or CPU." << std::endl;
              throw std::logic_error("HETERO:FPGA,CPU plugin is not supported for quantization.");
            }
          }
        }

        auto compiled_model = new ov::CompiledModel();
        *compiled_model = core.compile_model(model, device_name, config);
        duration_ms = double_to_string(get_total_ms_time(individual_start_time));
        individual_start_time = Time::now();
        slog::info << "Compile model ( " << model->get_friendly_name() << " ) took " << duration_ms << " ms"
                   << slog::endl;
        printInputAndOutputsInfoShort(*compiled_model, true);
        if (FLAGS_enable_object_detection_ap) {
          if (!CheckIsYOLO(*compiled_model, FLAGS_yolo_version)) {
            slog::err << "ERROR: Object-detection mode is enabled, but the loaded model is not a YOLO model.\n"
                      << "Provide a YOLO model or disable object-detection mode (remove --enable_object_detection_ap)."
                      << slog::endl;
            throw std::logic_error("Object-detection mode requires a YOLO model.");
          }
        }
        return compiled_model;
      });
      duration_ms = double_to_string(get_total_ms_time(start_time));
      slog::info << "Load network(s) took " << duration_ms << " ms" << slog::endl;
      if (statistics)
        statistics->addParameters(StatisticsReport::Category::EXECUTION_RESULTS,
                                  {{"load network time (ms)", duration_ms}});
#endif
    } else {
      next_step();
      slog::info << "Skipping the step for compiled network" << slog::endl;
      next_step();
      slog::info << "Skipping the step for compiled network" << slog::endl;
      next_step();
      slog::info << "Skipping the step for compiled network" << slog::endl;
      // ----------------- 7. Loading the model to the device --------------------------------------------------------
      next_step();
      auto compiled_graph_paths = split(FLAGS_cm, MULTIGRAPH_SEP);   // get a list of compiled graphs

      compiled_models = vectorMapWithIndex<ov::CompiledModel*>(
          compiled_graph_paths,
          [&](const std::string& compiled_graph_path, size_t index){
            std::stringstream generated_name;
            generated_name << "Graph_" << index;

            std::string network_name = generated_name.str();
            std::string final_network_name = network_name;  // Track the final name used
            std::string network_subdir = base_output_dir + network_name + separator;
            std::string report_subdir = network_subdir + "reports" + separator;

            // Check if this folder name has been used before
            if (folder_name_counts.find(network_name) != folder_name_counts.end()) {
              // Duplicate found - append "_N" suffix
              int count = folder_name_counts[network_name];
              std::string unique_name = network_name + "_" + std::to_string(count);
              final_network_name = unique_name;
              network_subdir = base_output_dir + unique_name + separator;
              report_subdir = network_subdir + "reports" + separator;
              folder_name_counts[network_name]++;
            } else {
              // First occurrence of this name
              folder_name_counts[network_name] = 1;
            }

            network_directory_names.push_back(final_network_name);

            std::string on_chip_parameters_subdir = dla::util::get_on_chip_parameters_dumpdir(network_subdir);

            // Create directories
            CreateDir(network_subdir);
            if (FPGA_used) {
              CreateDir(report_subdir);
              CreateDir(on_chip_parameters_subdir);
            }

            slog::info << "Importing model from " << compiled_graph_paths[index] << " to " << device_name << " as "
                       << generated_name.str() << slog::endl;
            auto start_time = Time::now();
            std::ifstream model_stream(compiled_graph_paths[index].c_str(), std::ios_base::in | std::ios_base::binary);
            if (!model_stream.is_open()) {
              throw std::runtime_error("Cannot open compiled model file: " + compiled_graph_paths[index]);
            }
            std::string compiled_model_device;
            {
              char c;
              while (model_stream.get(c) && c != '\0') {
                compiled_model_device += c;
              }
              if (compiled_model_device != device_name) {
                throw std::runtime_error("The compiled model is not for the " + device_name + " device. "
                                        "The compiled model is for the " + compiled_model_device + " device.");
              }
            }

            std::string rest_of_data(
              (std::istreambuf_iterator<char>(model_stream)),
              std::istreambuf_iterator<char>());
            model_stream.close();
            std::istringstream rest_of_data_stream(rest_of_data);


            auto compiled_model = new ov::CompiledModel();
            CoreSetPropertyFPGA(core,
                              {{DLIAPlugin::properties::streaming_input_pipe.name(), FLAGS_streaming_input_pipe}});
            // Import specific configs
            ov::AnyMap config;
            config.emplace(DLIAPlugin::properties::export_dir.name(), network_subdir);
            config.emplace(DLIAPlugin::properties::on_chip_parameters_export_dir.name(), on_chip_parameters_subdir);
            *compiled_model = core.import_model(rest_of_data_stream, device_name, config);
            topology_names.push_back(generated_name.str());
            printInputAndOutputsInfoShort(*compiled_model, true);
            if (FLAGS_enable_object_detection_ap) {
              if (!CheckIsYOLO(*compiled_model, FLAGS_yolo_version)) {
                slog::err << "ERROR: Object-detection mode is enabled, but the loaded model is not a YOLO model.\n"
                          << "Provide a YOLO model or disable object-detection mode (remove --enable_object_detection_ap)."
                          << slog::endl;
                throw std::logic_error("Object-detection mode requires a YOLO model.");
              }
            }
            auto duration_ms = double_to_string(get_total_ms_time(start_time));
            slog::info << "Import model took " << duration_ms << " ms" << slog::endl;
            if (statistics)
              statistics->addParameters(StatisticsReport::Category::EXECUTION_RESULTS,
                                        {{"import model time (ms)", duration_ms}});
            if (batch_size == 0) {
              batch_size = 1;
            }
            const auto& inputs = compiled_model->inputs();
            for (const auto& item : inputs) {
              const auto& shape = item.get_shape();
              if (shape[0] != batch_size) {
                slog::err << "Batch size of the compiled model is " << shape[0] << " and batch size provided is "
                          << batch_size << slog::endl;
                std::cout << "Set the same batch size = " << shape[0] << " when running the app" << std::endl;
                std::cout << "Or recompile model with batch size = " << batch_size << std::endl;
                exit(5);
              }
            }
            bool reshape_required = false;
            input_infos.push_back(GetInputsInfo(batch_size,
                                                compiled_model->inputs(),
                                                reshape_required,
                                                FLAGS_bin_data,
                                                FLAGS_mean_values,
                                                FLAGS_scale_values));
            return compiled_model;
          });
    }
    // ----------------- 8. Setting optimal runtime parameters -----------------------------------------------------
    next_step();

    // Number of requests
    uint32_t nireq = FLAGS_nireq;
#if defined(__arm__) | defined(__aarch64__)
    // In OpenVINO 2022.3 Arm plugin, when a AOT graph is compiled on CPU and dla_benchmark has -nireq > 1
    // the program will be killed. We force nireq = 1 for HETERO:CPU graph only.
    // Note: -d CPU doesn't need to be checked for AOT because dlac does not support -fplugin CPU.
    if (device_name == "HETERO:CPU" && nireq > 1) {
      slog::warn << "-nireq > 1 is not supported for HETERO:CPU graph. Forcing -nireq = 1" << slog::endl;
      nireq = 1;
    }

#endif

    if (nireq == 0) {
      if (FLAGS_api == "sync") {
        nireq = 1;
      } else {
        try {
          nireq = 0;
          for (auto& compiled_model : compiled_models) {
            auto req = compiled_model->get_property(ov::optimal_number_of_infer_requests);
            if (nireq == 0 || nireq > req) nireq = req;
          }
        } catch (const std::exception& ex) {
          OPENVINO_THROW("Every device used with the dla_benchmark should support " +
                         std::string(ov::optimal_number_of_infer_requests.name()) +
                         " Failed to query the metric for the " + device_name + " with error: " +
                         ex.what());
        }
      }
    }
    // Graph-request limit on device
    bool has_fpga = false;
    try {
      unsigned int ip_num_instances = (unsigned int) CoreGetPropertyFPGA(core, "COREDLA_NUM_INSTANCES").as<int>();
      unsigned int numOutstandingInferRequest = (nireq * net_size + ip_num_instances - 1U) / ip_num_instances;
      unsigned int maxOutstandingInferRequest = (unsigned int) CoreGetPropertyFPGA(core, "COREDLA_MAX_NUMBER_INFERENCE_REQUESTS_PER_INSTANCE").as<int>();
      if ((maxOutstandingInferRequest * ip_num_instances) < net_size) {
        slog::err << "Too many networks (" << net_size
                << "). Lower the number of networks to "<< maxOutstandingInferRequest * ip_num_instances <<" or less."
                << slog::endl;
        return 1;
      }
      // If the benchmark is tasked with automatically picking a number of inference request during async mode, then it should pick a reasonable one
      uint32_t nireq_fpga = FLAGS_nireq;
      if (nireq_fpga == 0 && FLAGS_api == "async") {
        auto hw_limit_nireq = maxOutstandingInferRequest * ip_num_instances / net_size;
        nireq = (hw_limit_nireq < nireq) ? hw_limit_nireq : nireq;
      }
      if (maxOutstandingInferRequest > 0 && numOutstandingInferRequest > maxOutstandingInferRequest) {
        slog::err << "Possible number of outstanding inference requests per instance (" << numOutstandingInferRequest
                  << ") "
                  << "exceeds the runtime plugin's limit (" << maxOutstandingInferRequest << "). "
                  << "Please decrease the number of inference requests and the number of networks."
                  << slog::endl;
        return 1;
      }
      has_fpga = true;
    } catch (const std::exception& e) {
      // Catch the errors throw by "CheckFPGADevice" when getting FPGA property, defined in dla_plugin/inc/dlia_plugin.h
      // These errors might arise if there are no sub-graphs mapped to the FPGA by the compiler
      std::string error_message = e.what();
      if (error_message.find("Failed to fetch FPGA property") != std::string::npos) {
        if (FPGA_used) {
          slog::warn << "Target device specifies an FPGA, but no subgraph from any input model can be mapped to the FPGA." << slog::endl;
        }
      } else {
        slog::err << "Exception occured while trying to query property from the FPGA plugin: " << error_message << slog::endl;
      }
    }
    // nireq limit for FPGA
    if (has_fpga) {
      auto max_nireq = -1;
      for (auto& compiled_model : compiled_models) {
        auto max_reqs = compiled_model->get_property(DLIAPlugin::properties::max_infer_requests.name()).as<int>();
        max_nireq = (max_reqs > 0) ? (max_nireq == -1 ? max_reqs : std::min(max_nireq, max_reqs)) : max_nireq;
      }
      if (max_nireq > 0 && nireq > static_cast<uint32_t>(max_nireq)) {
        slog::warn << "Number of infer requests (" << nireq
                   << ") exceeds the maximum number of infer requests supported by the FPGA (" << max_nireq
                   << "). Limiting nireq to " << max_nireq << "." << slog::endl;
        nireq = max_nireq;
      }
    }

    // Iteration limit
    uint32_t niter = FLAGS_niter;
    if (niter > 0) {
      // Round up niter to a multiple of nireq
      niter = ((niter + nireq - 1) / nireq) * nireq;
      // We previously checked that FLAGS_niter >= 0, so okay to cast to uint.
      if (static_cast<uint32_t>(FLAGS_niter) != niter) {
        slog::warn << "Number of iterations was aligned by request number from " << FLAGS_niter << " to " << niter
                   << " using number of requests " << nireq << slog::endl;
      }
      num_batches = niter;
    } else if (niter > 0) {
      num_batches = niter;
    }

    if (statistics) {
      for (auto& topology_name : topology_names) {
        statistics->addParameters(StatisticsReport::Category::RUNTIME_CONFIG,
                                  {
                                      {"topology", topology_name},
                                      {"target device", device_name},
                                      {"API", FLAGS_api},
                                      {"precision", std::string(precision.get_type_name())},
                                      {"batch size", std::to_string(batch_size)},
                                      {"number of iterations", std::to_string(niter)},
                                      {"number of parallel infer requests", std::to_string(nireq)},
                                  });
      }
      for (auto& nstreams : device_nstreams) {
        std::stringstream ss;
        ss << "number of " << nstreams.first << " streams";
        statistics->addParameters(StatisticsReport::Category::RUNTIME_CONFIG,
                                  {
                                      {ss.str(), std::to_string(nstreams.second)},
                                  });
      }
    }

    // ----------------- 9. Creating infer requests and filling input blobs ----------------------------------------
    next_step();

    // check property to see if this is a streaming architecture
    bool is_streaming = false;
    ov::AnyMap streaming_properties;
    // streaming property is only available for FPGA device
    if (has_fpga) {
      for (auto& compiled_model : compiled_models) {
        streaming_properties = compiled_model->get_property(DLIAPlugin::properties::streaming_properties.name()).as<ov::AnyMap>();
        if (streaming_properties["has_input_streaming"].as<bool>()) {
          is_streaming = true;
          slog::info << "Detected streaming architecture from compiled model." << slog::endl;
          if (compiled_models.size() > 1) {
            throw std::logic_error("Detected " + std::to_string(compiled_models.size()) +
              " compiled models. dla_benchmark currently does not support streaming with multiple compiled models.");
          }
          break;
        }
      }
    }

    // Perform online reconfiguration if applicable
    if (FLAGS_online_reconfig != "none") {
      if (!has_fpga) {
        slog::warn << "Online reconfiguration is only supported on FPGA device. Skipping online reconfiguration."
                   << slog::endl;
      } else if (!is_streaming) {
        slog::warn << "Online reconfiguration is only supported for architectures with on-chip parameters. Skipping online reconfiguration."
                   << slog::endl;
      } else if (FLAGS_online_reconfig == "") {
        // dump mifs from compiled model
        std::string mifs_path = compiled_models[0]->get_property(DLIAPlugin::properties::export_mif_files.name()).as<std::string>();
        slog::info << "Applying online reconfiguration from files generated during compilation." << slog::endl;
        try {
          CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::online_reconfig.name(), mifs_path}});
        } catch (const std::exception& e) {
          slog::err << "Failed to apply online reconfiguration with error: " << e.what() << slog::endl;
          return 1;
        }
      } else {
        slog::info << "Applying online reconfiguration from mif folder: " << FLAGS_online_reconfig << slog::endl;
        try {
          CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::online_reconfig.name(), FLAGS_online_reconfig}});
        } catch (const std::exception& e) {
          slog::err << "Failed to apply online reconfiguration with error: " << e.what() << slog::endl;
          return 1;
        }
      }
      if (FLAGS_niter == 0) {
        slog::info << "Online reconfiguration applied. Exiting since no inference iterations were specified." << slog::endl;
        if (feed_fifo) {
          // remove the fifo file
          try {
            fs::path fifo_path(FLAGS_streaming_input_pipe);
            if (fs::exists(fifo_path)) {
              fs::remove(fifo_path);
            }
          } catch (const fs::filesystem_error& e) {
            slog::warn << "Failed to remove FIFO file: " << e.what() << slog::endl;
          }
        }
        return 0;
      }
    }

    // Data structure hierarchy
    // Outermost vec: which model it corresponds to (multigraph)
    // Map: input/output name and its corresponding TensorVector
    // TensorVector: An alias for vector<ov::tensor> where each vector element correspond to the batch
    std::vector<std::map<std::string, ov::TensorVector>> input_data_tensors;
    std::vector<std::map<std::string, ov::TensorVector>> output_tensors(compiled_models.size());
    std::vector<std::vector<std::vector<uint8_t>>> streaming_input_buffers;

    std::vector<std::unique_ptr<InferRequestsQueue>> infer_request_queues;
    const std::string resize_type = FLAGS_resize_type.empty() ? "resize" : FLAGS_resize_type;
    FormatReader::Reader::ResizeType resize_type_enum =
    (resize_type == "resize")
        ? FormatReader::Reader::ResizeType::RESIZE
        : FormatReader::Reader::ResizeType::PAD_RESIZE;

    for (size_t net_idx = 0; net_idx < compiled_models.size(); net_idx++) {
      // Handle the case that use same inputs for all networks
      const auto& inputFiles =
          net_idx >= multi_input_files.size() ? multi_input_files.back() : multi_input_files[net_idx];
      if (is_streaming) {
        if (feed_fifo) {
          int padded_streaming_input_size = streaming_properties["padded_input_size"].as<int>();
          int streaming_input_size = streaming_properties["input_size"].as<int>();
          streaming_input_buffers.push_back(GetStreamingInputs(inputFiles.empty() ? std::vector<std::string>{} : inputFiles,
                                                              streaming_input_size, padded_streaming_input_size, num_batches));
        }
      } else {
        input_data_tensors.push_back(GetStaticTensors(inputFiles.empty() ? std::vector<std::string>{} : inputFiles,
                                                      batch_size,
                                                      input_infos[net_idx],
                                                      num_batches,
                                                      resize_type_enum,
                                                      FLAGS_bgr,
                                                      FLAGS_bin_data,
                                                      !feed_fifo,
                                                      FLAGS_verbose));
      }
      // Use unique_ptr to create InferRequestsQueue objects and avoid copying mutex and cv
      infer_request_queues.push_back(
          std::move(std::unique_ptr<InferRequestsQueue>(new InferRequestsQueue(*(compiled_models[net_idx]), nireq, net_idx))));
    }
    // ----------------- 10. Measuring performance ------------------------------------------------------------------

    size_t progress_bar_total_count = progressBarDefaultTotalCount;

    std::stringstream ss;
    ss << "Start inference " << FLAGS_api << "ronously";
    if (FLAGS_api == "async") {
      if (!ss.str().empty()) {
        ss << ", ";
      }
      ss << infer_request_queues.size() * infer_request_queues.at(0)->requests.size() << " inference requests";
      std::stringstream device_ss;
      for (auto& nstreams : device_nstreams) {
        if (!device_ss.str().empty()) {
          device_ss << ", ";
        }
        device_ss << nstreams.second << " streams for " << nstreams.first;
      }
      if (!device_ss.str().empty()) {
        ss << " using " << device_ss.str();
      }
    }
    ss << ", limits: " << niter << " iterations with each graph, " << compiled_models.size() << " graph(s)";
    progress_bar_total_count = niter;
    next_step(ss.str());

    /** Start inference & calculate performance **/
    /** to align number if iterations to guarantee that last infer requests are executed in the same conditions **/
    ProgressBar progress_bar(progress_bar_total_count, FLAGS_stream_output, FLAGS_progress);
    std::vector<size_t> iterations(compiled_models.size(), 0);

    // setup fifo feeding if needed
    std::condition_variable fifo_cv;
    std::mutex fifo_mutex;
    bool fifo_stop = false;
    std::thread fifo_feeder;
    std::vector<uint8_t>* current_streaming_input_buffer = nullptr;
    auto feed_fifo_fun =
    [&](std::string fifo_path) {
      dla::sequential_fifo::Handle writer = dla::sequential_fifo::Handle(fifo_path, dla::sequential_fifo::Mode::WRITE, true);
      std::unique_lock<std::mutex> lock(fifo_mutex);
      while (!fifo_stop) {
        // wait for new data to be queued
        fifo_cv.wait(lock, [&]() { return current_streaming_input_buffer != nullptr || fifo_stop; });
        if (fifo_stop) {
          break;
        }
        writer.lock()->write(*current_streaming_input_buffer);
        current_streaming_input_buffer = nullptr;
        fifo_cv.notify_all();
      }
    };

    if (is_streaming && feed_fifo) {
      // fifo should already have a reader attached from the compiled model
      // if it didn't then this would block on linux
      fifo_feeder = std::thread(feed_fifo_fun, FLAGS_streaming_input_pipe);
    }

    // Get the models that have dynamic output
    std::vector<bool> has_dynamic_output(compiled_models.size(), false);
    for (size_t net_id = 0; net_id < compiled_models.size(); net_id++) {
      for (const auto &output : compiled_models[net_id]->outputs()) {
        if (output.get_partial_shape().is_dynamic()) {
          has_dynamic_output[net_id] = true;
          break;
        }
      }
    }

    try {
      while ((niter != 0LL && iterations.back() < niter) || (FLAGS_api == "async" && iterations.back() % nireq != 0)) {
        // set up all infer request and prep all i/o Blobs
        for (size_t net_id = 0; net_id < compiled_models.size(); net_id++) {
          for (size_t iireq = 0; iireq < nireq; iireq++) {
            auto infer_request = infer_request_queues.at(net_id)->get_idle_request();
            if (!infer_request) {
              OPENVINO_THROW("No idle Infer Requests!");
            }
            if (niter != 0LL) {
              if (!has_dynamic_output[net_id]) {
                const auto& outputs = compiled_models[net_id]->outputs();

                for (const auto& output : outputs) {
                  const std::string& name = output.get_any_name();

                  output_tensors.at(net_id)[name].emplace_back(output.get_element_type(), output.get_shape());
                  infer_request->set_tensor(output, output_tensors.at(net_id).at(name).at(iterations.at(net_id)));
                }
              }
              if (is_streaming) {
                if (feed_fifo) {
                  // wait for previous data to be written
                  std::unique_lock<std::mutex> lock(fifo_mutex);
                  fifo_cv.wait(lock, [&]() { return current_streaming_input_buffer == nullptr; });
                  current_streaming_input_buffer = &(streaming_input_buffers.at(net_id).at(iterations.at(net_id)));
                  lock.unlock();
                  fifo_cv.notify_all();
                }
              } else {
                const auto& inputs = compiled_models[net_id]->inputs();
                for (auto& input : inputs) {
                  const std::string& name = input.get_any_name();
                  const auto& data = input_data_tensors.at(net_id).at(name)[iterations.at(net_id)];
                  infer_request->set_tensor(input, data);
                }
              }
            }

            // Execute one request/batch
            // TODO(billlin): instead of reusing the same inference requests per iteration for models that have dynamic output,
            // make a new inference request for each iteration. this way we could do those asynchronously
            // only have to do this for models that have dynamic output.
            if (FLAGS_api == "sync" || has_dynamic_output[net_id]) {
              infer_request->infer();
              if (has_dynamic_output[net_id]) {
                // If output is dynamic, then get the output tensors because we couldn't have allocated memory for it previously
                for (size_t output_idx = 0; output_idx < compiled_models[net_id]->outputs().size(); output_idx++) {
                  const std::string& name = compiled_models[net_id]->outputs()[output_idx].get_any_name();
                  ov::Tensor tensor = infer_request->get_output_tensor(output_idx);
                  // deepcopy the tensor so that memory isn't shared.
                  ov::Tensor tensor_copy(tensor.get_element_type(), tensor.get_shape());
                  std::memcpy(tensor_copy.data(), tensor.data(), tensor.get_byte_size());

                  output_tensors.at(net_id)[name].push_back(tensor_copy);
                }
              }
            } else {
              // As the inference request is currently idle, the wait() adds no additional overhead (and should return
              // immediately). The primary reason for calling the method is exception checking/re-throwing. Callback,
              // that governs the actual execution can handle errors as well, but as it uses just error codes it has no
              // details like ‘what()’ method of `std::exception` So, rechecking for any exceptions here.
              infer_request->wait();
              infer_request->start_async();
            }
            iterations.at(net_id)++;
            if (net_id == compiled_models.size() - 1) {
              progress_bar.addProgress(1);
            }
          }
        }
      }

      // wait the latest inference executions
      for (auto& infer_request_queue : infer_request_queues) {
        infer_request_queue->wait_all();
      }
    } catch (const std::exception& ex) {
      slog::err << "Inference failed:" << slog::endl;
      slog::err << dla::user_facing_message(ex) << slog::endl;
      if (has_fpga) {
        ReadDebugNetworkInfo(core);
        PrintLSUCounterInfo(core);
      }
      if (fifo_feeder.joinable()) {
        {
          std::lock_guard<std::mutex> lock(fifo_mutex);
          fifo_stop = true;
        }
        fifo_cv.notify_all();
        fifo_feeder.join();
      }
      if (feed_fifo) {
        // remove the fifo file
        try {
          fs::path fifo_path(FLAGS_streaming_input_pipe);
          if (fs::exists(fifo_path)) {
            fs::remove(fifo_path);
          }
        } catch (const fs::filesystem_error& e) {
          slog::warn << "Failed to remove FIFO file: " << e.what() << slog::endl;
        }
      }

      // Instead of setting return_code = 1 and continuing, exit immediately.
      // High risk of segfaulting / weird behavior when inference fails.
      return 1;
    }
    if (fifo_feeder.joinable()) {
      {
        std::lock_guard<std::mutex> lock(fifo_mutex);
        fifo_stop = true;
      }
      fifo_cv.notify_all();
      fifo_feeder.join();
    }
    if (feed_fifo) {
      // remove the fifo file
      try {
        fs::path fifo_path(FLAGS_streaming_input_pipe);
        if (fs::exists(fifo_path)) {
          fs::remove(fifo_path);
        }
      } catch (const fs::filesystem_error& e) {
        slog::warn << "Failed to remove FIFO file: " << e.what() << slog::endl;
      }
    }


    size_t iteration = iterations.back();

    std::vector<double> all_latencies;
    auto start_time = infer_request_queues.at(0)->get_start_time();
    auto end_time = infer_request_queues.at(0)->get_end_time();
    for (auto& infer_request_queue : infer_request_queues) {
      auto& latencies = infer_request_queue->get_latencies();
      all_latencies.insert(all_latencies.end(), latencies.begin(), latencies.end());
      start_time = std::min(start_time, infer_request_queue->get_start_time());
      end_time = std::max(end_time, infer_request_queue->get_end_time());
    }
    double latency = GetMedianValue<double>(all_latencies);
    double total_duration = std::chrono::duration_cast<ns>(end_time - start_time).count() * 0.000001;
    double total_fps = (FLAGS_api == "sync")
                           ? compiled_models.size() * batch_size * 1000.0 / latency
                           : compiled_models.size() * batch_size * 1000.0 * iteration / total_duration;

    int ip_num_instances = 0;
    double ip_duration = 0.0;
    double ip_fps = 0.0;
    double ip_fps_per_fmax = 0.0;
    std::vector<double> estimated_ipFps;
    std::vector<double> estimated_ipFpsPerFmax;
    double fmax_core = -1.0;
    double ddr_clock = -1.0;
    double estimated_ipFps_assumed_fmax = 0.0;
    if (has_fpga) {
      ip_num_instances = CoreGetPropertyFPGA(core, "COREDLA_NUM_INSTANCES").as<int>();
      // even if hardware has 2 instances, only 1 instance actually gets used if only 1 inference is performed
      size_t ip_num_instances_used = std::min((size_t)ip_num_instances, iteration);
      ip_duration = CoreGetPropertyFPGA(core, "IP_ACTIVE_TIME").as<double>();
      ddr_clock = CoreGetPropertyFPGA(core, "COREDLA_DDR_CLOCK_FREQUENCY").as<double>();
      if (ip_duration) {
        if (ip_duration != 0.0) {
          ip_fps = compiled_models.size() * batch_size * 1000.0 * iteration / ip_duration / ip_num_instances_used;
        }
        fmax_core = CoreGetPropertyFPGA(core, "COREDLA_CLOCK_FREQUENCY").as<double>();
        if (fmax_core > 0.0) {
          ip_fps_per_fmax = ip_fps / fmax_core;
        } else {
          slog::warn << "Warning: could not estimate clk_dla frequency on the FPGA" << slog::endl;
        }
      }

      if (FLAGS_perf_est && FPGA_used) {
        if (is_model_compiled) {
          // Ahead of Time Flow: getting the imported, precalculated performance estimate
          estimated_ipFps = CoreGetPropertyFPGA(core, "IMPORT_PERFORMANCE_EST").as<std::vector<double>>();
          estimated_ipFps_assumed_fmax = CoreGetPropertyFPGA(core, "IMPORT_PERFORMANCE_EST_ASSUMED_FMAX").as<double>();
        } else {
#ifndef DISABLE_JIT
          // Just In Time Flow: running the performance estimate

          // Populate the available DDR bandwidth. If unspecified, the value would be negative
          // The performance estimator would then adopt the default value based on family.
          double ddr_bw = (double) FLAGS_ddr_bw;
          CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::assumed_ddr_bandwidth.name(), std::to_string(ddr_bw)}});
          if (fmax_core > 0.0) {
            CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::assumed_fmax_core.name(), std::to_string(fmax_core)}});
            CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::assumed_pe_fmax_core.name(), std::to_string(fmax_core)}});
            estimated_ipFps_assumed_fmax = fmax_core;
          } else {
            // In case the fmax_core variable is not set, we use the estimated fmax values for AGX7 and A10.
            // This can happen if inference is ran without a FPGA board attached
#ifdef DE10_AGILEX
            estimated_ipFps_assumed_fmax = 500;  // AGX7 fMAX estimate
#else
            estimated_ipFps_assumed_fmax = 265;  // A10 fMAX estimate
#endif
            slog::warn
                << "Warning: could not estimate clk_dla frequency on the FPGA, setting the fmax to default value."
                << slog::endl;
            CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::assumed_fmax_core.name(), std::to_string(estimated_ipFps_assumed_fmax)}});
            CoreSetPropertyFPGA(core, {{DLIAPlugin::properties::assumed_pe_fmax_core.name(), std::to_string(estimated_ipFps_assumed_fmax)}});
          }
        estimated_ipFps = CoreGetPropertyFPGA(core, "PLUGIN_PERFORMANCE_EST").as<std::vector<double>>();
        dla::util::PrintSectionDivider(std::cout);
#endif
        }
        estimated_ipFpsPerFmax.reserve(estimated_ipFps.size());
        // Divide every element of estimated_ipFPS by estimated_ipFps_assumed_fmax and insert into estimated_ipFpsPerFmax
        std::transform(
            estimated_ipFps.begin(),
            estimated_ipFps.end(),
            std::back_inserter(estimated_ipFpsPerFmax),
            [estimated_ipFps_assumed_fmax](double numerator) {
              return numerator / estimated_ipFps_assumed_fmax;
          });
          if (estimated_ipFps.size() != compiled_models.size() || estimated_ipFpsPerFmax.size() != compiled_models.size()) {
            throw dla::errors::runtime_error("Mismatch in number of compiled models " + std::to_string(compiled_models.size()) +
                                            " and number of performance estimates " + std::to_string(estimated_ipFps.size()) + ".");
          }
      }

      // Optional overrides for the printed summary only (avoids rebuilding when MMD reports stale compile-time clocks)
      if (FLAGS_ddr_clock_override > 0.0) {
        // Recalculate IP duration
        double clocks_active = ip_duration * ddr_clock * 1000.0;
        ip_duration = clocks_active / (FLAGS_ddr_clock_override * 1000.0);

        // Recalculate IP Throughput
        ip_fps = compiled_models.size() * batch_size * 1000.0 * iteration / ip_duration / ip_num_instances_used;

        // Recalculate IP FPS per IP MHz
        ip_fps_per_fmax = ip_fps / fmax_core;

        ddr_clock = FLAGS_ddr_clock_override;
      }

      if (FLAGS_ip_clock_override > 0.0) {
        if (ip_fps != 0.0 && fmax_core > 0.0) {
          // Recalculate IP FPS per IP MHz with the overridden clock
          ip_fps_per_fmax = ip_fps / FLAGS_ip_clock_override;
        }

        fmax_core = FLAGS_ip_clock_override;
      }
    }

    if (statistics) {
      statistics->addParameters(StatisticsReport::Category::EXECUTION_RESULTS,
                                {
                                    {"total execution time (ms)", double_to_string(total_duration)},
                                    {"IP active time (ms)", double_to_string(ip_duration)},
                                    {"total number of iterations", std::to_string(iteration)},
                                });
      if (device_name.find("MULTI") == std::string::npos) {
        statistics->addParameters(StatisticsReport::Category::EXECUTION_RESULTS,
                                  {
                                      {"latency (ms)", double_to_string(latency)},
                                  });
      }
      statistics->addParameters(
          StatisticsReport::Category::EXECUTION_RESULTS,
          {{"throughput", double_to_string(total_fps)}, {"IP throughput", double_to_string(ip_fps)}});
    }

    progress_bar.finish();

    // ----------------- 11. Dumping statistics report -------------------------------------------------------------
    next_step();

    if (perf_count || !perf_count_sort.empty()) {
      std::vector<std::vector<ov::ProfilingInfo>> perfCounts;
      for (size_t ireq = 0; ireq < nireq; ireq++) {
        auto reqPerfCounts = infer_request_queues.at(0)->requests[ireq]->get_performance_counts();
        perfCounts.push_back(reqPerfCounts);
      }
      if (statistics) {
        if (perf_count_sort == "sort") {
          statistics->printPerfCountersSort(perfCounts, "sort");
        } else if (perf_count_sort == "simple_sort") {
          statistics->printPerfCountersSort(perfCounts, "simple_sort");
        } else {
          statistics->printPerfCountersSort(perfCounts, "no_sort");
        }
      }
    }

    // dla_benchmark originally also implemented more detailed performance
    // statistics via InferRequest's getPerformanceCounts function
    // We did not support it, and removed it. If we want to re-implement it
    // looking at the latest version of OpenVINO's benchmark_app or our git
    // history would be a good starting point
    if (statistics) {
      statistics->dump();
    }


#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
    // If the OPT_ENABLE_PERFORMANCE_PROFILER macro is defined, we ensure that CPU enable_profiling() is true. Force a dump of the statistics:

      // The map should be from model_name to a vector of LayerInfo objects, where each LayerInfo object corresponds
      // to the average performance counts for a particular node in the model.
      std::unordered_map<std::string, std::vector<RuntimeAnalyzer::LayerInfo>> layerInfoMap;

      // A vector (one for each compiled model) of vectors of LayerInfo objects (one per layer).
      for (size_t model_id = 0; model_id < compiled_models.size(); model_id++) {
        std::vector<std::vector<RuntimeAnalyzer::LayerInfo>> modelPerfCounts;
        for (size_t req_id = 0; req_id < nireq; req_id++) {
          modelPerfCounts.push_back(infer_request_queues[model_id]->get_average_performance_counts(req_id));
        }

        std::vector<RuntimeAnalyzer::LayerInfo> modelAvgLayerInfo;

        for (const auto& reqPerfCounts : modelPerfCounts) {     // Iterate over each request object's performance counts
          for (const auto& perfCount : reqPerfCounts) {
            // Note: we assume that the performance counts have the same execution status.
            auto it = std::find_if(modelAvgLayerInfo.begin(), modelAvgLayerInfo.end(),
                                    [&perfCount](const RuntimeAnalyzer::LayerInfo& avgLayerInfo) {
                                    return avgLayerInfo.node_name == perfCount.node_name;
                                  });
            if (it != modelAvgLayerInfo.end()) {
              it->exec_time += perfCount.exec_time / static_cast<double>(nireq);
            } else {
              RuntimeAnalyzer::LayerInfo layerInfo{
                  .node_name = perfCount.node_name,
                  .layer_status = perfCount.layer_status,
                  .layer_type = perfCount.layer_type,
                  .exec_time = perfCount.exec_time / static_cast<double>(nireq),
                  .exec_type = perfCount.exec_type
              };
              modelAvgLayerInfo.push_back(layerInfo);
            }
          }
        }
        layerInfoMap[compiled_models[model_id]->get_property(ov::model_name)] = modelAvgLayerInfo;
      }

      SET_LAYER_MAP(layerInfoMap);

#endif

    std::cout << "count:             " << iteration << " iterations" << std::endl;
    std::cout << "system duration:   " << double_to_string(total_duration) << " ms" << std::endl;
    if (ip_duration != 0.0) {
      std::cout << "IP duration:       " << double_to_string(ip_duration) << " ms";
      if (fmax_core > 0.0) {
        uint64_t ip_cycles = static_cast<uint64_t>(ip_duration * fmax_core * 1000.0);
        std::cout << " (" << ip_cycles << " cycles @ " << double_to_string(fmax_core) << " MHz)";
      }
      std::cout << std::endl;
    }
    if (device_name.find("MULTI") == std::string::npos)
      std::cout << "latency:           " << double_to_string(latency) << " ms" << std::endl;
    std::cout << "system throughput: " << double_to_string(total_fps) << " FPS" << std::endl;
    if (ip_num_instances != 0) std::cout << "number of hardware instances: " << ip_num_instances << std::endl;
    if (compiled_models.size() != 0)
      std::cout << "number of network instances: " << compiled_models.size() << std::endl;
    if (ip_fps != 0.0) std::cout << "IP throughput per instance: " << double_to_string(ip_fps) << " FPS" << std::endl;
    if (ip_fps_per_fmax != 0.0)
      std::cout << "IP throughput per fmax per instance: " << double_to_string(ip_fps_per_fmax) << " FPS/MHz" << std::endl;
    if (fmax_core > 0.0)
      std::cout << "IP clock frequency measurement: " << double_to_string(fmax_core) << " MHz"
                << (FLAGS_ip_clock_override > 0.0 ? " (override)" : "") << std::endl;
    if (ddr_clock > 0.0)
      std::cout << "DDR clock frequency measurement: " << double_to_string(ddr_clock) << " MHz"
                << (FLAGS_ddr_clock_override > 0.0 ? " (override)" : "") << std::endl;
    for (size_t i = 0; i < estimated_ipFps.size(); i++) {
      // A negative throughput means the AOT model was compiled without --fanalyze-performance,
      // so DLACompiledModel::throughput_est_ kept its default value (-1.0). For a single FPGA
      // instance it yields exactly -1; with N instances it yields -1/N.
      if (estimated_ipFps[i] < 0.0) {
        std::cout << "estimated IP throughput per instance: N/A" << std::endl;
        std::cout << "estimated IP throughput per fmax per instance: N/A" << std::endl;
        continue;
      }
      std::cout << "estimated IP throughput per instance: " << double_to_string(estimated_ipFps[i])
                << " FPS (" << (int)estimated_ipFps_assumed_fmax << " MHz assumed)"
                << " [graph: " << topology_names[i] << "]" << std::endl;
      std::cout << "estimated IP throughput per fmax per instance: "
                << double_to_string(estimated_ipFpsPerFmax[i]) << " FPS/MHz"
                << " [graph: " << topology_names[i] << "]" << std::endl;
    }
    // ----------------- 12. Dumping output values -------------------------------------------------------------
    next_step();

#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
    nlohmann::ordered_json run_data;

    // IMPORTANT: these fields are expected to be present (by exact name matching) within the GUI
    // for some heuristics and visualizations. If these field keys are changed this must also be reflected on the GUI side in the JS data processing.
    run_data["numInferenceRequests"] = (FLAGS_nireq > 0 ? std::to_string(FLAGS_nireq) : "Not specified");
    if (ip_num_instances != 0)
      run_data["ipNumInstances"] = ip_num_instances;

    // Run settings information
    run_data["api (-api)"] = FLAGS_api;
    run_data["device (-d)"] = FLAGS_d;
    run_data["batch_size (-b)"] = batch_size_flag;
    run_data["compiled model (-cm)"] = (!FLAGS_cm.empty() ? FLAGS_cm : network_file_flag);
    run_data["num_compiled_models"] = compiled_models.size();
    run_data["num_iterations (-niter)"] = (FLAGS_niter > 0 ? std::to_string(FLAGS_niter) : "Not specified");
    run_data["num_inferences"] = num_batches;
    run_data["input_images_directory (-i)"] = (!FLAGS_i.empty() ? FLAGS_i : "Not specified, will use randomly-generated images");
    run_data["num_cpu_threads (-nthreads)"] = (FLAGS_nthreads > 0 ? std::to_string(FLAGS_nthreads) : "Not specified");
    run_data["architecture_file (-arch)"] = arch_file_flag;
    run_data["plugins_file (-plugins)"] = FLAGS_plugins;
    run_data["groundtruth_file (-groundtruth)"] = (!FLAGS_groundtruth_loc.empty() ? FLAGS_groundtruth_loc : "Not specified");
    run_data["reverse_input_channels (-bgr)"] = (FLAGS_bgr ? "True" : "False");

    // Performance information
    run_data["Successfully enqueued infer requests"] = std::to_string(iteration) + " iterations";
    run_data["System duration"] = double_to_string(total_duration) + " ms";
    run_data["IP duration"] = double_to_string(ip_duration) + " ms";
    run_data["Latency"] = double_to_string(latency) + " ms";
    run_data["System throughput"] = double_to_string(total_fps) + " FPS";
    if (ip_fps != 0.0)
      run_data["IP throughput per instance"] = double_to_string(ip_fps) + " FPS";
    if (ip_fps_per_fmax != 0.0)
      run_data["IP throughput per fmax per instance"] = double_to_string(ip_fps_per_fmax) + " FPS/MHz";
    if (fmax_core > 0.0)
      run_data["IP clock frequency measurement"] =
          double_to_string(fmax_core) + " MHz" + (FLAGS_ip_clock_override > 0.0 ? " (override)" : "");
    if (ddr_clock > 0.0)
      run_data["DDR clock frequency measurement"] =
          double_to_string(ddr_clock) + " MHz" + (FLAGS_ddr_clock_override > 0.0 ? " (override)" : "");

    std::string run_data_json = run_data.dump(2);

    SET_RUN_DATA(run_data_json);

    HW_PPN_DUMP(base_output_dir);
    DUMP_TRACE_DATA_JSON(base_output_dir, FLAGS_perf_profiler_trace_name);
#endif

    // Write network directories file
    if (!network_directory_names.empty()) {
      std::string output_file = base_output_dir + "network_directories.txt";
      std::ofstream out_file(output_file);

      if (out_file.is_open()) {
        for (const auto& network_name : network_directory_names) {
          out_file << network_name << std::endl;
        }
        out_file.close();
        std::cout << "Network directories list written to: " << output_file << std::endl;
      } else {
        std::cerr << "Warning: Failed to create network_directories.txt file: " << output_file << std::endl;
      }
    }

    if (FLAGS_dump_output) {
      for (size_t i = 0; i < compiled_models.size(); i++) {
        std::vector<ov::Output<const ov::Node>> output_info = compiled_models[i]->outputs();
        // For multi-outputs: Sort to ensure the order of each tensor dump aligns with the ground truth files
        std::sort(output_info.begin(), output_info.end(), CompareOutputNodeNames);
        const auto& output_tensors_map = output_tensors[i];
        // A flag regarding whether we can dump output tensor in a text file due to unsupported layout.
        // This flag is set at first during dumping.
        bool can_dump_txt = true;
        bool can_dump_layout_info_in_txt = true;

        std::string export_dir = base_output_dir + network_directory_names[i] + separator;
        if (has_fpga) {
          export_dir = compiled_models[i]->get_property(DLIAPlugin::properties::export_dir.name()).as<std::string>();
        }

        // dump output tensor as bin, which can be loaded using Python Numpy
        std::regex pattern("\\{batch\\}");
        std::string results_bin_file_name = export_dir + "result_{batch}.bin";
        // dump output tensor as text
        std::string results_txt_file_name = export_dir + "result.txt";
        std::string results_boundaries_file_name = export_dir + "result_tensor_boundaries.txt";
        // dump inference arguments and metadata as JSON
        std::string results_meta_file_name = export_dir + "result_meta.json";

        slog::info << "Dumping result of " << topology_names[i]
                   << " to " << results_txt_file_name << slog::endl;
        slog::info << "Dumping per-batch result (raw output) of " << topology_names[i]
                   << " to " << results_bin_file_name << slog::endl;
        slog::info << "Dumping inference meta data of " << topology_names[i]
                   << " to " << results_meta_file_name << slog::endl;

        std::ofstream result_txt_file(results_txt_file_name);
        std::ofstream results_boundaries(results_boundaries_file_name);
        std::ofstream result_meta_file(results_meta_file_name);

        dla_benchmark::InferenceMetaData result_metadata;
        // Handle the case that use same inputs for all networks
        const auto& inputFiles =
          i >= multi_input_files.size() ? multi_input_files.back() : multi_input_files[i];
        result_metadata.input_files = inputFiles;  // all input files in -i
        result_metadata.groundtruth_loc = FLAGS_groundtruth_loc;
        result_metadata.batch_size = FLAGS_batch_size;
        result_metadata.niter = niter;
        result_metadata.nireq = nireq;
        result_metadata.model_input_info = input_infos[i];
        dla_benchmark::OutputsInfoVec model_output_info;

        uint32_t current_lines = 1;
        size_t max_allowed_megabytes_to_dump = FLAGS_max_output_file_size;

        for (uint32_t batch = 0; batch < num_batches; batch++) {
          std::string per_batch_results_bin_file_name = std::regex_replace(results_bin_file_name,
                                                                           pattern,
                                                                           std::to_string(batch));
          std::ofstream per_batch_results_bin_file(per_batch_results_bin_file_name, std::ios::binary);
          for (const auto& item : output_info) {
            auto tensor = output_tensors_map.at(item.get_any_name()).at(batch);
            unsigned int output_size = tensor.get_size() / batch_size;

            const ov::Layout& layout = ov::layout::get_layout(item);
            const auto& shape = tensor.get_shape();
            const std::string& name = item.get_any_name();
            size_t total_bytes_to_dump = tensor.get_size() * niter * sizeof(float);

            if (can_dump_txt) {
              // if we cannot dump as a text file, we set can_dump_txt flag to false and write the one-time message
              if (total_bytes_to_dump > max_allowed_megabytes_to_dump * BYTE_TO_MEGABYTE) {
                can_dump_txt = false;
                std::string msg = "Output tensor (" + std::to_string(total_bytes_to_dump / BYTE_TO_MEGABYTE) +
                                  " MB) "
                                  "is too large to dump. Change environmental variable MAX_DUMP_OUTPUT_TXT (default " +
                                  std::to_string(FLAGS_max_output_file_size) + " MB) to allow dumping larger tensors";
                slog::warn << msg << slog::endl;
                result_txt_file << msg;
              } else {
                if (can_dump_layout_info_in_txt && shape.size() != 2 && shape.size() != 4 && shape.size() != 5) {
                  can_dump_layout_info_in_txt = false;
                  slog::warn << "Output data tensor of rank that is not 2, 4 or 5. layout info will not be dumped in "
                             << "result.txt." << slog::endl;
                }
                // Otherwise, dump text and write to the result_tensor_boundaries.txt with additional information
                // about the result.txt file
                results_boundaries << name << ": Line " << current_lines << " to "
                                   << "line " << current_lines + output_size - 1 << std::endl;
                results_boundaries << name << " output layout: " << layout.to_string() << std::endl;
                results_boundaries << name << " output dimension:";
                for (unsigned int dim = 0; dim < shape.size(); dim++) {
                  results_boundaries << " " << shape[dim];
                }
                results_boundaries << std::endl;
                current_lines = current_lines + output_size;
                DumpResultTxtFile(tensor, item, output_size, result_txt_file);
              }
            }
            DumpResultBinFile(tensor, per_batch_results_bin_file);

            if (batch == 0) {
              // all batches should have the same output info
              dla_benchmark::OutputInfo output_info;
              output_info.name = name;
              output_info.shape = shape;
              model_output_info.push_back(output_info);
            }
          }
          per_batch_results_bin_file.close();
        }

        result_metadata.model_output_info = model_output_info;
        DumpResultMetaJSONFile(result_metadata, result_meta_file);
        result_txt_file.close();
        results_boundaries.close();
        result_meta_file.close();
      }
      const std::string throughput_file_name = base_output_dir + "throughput_report.txt";
      std::ofstream throughput_file;
      throughput_file.open(throughput_file_name);
      throughput_file << "Throughput : " << total_fps << " fps" << std::endl;
      throughput_file << "Batch Size : " << batch_size << std::endl;
      throughput_file << "Graph number : " << compiled_models.size() << std::endl;
      throughput_file << "Num Batches : " << num_batches << std::endl;
      throughput_file.close();

      // Append throughput to dataset
      // Check both gz and non gz versions
      std::string dataset_gz_file_name = "data.csv.gz";
      append_value_if_incomplete_to_csv(dataset_gz_file_name, ip_fps);
      std::string dataset_file_name = "data.csv";
      append_value_if_incomplete_to_csv(dataset_file_name, ip_fps);
    }

    // Calculate top 1, top 5 results
    if (FLAGS_groundtruth_loc != "") {
      auto groundtruth_files = split(FLAGS_groundtruth_loc, MULTIGRAPH_SEP);
      for (size_t i = 0; i < compiled_models.size(); i++) {
        // This flag `FLAGS_enable_object_detection_ap` enables accuracy checking subroutine that
        // gives the mAP and COCO AP scores. These scores are two of the main detection evaluation
        // metrics used in the Common Objects in Context contest, https://cocodataset.org/#detection-eval.

        std::vector<ov::Output<const ov::Node>> output_info = compiled_models[i]->outputs();
        // For multi-outputs: Sort to ensure the order of each tensor dump aligns with the ground truth files
        std::sort(output_info.begin(), output_info.end(), CompareOutputNodeNames);

        std::string export_dir = base_output_dir;
        if (has_fpga) {
          export_dir = compiled_models[i]->get_property(DLIAPlugin::properties::export_dir.name()).as<std::string>();
        }
        // Run the default top-1, top-5 evaluation routine if AP scores are not required.
        if (!FLAGS_enable_object_detection_ap) {
          if (groundtruth_files.size() <= i) {
            slog::warn << "Missing ground truth file for " << topology_names[i] << "! SKIPPED" << slog::endl;
            continue;  // Print warnings for all missing ground truth graphs;
          }
          slog::info << "Comparing ground truth file " << groundtruth_files[i] << " with network " << topology_names[i]
                     << slog::endl;
          // captures the results in higher precision for accuracy analysis
          std::vector<float> results;
          const auto& output_tensors_map = output_tensors[i];
          for (uint32_t batch = 0; batch < num_batches; batch++) {
            for (unsigned int img = 0; img < batch_size; img++) {
              for (const auto& item : output_info) {
                auto tensor = output_tensors_map.at(item.get_any_name()).at(batch);
                auto tensor_data = tensor.data<float>();
                unsigned int output_size = tensor.get_size() / batch_size;
                size_t offset = img * output_size;
                for (unsigned int j = 0; j < output_size; j++) {
                  results.push_back(tensor_data[j + offset]);
                }
              }
            }
          }
          bool passed = TopResultsAnalyser::get_top_results(groundtruth_files[i], results, batch_size * num_batches, export_dir);
          if (passed) {
            slog::info << "Get top results for \"" << topology_names[i] << "\" graph passed" << slog::endl;
          } else {
            // return 4 indicates that the accuracy of the result was below the threshold
            return_code = 4;
          }
        } else {
          const auto& inputFiles =
            i >= multi_input_files.size() ? multi_input_files.back() : multi_input_files[i];
          // Runs the accuracy checking routine if AP scores are required.
          set_runtime(FLAGS_yolo_version, FLAGS_niter, batch_size_flag, FLAGS_i, FLAGS_groundtruth_loc, resize_type_enum);
          std::pair<double, double> res =
              validate_yolo_wrapper(output_tensors[i], output_info, inputFiles, export_dir);
          std::cout << std::endl;
          slog::info << "Batch metrics results:" << slog::endl;
          std::cout << "Detection - mAP@0.5: " << std::setprecision(6) << res.first * 100 << "%" << std::endl;
          std::cout << "Detection - mAP@0.5:0.95: " << std::setprecision(6) << res.second * 100 << "%" << std::endl;
          double epsilon = 1e-9;
          if (FLAGS_yolo_version == "yolo-v8" && (res.first < epsilon || res.second < epsilon)) {
            slog::warn << "Did you remember to set -scale_values=[255,255,255] to normalize the input images for YOLOv8?" << slog::endl;
          }
        }
      }
    }
    // Output Debug Network Info if COREDLA_TEST_DEBUG_NETWORK is set
    if (has_fpga) {
      ReadDebugNetworkInfo(core);
      if (FLAGS_report_lsu_counters) {
        PrintLSUCounterInfo(core);
      }
    }
    if (return_code) return static_cast<int>(return_code);
  } catch (const dla::error& ex) {
    slog::err << ex.user_message() << slog::endl;
    if (statistics) {
      statistics->addParameters(StatisticsReport::Category::EXECUTION_RESULTS,
                                {{"Error during dla_benchmark", ex.user_message()}});
      statistics->dump();
    }
    return 3;
  } catch (const std::exception& ex) {
    slog::err << dla::user_facing_message(ex) << slog::endl;
    if (statistics) {
      statistics->addParameters(StatisticsReport::Category::EXECUTION_RESULTS,
                                {{"Error during dla_benchmark", dla::user_facing_message(ex)}});
      statistics->dump();
    }
    return 3;
  }

  return 0;
  // Bypass long function lint check
  // NOLINTNEXTLINE(readability/fn_size)
}
