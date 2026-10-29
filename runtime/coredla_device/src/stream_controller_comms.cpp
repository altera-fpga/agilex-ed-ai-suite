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

#include "stream_controller_comms.h"
#include <chrono>
#include <cstring>
#include <iostream>
#include <sstream>
#include <thread>

// StreamControllerComms provides an interface to the Stream Controller
// microcode running in the NIOS-V

static const uint32_t messageReadyMagicNumber = 0x55225522;
static constexpr uint32_t mailboxRamSize = 0x1000;

#ifdef AOCL_JTAG_PATH
StreamControllerComms::StreamControllerComms(const std::string& jtagPath): _mmdWrapper(jtagPath) {}
#else
StreamControllerComms::StreamControllerComms() {}
#endif

bool StreamControllerComms::IsPresent() {
  // Check there is an interface to the stream controller
  if (!_mmdWrapper.bIsStreamControllerValid(_streamControllerInstance)) {
    return false;
  }

  // Check that the stream controller responds
  bool isPresent = Ping();
  return isPresent;
}

// Query for the current status
Payload<StatusMessagePayload> StreamControllerComms::GetStatus() {
  BusyCheck busyCheck(_busyFlag);
  if (!busyCheck) {
    return {};
  }

  if (SendMessage(MessageType_GetStatus)) {
    if (ReceiveMessage() == MessageType_Status) {
      return _receivedStatusMessage;
    }
  }

  return {};
}

// Schedule an inference request with the stream controller
bool StreamControllerComms::ScheduleItems(std::vector<Payload<CoreDlaJobPayload>> items) {
  BusyCheck busyCheck(_busyFlag);
  if (!busyCheck) {
    return false;
  }

  bool status = true;

  for (auto& job : items) {
    bool thisJobStatus = false;

    if (SendMessage(MessageType_ScheduleItem, job.GetPayload(), job.GetSize())) {
      if (ReceiveMessage() == MessageType_NoOperation) {
        thisJobStatus = true;
      }
    }

    if (!thisJobStatus) {
      status = false;
    }
  }

  return status;
}

// Send a ping command to the stream controller and wait for a pong
// response.
bool StreamControllerComms::Ping() {
  BusyCheck busyCheck(_busyFlag);
  if (!busyCheck) {
    return false;
  }

  if (SendMessage(MessageType_Ping)) {
    return (ReceiveMessage() == MessageType_Pong);
  }

  return false;
}

// Initialize and reset the stream controller
//
// sourceBufferSize:
//      The size of the MSGDMA buffers that the stream
//      controller will receive from the layout transform
// dropSourceBuffers:
//      How many source buffers to drop between each
//      processed one. 0 by default unless set in the configuration
//      by the app with DLIAPlugin::properties::streaming_drop_source_buffers.name()
// numInferenceRequest:
//      A constant value set in the executable network. The
//      stream controller will start executing once it has
//      received this number of inference requests from OpenVINO
bool StreamControllerComms::Initialize(uint32_t sourceBufferSize,
                                       uint32_t dropSourceBuffers,
                                       uint32_t numInferenceRequests) {
  BusyCheck busyCheck(_busyFlag);
  if (!busyCheck) {
    return false;
  }

  Payload<InitializeStreamControllerPayload> initializePayload{};
  initializePayload._sourceBufferSize = sourceBufferSize;
  initializePayload._dropSourceBuffers = dropSourceBuffers;
  initializePayload._numInferenceRequests = numInferenceRequests;

  if (SendMessage(
          MessageType_InitializeStreamController, initializePayload.GetPayload(), initializePayload.GetSize())) {
    if (ReceiveMessage() == MessageType_NoOperation) {
      return true;
    }
  }

  return false;
}

// Receive a message from the stream controller by reading from the
// mailbox memory until the magic number is set to indicate a message is ready.
// Only the Status return message has a payload
MessageType StreamControllerComms::ReceiveMessage() {
  uint32_t receiveMessageOffset = mailboxRamSize / 2;
  MessageHeader* pReceiveMessage = nullptr;
  uint32_t messageReadyMagicNumberOffset = receiveMessageOffset;
  uint32_t payloadOffset = static_cast<uint32_t>(receiveMessageOffset + (size_t)&pReceiveMessage->_payload);
  uint32_t waitCount = 0;

  while (waitCount < 100) {
    MessageHeader messageHeader;
    _mmdWrapper.ReadFromStreamController(
        _streamControllerInstance, receiveMessageOffset, sizeof(messageHeader), &messageHeader);
    if (messageHeader._messageReadyMagicNumber == messageReadyMagicNumber) {
      MessageType messageType = static_cast<MessageType>(messageHeader._messageType);
      uint32_t sequenceId = messageHeader._sequenceID;

      bool ok = false;

      if (messageType == MessageType_Status) {
        ok = StatusMessageHandler(payloadOffset);
      } else if (messageType == MessageType_Pong) {
        ok = true;
      }

      if (!ok) {
        _numBadMessages++;
      }

      _mmdWrapper.WriteToStreamController(
          _streamControllerInstance, messageReadyMagicNumberOffset, sizeof(sequenceId), &sequenceId);
      _lastReceiveSequenceID = sequenceId;
      return messageType;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(1));
    waitCount++;
  }

  return MessageType_Invalid;
}

// Send a message to the stream controller by writing to the mailbox memory,
// and wait for the message to be received/processed
bool StreamControllerComms::SendMessage(MessageType messageType, void* pPayload, size_t payloadSize) {
  uint32_t sendMessageOffset = 0;
  MessageHeader* pSendMessage = nullptr;
  uint32_t messageReadyMagicNumberOffset = 0;
  uint32_t messageTypeOffset = static_cast<uint32_t>((size_t)&pSendMessage->_messageType);
  uint32_t sequenceIDOffset = static_cast<uint32_t>((size_t)&pSendMessage->_sequenceID);
  uint32_t payloadOffset = static_cast<uint32_t>((size_t)&pSendMessage->_payload);

  uint32_t uintMessageType = static_cast<uint32_t>(messageType);

  _mmdWrapper.WriteToStreamController(
      _streamControllerInstance, messageTypeOffset, sizeof(uintMessageType), &uintMessageType);
  _mmdWrapper.WriteToStreamController(
      _streamControllerInstance, sequenceIDOffset, sizeof(_sendSequenceID), &_sendSequenceID);

  if (payloadSize > 0) {
    _mmdWrapper.WriteToStreamController(_streamControllerInstance, payloadOffset, payloadSize, pPayload);
  }

  // Signal the message as ready
  _mmdWrapper.WriteToStreamController(_streamControllerInstance,
                                      messageReadyMagicNumberOffset,
                                      sizeof(messageReadyMagicNumber),
                                      &messageReadyMagicNumber);

  // Wait until the message has been processed by looking for the sequence ID
  // in the magic number position
  uint32_t waitCount = 0;
  while (waitCount < 100) {
    MessageHeader messageHeader;
    _mmdWrapper.ReadFromStreamController(
        _streamControllerInstance, sendMessageOffset, sizeof(messageHeader), &messageHeader);

    if (messageHeader._messageReadyMagicNumber == _sendSequenceID) {
      _sendSequenceID++;
      return true;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(1));
    waitCount++;
  }

  return false;
}

// Read the status message payload
bool StreamControllerComms::StatusMessageHandler(uint32_t payloadOffset) {
  _mmdWrapper.ReadFromStreamController(
      _streamControllerInstance, payloadOffset, sizeof(_receivedStatusMessage), &_receivedStatusMessage);
  return true;
}

// Parse the status message payload into a string
std::string StreamControllerComms::GetStatusString(Payload<StatusMessagePayload>& statusPayload) {
  std::ostringstream stringStream;
  stringStream << static_cast<uint32_t>(statusPayload._status) << "," << statusPayload._statusLineNumber << ","
               << statusPayload._numReceivedSourceBuffers << "," << statusPayload._numScheduledInferences << ","
               << statusPayload._numExecutedJobs;
  return stringStream.str();
}

///////////////////////////////////////////////////////////////////////////////

// BusyFlag is used to prevent concurrent access to the stream controller,
// without holding a mutex when sending/receiving commands
using LockGuard = std::lock_guard<std::recursive_mutex>;

bool BusyFlag::Lock() {
  LockGuard lock(_mutex);
  if (_busy) {
    return false;
  }

  _busy = true;
  return true;
}

void BusyFlag::Release() {
  LockGuard lock(_mutex);
  _busy = false;
}

BusyCheck::BusyCheck(BusyFlag& busyFlag) : _busyFlag(busyFlag), _haveLocked(false) {}

BusyCheck::~BusyCheck() {
  if (_haveLocked) {
    _busyFlag.Release();
  }
}

BusyCheck::operator bool() {
  bool locked = _busyFlag.Lock();
  if (locked) {
    _haveLocked = true;
  }
  return locked;
}
