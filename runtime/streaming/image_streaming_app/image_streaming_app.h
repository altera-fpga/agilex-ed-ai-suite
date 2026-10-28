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
#include <condition_variable>
#include <filesystem>
#include <vector>
#include <semaphore.h>
#include "ILayoutTransform.h"
#include "command_line.h"

using namespace std::chrono_literals;

class RawImage;

class Event {
 public:
  void Wait() {
    std::unique_lock<std::mutex> lock(_signalMutex);
    _conditionVariable.wait(lock);
  }

  void Set() {
    std::lock_guard<std::mutex> lock(_signalMutex);
    _conditionVariable.notify_all();
  }

  bool IsSignalled() {
    std::unique_lock<std::mutex> lock(_signalMutex);
    return (_conditionVariable.wait_for(lock, 0ms) != std::cv_status::timeout);
  }

 private:
  std::mutex _signalMutex;
  std::condition_variable _conditionVariable;
};

class ImageStreamingApp {
 public:
  ImageStreamingApp(int numParams, char* paramValues[]);
  void Run();

 private:
  bool ProgramLayoutTransform();
  bool SendNextImage();
  bool LoadImageFiles(bool dumpLayoutTransform);
  void RunSendImageSignalThread();
  static void SigIntHandler(int);
  uint32_t GetUintOption(const char* optionName, uint32_t defaultValue);
  float GetFloatOption(const char* optionName, float defaultValue);
  bool OpenMsgDmaStream();
  void CloseMsgDmaStream();
  bool WaitForInferenceApp();

  CommandLine _commandLine;
  std::filesystem::path _imageFilesFolder;
  std::string _imageFile;
  std::vector<std::shared_ptr<RawImage>> _images;
  Event _sendNextImageEvent;
  static volatile bool _shutdownEvent;
  size_t _nextImageIndex = 0;
  uint32_t _numToSend = 0;
  uint32_t _sendRate = 30;
  uint32_t _sentCount = 0;
  bool _dumpTransformedImages = false;
  bool _runLayoutTransform = false;
  bool _disableExternalLT = false;
  FILE* _msgDmaStream = nullptr;
  ILayoutTransform::Configuration _ltConfiguration = {};
};
