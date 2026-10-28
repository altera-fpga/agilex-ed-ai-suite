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

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include "altera_msgdma.h"
#include "system.h"
#include "stream_controller_messages.h"

typedef struct CoreDlaJobItem
{
    uint32_t                _index;
    bool                    _hasSourceBuffer;
    bool                    _scheduledWithDLA;
    CoreDlaJobPayload       _payload;
    struct CoreDlaJobItem*  _pPreviousJob;
    struct CoreDlaJobItem*  _pNextJob;
} CoreDlaJobItem;

typedef struct StreamController
{
    void        (*Start)(struct StreamController* this);
    void        (*Reset)(struct StreamController* this);
    bool        (*InitializeMsgDma)(struct StreamController* this);
    bool        (*ArmDmaTransfer)(struct StreamController* this, CoreDlaJobItem* pFillJob, bool fromHPS);
    void        (*RunEventLoop)(struct StreamController* this);
    void        (*WriteToDlaCsr)(struct StreamController* this, uint32_t addr, uint32_t data);
    void        (*InitializeStreamController)(struct StreamController* this,
                                              uint32_t sourceBufferSize,
                                              uint32_t dropSourceBuffers,
                                              uint32_t numInferenceRequests);
    void        (*SetStatus)(struct StreamController* this,
                             NiosStatusType statusType, uint32_t lineNumber);
    MessageType (*ReceiveMessage)(struct StreamController *this, volatile MessageHeader* pReceiveMessage);
    bool        (*SendMessage)(struct StreamController* this,
                               MessageType messageType,
                               void* pPayload,
                               size_t payloadSize);
    void        (*NewSourceBuffer)(struct StreamController* this);
    void        (*ScheduleDlaInference)(struct StreamController* this, CoreDlaJobItem* pJob);
    void        (*NewInferenceRequestReceived)(struct StreamController* this, volatile CoreDlaJobPayload* pJob);

    // Message handlers
    bool        (*GetStatusMessageHandler)(struct StreamController* this, volatile uint32_t* pPayload);
    bool        (*ScheduleItemMessageHandler)(struct StreamController* this, volatile uint32_t* pPayload);
    bool        (*PingMessageHandler)(struct StreamController* this, volatile uint32_t* pPayload);
    bool        (*InitializeStreamControllerMessageHandler)(struct StreamController* this, volatile uint32_t* pPayload);
    bool        (*ManualArmDmaTransferMessageHandler)(struct StreamController* this, volatile uint32_t* pPayload);
    bool        (*ManualScheduleDlaInferenceMessageHandler)(struct StreamController* this, volatile uint32_t* pPayload);

    CoreDlaJobItem* _jobs;
    CoreDlaJobItem* _pNextInferenceRequestJob;
    CoreDlaJobItem* _pFillingImageJob;
    CoreDlaJobItem  _debugJob;
    NiosStatusType  _status;
    uint32_t        _statusLineNumber;
    uint32_t        _commandCounter;
    uint32_t        _sourceBufferSize;
    uint32_t        _dropSourceBuffers;
    uint32_t        _totalNumInferenceRequests;
    uint32_t        _numInferenceRequests;
    uint32_t        _numExecutedJobs;
    uint32_t        _numScheduledInferences;
    uint32_t        _lastReceiveSequenceID;
    uint32_t        _sendSequenceID;
    bool            _running;
    uint32_t        _numReceivedSourceBuffers;
    volatile uint32_t   _isrCount;
    alt_msgdma_dev*     _pMsgDevice;
    alt_msgdma_extended_descriptor _msgdmaDescriptor;
} StreamController;
