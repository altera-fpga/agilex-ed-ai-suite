// Copyright 2022-2023 Altera Corporation.
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

#include <stdio.h>
#include <sys/stat.h>
#include <algorithm>
#include <map>
#include <memory>
#include <string>
#include <utility>
#include <vector>
#if defined(_WIN32) || defined(_WIN64)
#else
#include <dirent.h>
#include <unistd.h>
#endif

#include <openvino/openvino.hpp>
#include "samples/args_helper.hpp"
#include "samples/slog.hpp"

// #include "average_precision.hpp"
#include "dla_aot_splitter.hpp"
// #include "infer_request_wrap.hpp"
#include "dla_exception.h"
#include "dla_error_log.h"
#include "dla_plugin_config.hpp"
#include "inputs_filling.hpp"
#include "utils.hpp"

using DebugNetworkData = std::map<std::string, uint64_t>;

bool exists_test(const std::string& name) {
  struct stat buffer;
  return (stat(name.c_str(), &buffer) == 0);
}

// This function appears in dla_benchmark/main.cpp too.
bool dir_open_test(const std::string& name) {
#if (!defined(_WIN32) && !defined(_WIN64))
  // If we can open the directory then return true
  DIR* dp = opendir(name.c_str());
  if (dp != nullptr) {
    closedir(dp);
    return true;
  }
#endif  // !_WIN32 && !_WIN64
  struct stat sb;
  if (stat(name.c_str(), &sb) == 0) {
    if ((sb.st_mode & S_IFMT) != S_IFREG) {
      slog::err << "File " << name << " cannot be opened!" << slog::endl;
      throw std::logic_error("File cannot be opened!");
    }
  }
  return true;
}

// copy arguments into a new array to split the '-i=<arg>' into
// two arguments (i.e. '-i' and '<arg>') to overcome a bug
// parseInputFilesArguments function where is doesn't recognize
// the -i=<arg> format
void parseCommandLine(int argc, char** argv) {
  int num_args = argc;
  // allocated enough memory in case we needed to split the -i argument into two
  char** arguments = new char*[num_args + 1];
  for (int i = 0, j = 0; j < argc; ++i, ++j) {
    if (strstr(argv[j], "-i=")) {
      // number of arguments will increase by one after splitting
      num_args++;
      arguments[i] = new char[3];
      strcpy(arguments[i++], "-i");
      // copy the reset of the argument (i.e. post "-i=")
      arguments[i] = new char[strlen(argv[j]) - 2];
      strcpy(arguments[i], argv[j] + 3);
      continue;
    }
    arguments[i] = new char[strlen(argv[j]) + 1];
    strcpy(arguments[i], argv[j]);
  }
  // the parse function is modifying the arguments point so we need to keep
  // a copy of the original pointer value to delete it properly
  char** orig_arg_ptr = arguments;
  gflags::ParseCommandLineNonHelpFlags(&num_args, &arguments, true);
  // delete the allocated memory
  for (int i = 0; i < num_args; ++i) {
    delete[] orig_arg_ptr[i];
  }
  delete[] orig_arg_ptr;
}

bool ParseAndCheckCommandLine(int argc, char* argv[], size_t& netSize) {
  // ---------------------------Parsing and validating input arguments--------------------------------------
  slog::info << "Parsing input parameters" << slog::endl;

  // Check for any flags that are missing their preceding dashes
  // GFlags quietly ignores any flags missing their dashes, which can cause
  // aot_splitter to run with settings other than what the user intended

  // GFlags supports two different styles of flag:
  // 1. --<flag>
  // 2. -<flag>
  // It also supports two different ways of specifying values for flags which
  // take values:
  // 1. --<flag>=<value>
  // 2. --<flag> <value>

  // If we are not expecting a flag, we are expecting a value for the
  // preceding flag
  bool expectingFlag = true;
  // Start at 1 to skip the command itself
  for (int i = 1; i < argc; i++) {
    if (expectingFlag) {
      // A flag is always denoted by the first char being '-'
      if (argv[i][0] != '-') {
        slog::err << "Argument " << argv[i] << " is invalid. You"
                  << " may have forgotten a preceding '-'." << slog::endl;
        throw std::logic_error("One or more invalid arguments");
      }

      char* flagNameStart = (argv[i][1] == '-') ? &argv[i][2] : &argv[i][1];
      std::string flagName;

      gflags::CommandLineFlagInfo flagInfo;
      if (strstr(flagNameStart, "=")) {
        flagName = std::string(flagNameStart, size_t(strstr(flagNameStart, "=") - flagNameStart));
      } else {
        flagName = std::string(flagNameStart);
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
      // when we call parseCommandLine so we can assume here it's a bool.
      if (!GetCommandLineFlagInfo(flagName.c_str(), &flagInfo) || strstr(argv[i], "=") || flagInfo.type == "bool") {
        expectingFlag = true;
      } else {
        expectingFlag = false;
      }
    } else {
      // If we were expecting a value, doesn't matter what it is
      // gflags will check all values are the correct type, and
      // aot_splitter checks if the values received are sane
      expectingFlag = true;
    }
  }

  parseCommandLine(argc, argv);

  if (FLAGS_help || FLAGS_h) {
    showUsage();
    // CoreDLA: Version 2020.3 of OpenVINO assumes that the PAC board with OPAE on it
    // is an OpenCL/DLAv1 device.  Since it is not, it then errors-out when the device
    // does not response as expected to the OpenCL query.
    // showAvailableDevices();
    std::cout << "\n";
    return false;
  }

  if (FLAGS_cm.empty()) {
    throw std::logic_error("Model is required but not set. Please set -cm option.");
  } else {
    std::vector<std::string> m_paths = split(FLAGS_cm, MULTIGRAPH_SEP);
    netSize = m_paths.size();
    slog::info << "Found " << netSize << " compiled graph" << (netSize == 1 ? "" : "s") << slog::endl;
    for (auto& m_path : m_paths) {
      if (!exists_test(m_path)) {
        slog::err << "compiled model file: " << FLAGS_cm << " doesn't exist. Please provide a valid path with -cm."
                  << slog::endl;
        throw std::logic_error("Compiled model file path does not exist.");
      }
    }
  }

  if (!FLAGS_plugins.empty()) {
    slog::info << "Using custom plugins xml file - " << FLAGS_plugins << slog::endl;
  }

  if (FLAGS_plugins.empty()) {
    #ifdef DEFAULT_PLUGINS_PATH
    FLAGS_plugins = DEFAULT_PLUGINS_PATH;
    #else
    const char* coredla_work = std::getenv("COREDLA_WORK");
    const char* coredla_root = std::getenv("COREDLA_ROOT");
    if (coredla_work == nullptr) {
      if (coredla_root == nullptr) {
        slog::err << "ERROR: COREDLA_ROOT or CORDLA_WORK must be set to run without specifying --plugins." << slog::endl;
        throw std::logic_error("Please set up correct environment variables first");
      }
      std::string coredla_root_str = coredla_root;
      FLAGS_plugins = coredla_root_str + "/runtime/plugins.xml";
    } else {
      std::string coredla_work_str = coredla_work;
      FLAGS_plugins = coredla_work_str + "/runtime/plugins.xml";
    }
    #endif

    if (exists_test(FLAGS_plugins)) {
      slog::info << "Using default plugins xml file - " << FLAGS_plugins << slog::endl;
      return true;
    }
    slog::err << "No plugins xml file was provided and the default path: " << FLAGS_plugins << " doesn't exist." << slog::endl;
    throw std::logic_error("plugins_xml file path does not exist.");
  }

  if (!exists_test(FLAGS_plugins)) {
    slog::err << "Specified plugins xml file: " << FLAGS_plugins << " doesn't exist. Please provide a valid path." << slog::endl;
    throw std::logic_error("plugins_xml file path does not exist.");
  }

  return true;
}

static void next_step(const std::string additional_info = "") {
  static size_t step_id = 0;
  static const std::map<size_t, std::string> step_names = {
      {1, "Parsing and validating input arguments"},
      {2, "Loading Inference Engine"},
      {3, "Setting device configuration"},
      {4, "Reading the Intermediate Representation network"},
      {5, "Resizing network to match image sizes and given batch"},
      {6, "Configuring input of the model"},
      {7, "Loading the model to the device"},
      {8, "Setting optimal runtime parameters"},
      {9, "Creating infer requests and filling input blobs with images"},
      {10, "Measuring performance"},
      {11, "Dumping statistics report"},
      {12, "Dumping the output values"}};

  step_id++;
  if (step_names.count(step_id) == 0) {
    OPENVINO_THROW("Step ID ", step_id, " is out of total steps number ", step_names.size());
  }

  std::cout << "[Step " << step_id << "/" << step_names.size() << "] " << step_names.at(step_id)
            << (additional_info.empty() ? "" : " (" + additional_info + ")") << std::endl;
}

template <typename T>
T getMedianValue(const std::vector<T>& vec) {
  std::vector<T> sortedVec(vec);
  std::sort(sortedVec.begin(), sortedVec.end());
  return (sortedVec.size() % 2 != 0)
             ? sortedVec[sortedVec.size() / 2ULL]
             : (sortedVec[sortedVec.size() / 2ULL] + sortedVec[sortedVec.size() / 2ULL - 1ULL]) / static_cast<T>(2.0);
}

/**
 * @brief The entry point of the dla benchmark
 */
int main(int argc, char* argv[]) {
  try {
    // Declaring the ExecutableNetwork object as a pointer to workaround the segfault
    // that occurs when destructing the object. Now that it's declared as a pointer
    // the complier won't automatically call the destructor of the object at the end
    // of this scope and we won't delete the allocated memory either
    std::vector<ov::CompiledModel*> exeNetworks;
    size_t netSize = 0;  // parse the size of networks for arguments check

    size_t return_code = 0;  // universal return code, return this value after dumping out Debug info

    // ----------------- 1. Parsing and validating input arguments -------------------------------------------------
    next_step();

    if (!ParseAndCheckCommandLine(argc, argv, netSize)) {
      return 0;
    }

    bool isNetworkCompiled = !FLAGS_cm.empty();
    if (isNetworkCompiled) {
      slog::info << "Network is compiled" << slog::endl;
    }

    // The set of arguments printed is meant to be a useful summary to the
    // user, rather than all of the arguments to aot_splitter
    slog::info << "Printing summary of arguments being used by aot_splitter" << slog::endl
               << "Device (-d) .......................... "
               << "HETERO:FPGA" << slog::endl
               << "Compiled model (-cm) ................. " << FLAGS_cm << slog::endl
               << "Input images directory (-i) .......... "
               << (!FLAGS_i.empty() ? FLAGS_i : "Not specified, will use randomly-generated images") << slog::endl
               << "Plugins file (-plugins) ..... " << FLAGS_plugins << slog::endl
               << "Reverse input image channels (-bgr) .. " << (FLAGS_bgr ? "True" : "False") << slog::endl;

    /** This vector stores paths to the processed images **/
    auto multiInputFiles = VectorMap<std::vector<std::string>>(
        SplitMultiInputFilesArguments(netSize),  // get input directory list
        [&](const std::vector<std::string>& inputArgs) mutable {
          std::vector<std::string> files;
          for (auto& inputArg : inputArgs) {
            // Test if the path exists
            if (!exists_test(inputArg)) {
              slog::err << "Specified image path: " << inputArg << " does not exist" << slog::endl;
              throw std::logic_error("Image path does not exist");
            }
            // Test whether the path can be opened if it's a directory
            dir_open_test(inputArg);
            readInputFilesArguments(files, inputArg);
          }

          return files;
        });
    if (multiInputFiles.size() == 0) {
      // failed to read input files
      slog::err << "Failed to read input files" << slog::endl;
      return 1;
    }

    uint32_t num_batches = 1;

    // ----------------- 2. Loading the Inference Engine -----------------------------------------------------------
    next_step();

    // Get optimal runtime parameters for device
    std::string device_name = "HETERO:FPGA";
    ov::Core core(FLAGS_plugins);

    slog::info << "OpenVINO: " << ov::get_openvino_version() << slog::endl;

    // ----------------- 3. Setting device configuration -----------------------------------------------------------
    next_step();

    size_t batchSize = 1;
    std::vector<std::string> topology_names;
    if (!isNetworkCompiled) {
    } else {
      next_step();
      slog::info << "Skipping the step for compiled network" << slog::endl;
      next_step();
      slog::info << "Skipping the step for compiled network" << slog::endl;
      next_step();
      slog::info << "Skipping the step for compiled network" << slog::endl;
      // ----------------- 7. Loading the model to the device --------------------------------------------------------
      next_step();

      int folding_option = 1;
      bool fold_preprocessing = false;
      bool enable_early_access = false;
      if (FLAGS_folding_option) {
        folding_option = FLAGS_folding_option;
      }
      if (FLAGS_fold_preprocessing) {
        fold_preprocessing = FLAGS_fold_preprocessing;
      }
      if (FLAGS_enable_early_access) {
        enable_early_access = FLAGS_enable_early_access;
      }
      core.set_property("FPGA", {{DLIAPlugin::properties::folding_option.name(), std::to_string(folding_option)}});
      core.set_property("FPGA",
                        {{DLIAPlugin::properties::fold_preprocessing.name(), fold_preprocessing}});
      core.set_property("FPGA",
                        {{DLIAPlugin::properties::enable_early_access.name(), enable_early_access}});

      auto compiled_graph_paths = split(FLAGS_cm, MULTIGRAPH_SEP);
      exeNetworks = vectorMapWithIndex<ov::CompiledModel*>(
          split(FLAGS_cm, MULTIGRAPH_SEP),  // get a list of compiled graphs
          [&](const std::string& compiled_graph_path, size_t index) {
            std::stringstream generated_name;
            generated_name << "Graph_" << index;
            slog::info << "Importing model from " << compiled_graph_paths[index] << " to " << device_name << " as "
                       << generated_name.str() << slog::endl;
            std::filebuf objFileBuf;
            objFileBuf.open(compiled_graph_paths[index].c_str(), std::ios::in | std::ios::binary);
            std::istream objIstream(&objFileBuf);

            std::string compiled_model_device;
            {
              char c;
              while (objIstream.get(c) && c != '\0') {
                compiled_model_device += c;
              }
              if (compiled_model_device != device_name) {
                throw std::runtime_error("The compiled model is not for the " + device_name + " device. "
                                        "The compiled model is for the " + compiled_model_device + " device.");
              }
            }

            std::string rest_of_data(
              (std::istreambuf_iterator<char>(objIstream)),
              std::istreambuf_iterator<char>());
            objFileBuf.close();
            std::istringstream rest_of_data_stream(rest_of_data);

            auto exeNetwork = new ov::CompiledModel();
            *exeNetwork = core.import_model(rest_of_data_stream, device_name, {});
            topology_names.push_back(generated_name.str());
            printInputAndOutputsInfoShort(*exeNetwork);
            if (batchSize == 0) {
              batchSize = 1;
            }
            const auto& inputs = exeNetwork->inputs();
            for (const auto& item : inputs) {
              auto& dims = item.get_shape();
              if (dims[0] != batchSize) {
                slog::err << "Batch size of the compiled model is " << dims[0] << " and batch size provided is "
                          << batchSize << slog::endl;
                std::cout << "Set the same batch size = " << dims[0] << " when running the app" << std::endl;
                std::cout << "Or recompile model with batch size = " << batchSize << std::endl;
                exit(5);
              }
            }
            return exeNetwork;
          });
    }
    // ----------------- 8. Setting optimal runtime parameters -----------------------------------------------------
    next_step();

    // Number of requests
    uint32_t nireq = 1;
    if (nireq == 0) {
      nireq = 1;
    }
    int niter = 1;

    if (niter > 0) {
      num_batches = niter;
    }

    // ----------------- 9. Creating infer requests and filling input blobs ----------------------------------------
    next_step();
    std::vector<dla_benchmark::InputsInfo> inputInfos;
    // Data structure hierarchy
    // Outermost vec: which model it corresponds to (multigraph)
    // Map: input/output name and its corresponding TensorVector
    // TensorVector: An alias for vector<ov::tensor> where each vector element correspond to the batch
    std::vector<std::map<std::string, ov::TensorVector>> inputsData;
    std::vector<std::map<std::string, ov::TensorVector>> outputTensors(exeNetworks.size());

    std::vector<std::unique_ptr<InferRequestsQueue>> inferRequestsQueues;
    const std::string resize_type = FLAGS_resize_type.empty() ? "resize" : FLAGS_resize_type;
    FormatReader::Reader::ResizeType resize_type_enum =
    (resize_type == "resize")
        ? FormatReader::Reader::ResizeType::RESIZE
        : FormatReader::Reader::ResizeType::PAD_RESIZE;

    for (size_t netIdx = 0; netIdx < exeNetworks.size(); netIdx++) {
      // Handle the case that use same inputs for all networks
      const auto& inputFiles = netIdx >= multiInputFiles.size() ? multiInputFiles.back() : multiInputFiles[netIdx];
      inputInfos.push_back(GetInputsInfo(batchSize, exeNetworks[netIdx]->inputs(), FLAGS_bin_data));
      inputsData.push_back(GetStaticTensors(inputFiles.empty() ? std::vector<std::string>{} : inputFiles,
                                            batchSize,
                                            inputInfos[netIdx],
                                            num_batches,
                                            resize_type_enum,
                                            FLAGS_bgr,
                                            FLAGS_bin_data,
                                            false, /* Streaming is not supported for aot splitter */
                                            false /* verbose outputs not supported for aot splitter */));
      // Use unique_ptr to create InferRequestsQueue objects and avoid copying mutex and cv
      inferRequestsQueues.push_back(
          std::move(std::unique_ptr<InferRequestsQueue>(new InferRequestsQueue(*(exeNetworks[netIdx]), nireq))));
    }

    /** Start inference & calculate performance **/
    /** to align number if iterations to guarantee that last infer requests are executed in the same conditions **/
    std::vector<size_t> iterations(exeNetworks.size(), 0);

    try {
      {
        // set up all infer request and prep all i/o Blobs
        for (size_t net_id = 0; net_id < exeNetworks.size(); net_id++) {
          for (size_t iireq = 0; iireq < nireq; iireq++) {
            auto inferRequest = inferRequestsQueues.at(net_id)->get_idle_request();
            if (!inferRequest) {
              OPENVINO_THROW("No idle Infer Requests!");
            }

            if (niter != 0LL) {
              const auto& outputs = exeNetworks[net_id]->outputs();
              for (const auto& output : outputs) {
                const std::string& name = output.get_any_name();
                outputTensors.at(net_id)[name].emplace_back(output.get_element_type(), output.get_shape());
                inferRequest->set_tensor(name, outputTensors.at(net_id).at(name).at(iterations.at(net_id)));
              }
              const auto& inputs = exeNetworks[net_id]->inputs();
              for (auto& input : inputs) {
                const std::string& inputName = input.get_any_name();
                const auto& data = inputsData.at(net_id).at(inputName)[iterations.at(net_id)];
                inferRequest->set_tensor(inputName, data);
              }
            }

            {
              std::cout << "Generating Artifacts" << std::endl;
              inferRequest->infer();
            }
          }
        }
      }
    } catch (const dla::error& ex) {
      slog::err << ex.user_message() << slog::endl;
      slog::err << "Generation failed" << slog::endl;
      return_code = 1;
    } catch (const std::exception& ex) {
      slog::err << dla::user_facing_message(ex) << slog::endl;
      slog::err << "Generation failed" << slog::endl;
      return_code = 1;
    }

    if (return_code) return return_code;
  } catch (const dla::error& ex) {
    slog::err << ex.user_message() << slog::endl;
    return 3;
  } catch (const std::exception& ex) {
    slog::err << dla::user_facing_message(ex) << slog::endl;
    return 3;
  }

  return 0;
}
