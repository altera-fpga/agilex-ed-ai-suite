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
#include "stream_controller.h"

extern bool InitializeStreamControllerMessageHandler(StreamController* this, volatile uint32_t* pPayload);
extern bool ScheduleItemMessageHandler(StreamController* this, volatile uint32_t* pPayload);
extern bool PingMessageHandler(StreamController* this, volatile uint32_t* pPayload);
extern bool GetStatusMessageHandler(StreamController* this, volatile uint32_t* pPayload);
extern bool ManualArmDmaTransferMessageHandler(StreamController* this, volatile uint32_t* pPayload);
extern bool ManualScheduleDlaInferenceMessageHandler(StreamController* this, volatile uint32_t* pPayload);
