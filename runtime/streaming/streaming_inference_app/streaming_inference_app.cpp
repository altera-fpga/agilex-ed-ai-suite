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

#include "streaming_inference_app.h"
#include <fcntl.h>
#include <signal.h>
#include <sys/utsname.h>
#include <unistd.h>
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <mutex>
#include "dla_error_log.h"
#include "dla_plugin_config.hpp"

using namespace std::chrono_literals;

std::ofstream StreamingInferenceApp::_resultsStream("results.txt");
std::mutex StreamingInferenceApp::_signalMutex;
std::condition_variable StreamingInferenceApp::_signalConditionVariable;
std::chrono::time_point<std::chrono::system_clock> StreamingInferenceApp::_startTime;

int main(int numParams, char* paramValues[]) {
  StreamingInferenceApp app(numParams, paramValues);

  try {
    app.Run();
  } catch (const std::exception& ex) {
    std::cerr << dla::user_facing_message(ex) << '\n';
  }
  return 0;
}

StreamingInferenceApp::StreamingInferenceApp(int numParams, char* paramValues[])
    : _commandLine(numParams, paramValues) {
  OsStartup();
  LoadClassNames();
}

StreamingInferenceApp::~StreamingInferenceApp() {
  timespec waitTimeout = {};
  if (_pCancelSemaphore) {
    // Reset the cancel semaphore
    int r = 0;
    do {
      r = ::sem_timedwait(_pCancelSemaphore, &waitTimeout);
    } while (r == 0);
    ::sem_close(_pCancelSemaphore);
  }

  if (_pReadyForImageStreamSemaphore) {
    // Reset the ready semaphore
    int r = 0;
    do {
      r = ::sem_timedwait(_pReadyForImageStreamSemaphore, &waitTimeout);
    } while (r == 0);
    ::sem_close(_pReadyForImageStreamSemaphore);
  }
}

void StreamingInferenceApp::Run() {
  std::filesystem::path pluginsFilename = "plugins.xml";

  std::string deviceName;
  std::string arch;
  std::string model;

  // Get the command line options for the model, arch file, and device
  if (not _commandLine.GetOption("model", model) or not _commandLine.GetOption("arch", arch) or
      not _commandLine.GetOption("device", deviceName)) {
    return Usage();
  }

  std::filesystem::path architectureFilename = arch;
  std::filesystem::path compiledModelFilename = model;

  // Check that the provided files do in fact exist
  if (not CheckFileExists(architectureFilename, "architecture") or not CheckFileExists(pluginsFilename, "plugins") or
      not CheckFileExists(compiledModelFilename, "compiled model")) {
    return;
  }

  ov::Core inferenceEngine(pluginsFilename);

  // Setup CoreDLA private configuration parameters
  const std::map<std::string, std::string> configParameters;
  inferenceEngine.set_property("FPGA", {{DLIAPlugin::properties::arch_path.name(), architectureFilename}});

  // If dropSourceBuffers is 0, no input buffers are dropped
  // If dropSourceBuffers is 1, then 1 buffer is processed, 1 gets dropped
  // If dropSourceBuffers is 2, then 1 buffer is processed, 2 get dropped, etc.
  uint32_t dropSourceBuffers = 0;

  inferenceEngine.set_property("FPGA", {{DLIAPlugin::properties::streaming_drop_source_buffers.name(), std::to_string(dropSourceBuffers)},
                                        {DLIAPlugin::properties::external_streaming.name(), true}});

  std::ifstream inputFile(compiledModelFilename, std::fstream::binary);
  if (not inputFile) {
    std::cout << "Failed to load compiled model file.\n";
    return;
  }

  std::string compiledModelDevice = "";
  char c;
  while(inputFile.get(c) && c != '\0') {
    compiledModelDevice += c;
  }
  if (compiledModelDevice != deviceName) {
    std::cerr << "The compiled model may not be compatible with the specified device.\n";
    std::cerr << "Compiled model device: " << compiledModelDevice << "\n";
    std::cerr << "Specified device: " << deviceName << "\n";
  }
  std::string rest_of_data(
    (std::istreambuf_iterator<char>(inputFile)),
    std::istreambuf_iterator<char>());
  inputFile.close();
  std::istringstream rest_of_data_stream(rest_of_data);

  // Load the model to the device
  ov::CompiledModel importedNetwork = inferenceEngine.import_model(rest_of_data_stream, deviceName, {});

  // The plugin defines the number of inferences requests required for streaming
  uint32_t numStreamingInferenceRequests = importedNetwork.get_property(DLIAPlugin::properties::num_streaming_inference_requests.name()).as<uint32_t>();
  const std::string cancelSemaphoreName = importedNetwork.get_property(DLIAPlugin::properties::cancel_semaphore_name.name()).as<std::string>();
  _cancelSemaphoreName = cancelSemaphoreName;

  for (uint32_t i = 0; i < numStreamingInferenceRequests; i++) {
    auto spInferenceData = std::make_shared<SingleInferenceData>(this, importedNetwork, i);
    _inferences.push_back(spInferenceData);
  }

  // Start the inference requests. Streaming inferences will reschedule
  // themselves when complete
  for (auto& inference : _inferences) {
    inference->StartAsync();
  }

  std::cout << "Ready to start image input stream.\n";

  // Signal the image streaming app that we are ready, so it can
  // begin transferring files
  SetReadyForImageStreamSemaphore();

  // Wait until Ctrl+C
  bool done = false;
  while (not done) {
    std::unique_lock<std::mutex> lock(_signalMutex);
    done = (_signalConditionVariable.wait_for(lock, 1000ms) != std::cv_status::timeout);
  }

  SetShutdownSemaphore();

  for (auto& inference : _inferences) {
    inference->Cancel();
  }

  _inferences.clear();
}


void StreamingInferenceApp::SetShutdownSemaphore() {
  _pCancelSemaphore = ::sem_open(_cancelSemaphoreName.c_str(), O_CREAT, 0644, 0);
  if (_pCancelSemaphore) {
    ::sem_post(_pCancelSemaphore);
  }
}


void StreamingInferenceApp::SetReadyForImageStreamSemaphore() {
  _pReadyForImageStreamSemaphore = ::sem_open("/CoreDLA_ready_for_streaming", O_CREAT, 0644, 0);
  if (_pReadyForImageStreamSemaphore) {
    ::sem_post(_pReadyForImageStreamSemaphore);
  }
}


/**
 * Print a help menu to the console
 */
void StreamingInferenceApp::Usage() {
  std::cout << "Usage:\n";
  std::cout << "\tstreaming_inference_app -model=<model> -arch=<arch> -device=<device>\n\n";
  std::cout << "Where:\n";
  std::cout << "\t<model>    is the compiled model binary file, eg /home/root/resnet-50-tf/RN50_Performance_no_folding.bin\n";
  std::cout << "\t<arch>     is the architecture file, eg /home/root/resnet-50-tf/A10_Performance.arch\n";
  std::cout << "\t<device>   is the OpenVINO device ID, eg HETERO:FPGA or HETERO:FPGA,CPU\n";
}


/**
 * Check that a file exists
 *
 * @param[in]  filename Filename to check
 * @param[in]  message  Description of file to display if it does not exist
 * @returns             true if the file exists, false otherwise
 */
bool StreamingInferenceApp::CheckFileExists(const std::filesystem::path& filename, const std::string& message) {
  if (not std::filesystem::exists(filename)) {
    std::cout << "Can't find " << message << ", '" << filename.c_str() << "'\n";
    return false;
  }

  return true;
}

////////////

std::atomic<uint32_t> SingleInferenceData::_atomic{0};
uint32_t SingleInferenceData::_numResults = 0;

SingleInferenceData::SingleInferenceData(StreamingInferenceApp* pApp,
                                         ov::CompiledModel& importedNetwork,
                                         uint32_t index)
    : _pApp(pApp), _importedNetwork(importedNetwork), _index(index), _inferenceCount(0) {
  // Set up output tensor
  const std::vector<ov::Output<const ov::Node>>& outputsInfo = importedNetwork.outputs();
  const ov::Output<const ov::Node> spOutputInfo = outputsInfo[0];
  std::string outputName = spOutputInfo.get_node()->get_friendly_name();

  _spOutputTensor = CreateOutputTensor(spOutputInfo);

  // Create an inference request and set its completion callback
  _inferenceRequest = importedNetwork.create_infer_request();
  std::function<void(std::exception_ptr)> inferenceRequestCompleteCB = [=](std::exception_ptr) { ProcessResult(); };
  _inferenceRequest.set_callback(inferenceRequestCompleteCB);

  // Assign the output blob to the inference request
  _inferenceRequest.set_tensor(outputsInfo[0], *_spOutputTensor);
}


std::shared_ptr<ov::Tensor> SingleInferenceData::CreateOutputTensor(
  const ov::Output<const ov::Node> spOutputInfo) {
  std::shared_ptr<ov::Tensor> pOutputTensor = std::make_shared<ov::Tensor>(spOutputInfo);

  float* pOutputTensorData = pOutputTensor->data<float>();
  if (pOutputTensorData) {
      size_t outputSize = pOutputTensor->get_size();
      for (size_t i = 0; i < outputSize; i++) {
          pOutputTensorData[i] = 0.0f;
      }
  }

  return pOutputTensor;
}


void SingleInferenceData::StartAsync() {
  _inferenceCount = _atomic++;
  _inferenceRequest.start_async();
}

void SingleInferenceData::Wait() { _inferenceRequest.wait(); }

void SingleInferenceData::Cancel() { _inferenceRequest.cancel(); }


/**
 * Stores the results of an inference
 *
 * The index corresponds to the category of the image, and the score is
 * the confidence level of the image.
 */
class ResultItem {
 public:
  uint32_t _index;
  float _score;
  bool operator<(const ResultItem& other) { return (_score > other._score); }
};


/**
 * Called when inference request has completed
 *
 * The inference results are floating point numbers consisting of the score for each category.
 * The scores are then sorted and the highest is written to the console. The top 5 scores of the
 * first 1000 images are saved to results.txt.
 *
 * Set as a callback in SingleInferenceData()
 */
void SingleInferenceData::ProcessResult() {
  if (_pApp and _pApp->IsCancelling()) {
    return;
  }

  // Increment the number of inference results that have returned thus far
  _numResults++;

  // If this is the first returned inference, store the current time to calculate the inference rate
  if (_numResults == 1) {
    StreamingInferenceApp::_startTime = std::chrono::system_clock::now();
  } else if (_numResults == 101) {
    // The inference rate is calculated afer 100 results have been received
    auto endTime = std::chrono::system_clock::now();
    auto duration = endTime - StreamingInferenceApp::_startTime;
    double durationMS = (double)std::chrono::duration_cast<std::chrono::milliseconds>(duration).count();
    double durationSecondsOne = durationMS / 100000.0;
    double rate = 1.0 / durationSecondsOne;
    std::cout << "Inference rate = " << rate << '\n';
  }

  // Create a float pointer to the returned data
  size_t outputSize = _spOutputTensor->get_size();
  float* pOutputData = _spOutputTensor->data<float>();
  if (!pOutputData) {
    return;
  }

  // Store each score as a ResultItem
  std::vector<ResultItem> results;
  for (size_t i = 0; i < outputSize; i++) {
    results.push_back({(uint32_t)i, pOutputData[i]});
  }

  // Sort the scores and set up the output streams
  std::sort(results.begin(), results.end());
  std::stringstream fileString;
  std::stringstream outString;
  bool flushFile = false;

  // Store the top 5 results of the first 1000 images to be written to a file
  if (_numResults <= 1000) {
    fileString << "Result: image[" << _numResults << "]\n";
    fileString << std::fixed << std::setprecision(1);

    for (size_t i = 0; i < 5; i++) {
      std::string className = _pApp->_imageNetClasses[results[i]._index];
      float score = results[i]._score * 100.0f;
      fileString << (i + 1) << ". " << className << ", score = " << score << '\n';
    }

    fileString << '\n';
  }

  if (_numResults == 1001) {
    fileString << "End of results capture\n";
    flushFile = true;
  }

  // Store the top score to write to the console
  outString << std::fixed << std::setprecision(1);
  std::string className = _pApp->_imageNetClasses[results[0]._index];
  float score = results[0]._score * 100.0f;
  outString << _numResults << " - " << className << ", score = " << score << '\n';

  // Write the results to the file
  std::string writeFileString = fileString.str();
  if (not writeFileString.empty()) {
    StreamingInferenceApp::_resultsStream << writeFileString;
    if (flushFile) {
      StreamingInferenceApp::_resultsStream << std::endl;
    }
  }

  // Write the top score to the console
  std::cout << outString.str();

  // Start again
  StartAsync();
}


/**
 * Load the categories and store them in _imageNetClasses
 */
void StreamingInferenceApp::LoadClassNames() {
  _imageNetClasses.resize(1001);

  bool validClassFile = false;
  std::filesystem::path classNameFilePath = "categories.txt";

  if (std::filesystem::exists(classNameFilePath)) {
    size_t classIndex = 0;
    std::ifstream classNameStream(classNameFilePath);

    if (classNameStream) {
      std::string className;
      while (std::getline(classNameStream, className)) {
        if (classIndex < 1001) _imageNetClasses[classIndex] = className;

        classIndex++;
      }

      validClassFile = (classIndex == 1001);
      if (not validClassFile) {
        std::cout << "Ignoring the categories.txt file. The file is expected to be a text file "
                     "with 1000 lines.\n";
      }
    }
  } else {
    std::cout << "No categories.txt file found. This file should contain 1000\n"
                 "lines, with the name of each category on each line.\n";
  }

  if (not validClassFile) {
    _imageNetClasses[0] = "NONE";
    for (size_t i = 1; i <= 1000; i++) {
      _imageNetClasses[i] = "Image class #" + std::to_string(i);
    }
  }
}

static void SigIntHandler(int) {
  std::cout << "\nCtrl+C detected. Shutting down application\n";
  std::lock_guard<std::mutex> lock(StreamingInferenceApp::_signalMutex);
  StreamingInferenceApp::_signalConditionVariable.notify_one();
}

void StreamingInferenceApp::OsStartup() {
  // Ctrl+C will exit the application
  signal(SIGINT, SigIntHandler);
}
