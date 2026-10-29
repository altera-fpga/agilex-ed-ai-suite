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
#include <stdint.h>

typedef enum
{
    MessageType_Invalid,
    MessageType_NoOperation,
    MessageType_GetStatus,
    MessageType_Status,
    MessageType_ScheduleItem,
    MessageType_Ping,
    MessageType_Pong,
    MessageType_InitializeStreamController,
    MessageType_ManualArmDmaTransfer,
    MessageType_ManualScheduleDlaInference
} MessageType;

typedef enum
{
    NiosStatusType_OK = 1000,
    NiosStatusType_Error,
    NiosStatusType_BadMessage,
    NiosStatusType_BadMessageSequence,
    NiosStatusType_BadDescriptor,
    NiosStatusType_AsyncTransferFailed,
    NiosStatusType_MsgDmaFailed,
    NiosStatusType_InvalidParameter
} NiosStatusType;

typedef struct
{
    uint32_t _messageReadyMagicNumber;
    uint32_t _messageType;
    uint32_t _sequenceID;
    uint32_t _payload;
} MessageHeader;

// Message payloads:

typedef struct
{
    uint32_t _configurationBaseAddressDDR;
    uint32_t _configurationSize;
    uint32_t _inputAddressDDR;
    uint32_t _outputAddressDDR;
} CoreDlaJobPayload;

typedef struct
{
    uint32_t _sourceBufferSize;
    uint32_t _dropSourceBuffers;
    uint32_t _numInferenceRequests;
} InitializeStreamControllerPayload;

typedef struct
{
    NiosStatusType _status;
    uint32_t _statusLineNumber;
    uint32_t _numReceivedSourceBuffers;
    uint32_t _numScheduledInferences;
    uint32_t _numExecutedJobs;
} StatusMessagePayload;

typedef struct
{
    uint32_t _sourceBufferSize;
    uint32_t _inputAddressDDR;
    uint32_t _fromHPS;
} ManualArmDmaTransferPayload;

typedef struct
{
    uint32_t _configurationBaseAddressDDR;
    uint32_t _configurationSize;
    uint32_t _inputAddressDDR;
} ManualScheduleDlaInferencePayload;

