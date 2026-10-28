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

#include "image_streaming_app.h"
#include <signal.h>
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>
#include <fcntl.h>
#include "raw_image.h"

int main(int numParams, char* paramValues[]) {
  ImageStreamingApp imageStreamingApp(numParams, paramValues);
  imageStreamingApp.Run();
  return 0;
}

volatile bool ImageStreamingApp::_shutdownEvent;

ImageStreamingApp::ImageStreamingApp(int numParams, char* paramValues[]) : _commandLine(numParams, paramValues) {
  std::string imagesFolder;
  if (_commandLine.GetOption("images_folder", imagesFolder))
    _imageFilesFolder = imagesFolder;
  else
    _imageFilesFolder = "./";

  std::string imageFile;
  if (_commandLine.GetOption("image", imageFile)) {
    _numToSend = 1;
    _imageFile = imageFile;
  }

  std::string nSendStr;
  if (_commandLine.GetOption("send", nSendStr)) _numToSend = std::strtoul(nSendStr.c_str(), 0, 0);

  std::string rateStr;
  if (_commandLine.GetOption("rate", rateStr)) _sendRate = std::strtoul(rateStr.c_str(), 0, 0);

  _dumpTransformedImages = _commandLine.HaveOption("dump");
  _disableExternalLT = _commandLine.HaveOption("skip_external_transform");

  _ltConfiguration._width = GetUintOption("width", 224);
  _ltConfiguration._height = GetUintOption("height", 224);
  _ltConfiguration._cVector = GetUintOption("c_vector", 32);
  _ltConfiguration._blueVariance = GetFloatOption("blue_variance", 1.0f);
  _ltConfiguration._greenVariance = GetFloatOption("green_variance", 1.0f);
  _ltConfiguration._redVariance = GetFloatOption("red_variance", 1.0f);
  _ltConfiguration._blueShift = GetFloatOption("blue_shift", -103.94f);
  _ltConfiguration._greenShift = GetFloatOption("green_shift", -116.78f);
  _ltConfiguration._redShift = GetFloatOption("red_shift", -123.68f);

  signal(SIGINT, SigIntHandler);
}

void ImageStreamingApp::Run() {
  if (_commandLine.HaveOption("-help")) {
    std::cout << "Usage:\n";
    std::cout << " image_streaming_app [Options]\n";
    std::cout << "\nOptions:\n";
    std::cout << "-images_folder=folder     Location of bitmap files. Defaults to working folder.\n";
    std::cout << "-image=path               Location of a single bitmap file for single inference.\n";
    std::cout << "-send=n                   Number of images to stream. Default is 1 if -image is set, otherwise infinite.\n";
    std::cout << "-rate=n                   Rate to stream images, in Hz. n is an integer. Default is 30.\n";
    std::cout << "-width=n                  Image width in pixels, default = 224\n";
    std::cout << "-height=n                 Image height in pixels, default = 224\n";
    std::cout << "-c_vector=n               C vector size, default = 32\n";
    std::cout << "-blue_variance=n          Blue variance, default = 1.0\n";
    std::cout << "-green_variance=n         Green variance, default = 1.0\n";
    std::cout << "-red_variance=n           Red variance, default = 1.0\n";
    std::cout << "-blue_shift=n             Blue shift, default = -103.94\n";
    std::cout << "-green_shift=n            Green shift, default -116.78\n";
    std::cout << "-red_shift=n              Red shift, default = -123.68\n";
    std::cout << "-skip_external_transform  Design uses CoreDLA's internal layout transform, so external transform should be skipped.\n";
    return;
  }

  if (not ProgramLayoutTransform()) {
    return;
  }

  if (not LoadImageFiles(_dumpTransformedImages)) {
    return;
  }

  if (_dumpTransformedImages) {
    return;
  }

  if (not WaitForInferenceApp())
    return;

  // Start event signal thread
  auto sendImageEventThreadCB = [this]() { RunSendImageSignalThread(); };
  std::thread sendImageEventThread(sendImageEventThreadCB);
  uint32_t sentCount = 0;

  while (not _shutdownEvent) {
    // Wait for the send image event
    _sendNextImageEvent.Wait();

    if (not SendNextImage()) {
      _shutdownEvent = true;
      break;
    }
    sentCount++;

    if ((_numToSend > 0) and (sentCount >= _numToSend)) {
      _shutdownEvent = true;
      break;
    }
  }

  // Wait for signalling thread to finish
  sendImageEventThread.join();
}

bool ImageStreamingApp::LoadImageFiles(bool dumpLayoutTransform) {
  if (not _imageFile.empty()) {
    std::filesystem::path filePath(_imageFile);
    std::string extension = filePath.extension();
    std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);
    if ((extension == ".bmp") or (extension == ".raw") or (extension == ".lt")) {
      auto spRawImage = std::make_shared<RawImage>(filePath, _disableExternalLT, _runLayoutTransform, _ltConfiguration);
      if (spRawImage->IsValid()) {
        _images.push_back(spRawImage);

        if (dumpLayoutTransform and _runLayoutTransform) {
          spRawImage->DumpLayoutTransform();
        }
      } else {
        std::cout << "Unsupported image: " << filePath << '\n';
      }
    }
  } else {
    for (const auto& entry : std::filesystem::directory_iterator(_imageFilesFolder)) {
      std::string filename = entry.path();
      std::filesystem::path filePath(filename);
      std::string extension = filePath.extension();
      std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);
      if ((extension == ".bmp") or (extension == ".raw") or (extension == ".lt")) {
        auto spRawImage = std::make_shared<RawImage>(filePath, _disableExternalLT, _runLayoutTransform, _ltConfiguration);
        _images.push_back(spRawImage);

        if (dumpLayoutTransform and _runLayoutTransform) {
          spRawImage->DumpLayoutTransform();
        }

        // Don't load any more than we need to send
        if (_images.size() == _numToSend) {
          break;
        }
      }
    }
  }

  std::cout << "Loaded " << _images.size() << " image";
  if (_images.size() > 1) {
    std::cout << "s";
  }
  std::cout << '\n';
  return not _images.empty();
}

bool ImageStreamingApp::OpenMsgDmaStream() {
  if (_msgDmaStream) {
    return true;
  }

  constexpr const char* msgdmaFilename = "/dev/msgdma_stream0";
  _msgDmaStream = ::fopen(msgdmaFilename, "w+");
  if (_msgDmaStream == NULL) {
    std::cout << "Failed to open" << '\n';
    return false;
  }

  // Turn off output buffering
  setvbuf(_msgDmaStream, NULL, _IONBF, 0);

  return true;
}

void ImageStreamingApp::CloseMsgDmaStream() {
  if (_msgDmaStream) {
    ::fclose(_msgDmaStream);
    _msgDmaStream = nullptr;
  }
}

bool ImageStreamingApp::SendNextImage() {
  size_t nImages = _images.size();
  if (nImages == 0) {
    return false;
  }

  if (not _msgDmaStream) {
    if (not OpenMsgDmaStream()) {
      return false;
    }
  }

  std::shared_ptr<RawImage> uploadImage = _images[_nextImageIndex];

  // Move to next index for next time
  _nextImageIndex = (_nextImageIndex + 1) % nImages;
  _sentCount++;

  char* pBuffer = reinterpret_cast<char*>(uploadImage->GetData());
  size_t bufferSize = uploadImage->GetSize();

  std::cout << _sentCount << " Send image " << uploadImage->Filename() << " size = " << bufferSize;

  size_t nWritten = ::fwrite(pBuffer, 1, bufferSize, _msgDmaStream);
  bool ok = (nWritten == bufferSize);
  if (ok) {
    std::cout << '\n';
  } else {
    std::cout << " failed\n";
  }

  return ok;
}

void ImageStreamingApp::RunSendImageSignalThread() {
  int64_t microSeconds = 1000000 / _sendRate;
  if (_sendRate == 59) {
    microSeconds = 16683;  // 59.94 Hz
  }

  while (not _shutdownEvent) {
    std::this_thread::sleep_for(std::chrono::microseconds(microSeconds));
    _sendNextImageEvent.Set();
  }
}

bool ImageStreamingApp::ProgramLayoutTransform() {
  // If the user set to skip the external LT, there is no need to program it
  if (_disableExternalLT) {
    return true;
  }

  auto spLayoutTransform = ILayoutTransform::Create();
  spLayoutTransform->SetConfiguration(_ltConfiguration);
  return true;
}

uint32_t ImageStreamingApp::GetUintOption(const char* optionName, uint32_t defaultValue) {
  std::string optionValue;
  if (_commandLine.GetOption(optionName, optionValue)) {
    return std::strtoul(optionValue.c_str(), nullptr, 0);
  } else {
    return defaultValue;
  }
}

float ImageStreamingApp::GetFloatOption(const char* optionName, float defaultValue) {
  std::string optionValue;
  if (_commandLine.GetOption(optionName, optionValue)) {
    return std::strtof(optionValue.c_str(), nullptr);
  } else {
    return defaultValue;
  }
}

void ImageStreamingApp::SigIntHandler(int) {
  std::cout << "\nShutting down application\n";
  _shutdownEvent = true;
}

bool ImageStreamingApp::WaitForInferenceApp() {
  bool isReady = false;
  bool firstTime = true;
  sem_t* pSemaphore = ::sem_open("/CoreDLA_ready_for_streaming", O_CREAT, 0644, 0);
  if (!pSemaphore) {
    return isReady;
  }

  while (not _shutdownEvent) {
    // Don't use a wait timeout because we need to break
    // if the user presses Ctrl+C
    timespec waitTimeout = {};
    int r = ::sem_timedwait(pSemaphore, &waitTimeout);
    if (r == 0) {
      isReady = true;
      ::sem_post(pSemaphore);
      break;
    }

    if (firstTime) {
      firstTime = false;
      std::cout << "Waiting for streaming_inference_app to become ready." << std::endl;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }

  ::sem_close(pSemaphore);

  return isReady;
}
