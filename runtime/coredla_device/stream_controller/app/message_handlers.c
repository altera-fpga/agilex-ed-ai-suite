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

#include "message_handlers.h"
#include "stream_controller_messages.h"

bool InitializeStreamControllerMessageHandler(StreamController* this, volatile uint32_t* pPayload)
{
    InitializeStreamControllerPayload* pInitializePayload = (InitializeStreamControllerPayload*)pPayload;
    this->InitializeStreamController(this,
                                     pInitializePayload->_sourceBufferSize,
                                     pInitializePayload->_dropSourceBuffers,
                                     pInitializePayload->_numInferenceRequests);
    this->SendMessage(this, MessageType_NoOperation, NULL, 0);
    return true;
}

bool ScheduleItemMessageHandler(StreamController* this, volatile uint32_t* pPayload)
{
    volatile CoreDlaJobPayload* pCoreDlaJobPayload = (volatile CoreDlaJobPayload*)pPayload;
    this->NewInferenceRequestReceived(this, pCoreDlaJobPayload);
    this->SendMessage(this, MessageType_NoOperation, NULL, 0);
    return true;
}

bool PingMessageHandler(StreamController* this, volatile uint32_t* pPayload)
{
    this->SendMessage(this, MessageType_Pong, NULL, 0);
    return true;
}

bool GetStatusMessageHandler(StreamController* this, volatile uint32_t* pPayload)
{
    StatusMessagePayload statusMessagePayload;
    statusMessagePayload._status = this->_status;
    statusMessagePayload._statusLineNumber = this->_statusLineNumber;
    statusMessagePayload._numReceivedSourceBuffers = this->_numReceivedSourceBuffers;
    statusMessagePayload._numScheduledInferences = this->_numScheduledInferences;
    statusMessagePayload._numExecutedJobs = this->_numExecutedJobs;
    this->SendMessage(this, MessageType_Status, &statusMessagePayload, sizeof(statusMessagePayload));
    return true;
}

// The DMA is configured for full word accesses only, so it cannot mask a
// partial first or last beat. Lengths and addresses that are not a whole
// number of 256 bit words would silently spill past the requested end.
// The normal path is safe because the plugin pads the length to
// kMsgDMAMaxBurstBytes and aligns the buffer to the feature word size, but
// this debug entry point takes both values straight from the host.
#define DLA_MSGDMA_0_WORD_BYTES 32

bool ManualArmDmaTransferMessageHandler(StreamController* this, volatile uint32_t* pPayload)
{
    ManualArmDmaTransferPayload* pManualArmDmaTransferPayload = (ManualArmDmaTransferPayload*)pPayload;

    if (((pManualArmDmaTransferPayload->_sourceBufferSize % DLA_MSGDMA_0_WORD_BYTES) != 0) ||
        ((pManualArmDmaTransferPayload->_inputAddressDDR % DLA_MSGDMA_0_WORD_BYTES) != 0))
    {
        this->SetStatus(this, NiosStatusType_InvalidParameter, __LINE__);
        this->SendMessage(this, MessageType_NoOperation, NULL, 0);
        return true;
    }

    CoreDlaJobItem emptyJob = {};
    this->_debugJob = emptyJob;
    this->_debugJob._payload._inputAddressDDR = pManualArmDmaTransferPayload->_inputAddressDDR;
    this->_sourceBufferSize = pManualArmDmaTransferPayload->_sourceBufferSize;
    bool fromHPS = (pManualArmDmaTransferPayload->_fromHPS != 0);
    this->ArmDmaTransfer(this, &this->_debugJob, fromHPS);
    this->SendMessage(this, MessageType_NoOperation, NULL, 0);
    return true;
}

bool ManualScheduleDlaInferenceMessageHandler(StreamController* this, volatile uint32_t* pPayload)
{
    ManualScheduleDlaInferencePayload* pManualScheduleDlaInferencePayload = (ManualScheduleDlaInferencePayload*)pPayload;
    CoreDlaJobItem emptyJob = {};
    this->_debugJob = emptyJob;
    this->_debugJob._payload._configurationBaseAddressDDR = pManualScheduleDlaInferencePayload->_configurationBaseAddressDDR;
    this->_debugJob._payload._configurationSize = pManualScheduleDlaInferencePayload->_configurationSize;
    this->_debugJob._payload._inputAddressDDR = pManualScheduleDlaInferencePayload->_inputAddressDDR;
    this->ScheduleDlaInference(this, &this->_debugJob);
    this->SendMessage(this, MessageType_NoOperation, NULL, 0);
    return true;
}


