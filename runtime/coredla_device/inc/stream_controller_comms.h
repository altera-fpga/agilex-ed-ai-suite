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
#include <mutex>
#include <string>
#include <vector>
#include "mmd_wrapper.h"
#include "stream_controller_messages.h"

template <class T>
struct Payload : public T {
  void* GetPayload() { return this; }
  size_t GetSize() { return sizeof(*this); }
};

class BusyFlag {
 public:
  bool Lock();
  void Release();

 private:
  std::recursive_mutex _mutex;
  bool _busy = false;
};

class BusyCheck {
 public:
  BusyCheck(BusyFlag& busyFlag);
  ~BusyCheck();
  operator bool();

 private:
  BusyFlag& _busyFlag;
  bool _haveLocked;
};

class StreamControllerComms {
 public:
#ifdef AOCL_JTAG_PATH
  StreamControllerComms(const std::string& jtagPath);
#else
  StreamControllerComms();
#endif
  bool IsPresent();
  Payload<StatusMessagePayload> GetStatus();
  std::string GetStatusString(Payload<StatusMessagePayload>& statusPayload);
  bool ScheduleItems(std::vector<Payload<CoreDlaJobPayload>> items);
  bool Ping();
  bool Initialize(uint32_t sourceBufferSize, uint32_t dropSourceBuffers, uint32_t numInferenceRequests);

 private:
  bool StatusMessageHandler(uint32_t payloadOffset);
  MessageType ReceiveMessage();
  bool SendMessage(MessageType, void* pPayload = nullptr, size_t size = 0);
  MmdWrapper _mmdWrapper;
  uint32_t _lastReceiveSequenceID = 0;
  uint32_t _sendSequenceID = 0;
  uint32_t _numBadMessages = 0;
  const int _streamControllerInstance = 0;
  Payload<StatusMessagePayload> _receivedStatusMessage;
  BusyFlag _busyFlag;
};
