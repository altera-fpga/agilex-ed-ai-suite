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
#include <semaphore.h>
#include <atomic>
#include <condition_variable>
#include <filesystem>
#include "command_line.h"
#include "openvino/runtime/core.hpp"

class SingleInferenceData;
using SingleInferenceDataPtr = std::shared_ptr<SingleInferenceData>;

class StreamingInferenceApp {
  friend class SingleInferenceData;

 public:
  StreamingInferenceApp(int numParams, char* paramValues[]);
  ~StreamingInferenceApp();
  void Usage();
  void Run();
  bool IsCancelling() { return (_pCancelSemaphore != nullptr); }

  static std::mutex _signalMutex;
  static std::condition_variable _signalConditionVariable;
  static std::chrono::time_point<std::chrono::system_clock> _startTime;
  static std::ofstream _resultsStream;

 private:
  void OsStartup();
  bool CheckFileExists(const std::filesystem::path& filename, const std::string& message);
  void SetShutdownSemaphore();
  void SetReadyForImageStreamSemaphore();
  void LoadClassNames();

  std::vector<SingleInferenceDataPtr> _inferences;
  CommandLine _commandLine;
  sem_t* _pCancelSemaphore = nullptr;
  sem_t* _pReadyForImageStreamSemaphore = nullptr;
  std::string _cancelSemaphoreName;
  std::vector<std::string> _imageNetClasses;
};

class SingleInferenceData {
 public:
  SingleInferenceData(StreamingInferenceApp* pApp, ov::CompiledModel& importedNetwork, uint32_t index);
  void StartAsync();
  void Wait();
  void Cancel();

 private:
  void ProcessResult();
  std::shared_ptr<ov::Tensor> CreateOutputTensor(const ov::Output<const ov::Node> spOutputInfo);

  StreamingInferenceApp* _pApp;
  ov::CompiledModel& _importedNetwork;
  std::shared_ptr<ov::Tensor> _spOutputTensor;
  ov::InferRequest _inferenceRequest;
  uint32_t _index;
  uint32_t _inferenceCount;
  static uint32_t _numResults;
  static std::atomic<uint32_t> _atomic;
};
