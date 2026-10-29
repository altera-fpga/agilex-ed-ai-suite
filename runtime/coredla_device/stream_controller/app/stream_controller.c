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

#include "stream_controller.h"
#include "message_handlers.h"
#include "sys/alt_cache.h"
#ifdef STREAM_CONTROLLER_ADDR_DEBUG
#include "sys/alt_stdio.h"
#endif
#include "dla_registers.h"
#include <string.h>

static const uint32_t messageReadyMagicNumber = 0x55225522;
static const uint32_t mailboxBaseAddress = 0x40000;
static const uint32_t mailboxSize = 0x1000;
static const uint32_t dlaBaseAddress = 0x30000;

static void Start(StreamController* this);
static void Reset(StreamController* this);
static bool InitializeMsgDma(StreamController* this);
static bool ArmDmaTransfer(StreamController* this, CoreDlaJobItem* pFillJob, bool fromHPS);
static void RunEventLoop(StreamController* this);
static void WriteToDlaCsr(StreamController* this, uint32_t addr, uint32_t data);
static void InitializeStreamController(StreamController* this, uint32_t sourceBufferSize, uint32_t dropSourceBuffers, uint32_t numInferenceRequests);
static void SetStatus(StreamController* this, NiosStatusType statusType, uint32_t lineNumber);
static MessageType ReceiveMessage(StreamController* this, volatile MessageHeader* pReceiveMessage);
static bool SendMessage(StreamController* this,
                        MessageType messageType,
                        void* pPayload,
                        size_t payloadSize);
static void NewSourceBuffer(StreamController* this);
static void ScheduleDlaInference(StreamController* this, CoreDlaJobItem* pJob);
static void NewInferenceRequestReceived(StreamController* this, volatile CoreDlaJobPayload* pJobPayload);
static void MsgDmaIsr(void* pContext);

int main()
{
    StreamController streamController = {};
    StreamController* this = &streamController;

    this->Start = Start;
    this->Reset = Reset;
    this->InitializeMsgDma = InitializeMsgDma;
    this->ArmDmaTransfer = ArmDmaTransfer;
    this->RunEventLoop = RunEventLoop;
    this->WriteToDlaCsr = WriteToDlaCsr;
    this->InitializeStreamController = InitializeStreamController;
    this->SetStatus = SetStatus;
    this->ReceiveMessage = ReceiveMessage;
    this->SendMessage = SendMessage;
    this->NewSourceBuffer = NewSourceBuffer;
    this->ScheduleDlaInference = ScheduleDlaInference;
    this->NewInferenceRequestReceived = NewInferenceRequestReceived;

    // Message handlers
    this->GetStatusMessageHandler = GetStatusMessageHandler;
    this->ScheduleItemMessageHandler = ScheduleItemMessageHandler;
    this->PingMessageHandler = PingMessageHandler;
    this->InitializeStreamControllerMessageHandler = InitializeStreamControllerMessageHandler;
    this->ManualArmDmaTransferMessageHandler = ManualArmDmaTransferMessageHandler;
    this->ManualScheduleDlaInferenceMessageHandler = ManualScheduleDlaInferenceMessageHandler;

    this->Reset(this);
    this->Start(this);

    return 0;
}

static void Start(StreamController* this)
{
    // Clear the mailbox memory
    uint8_t* pMailbox = (uint8_t*)(mailboxBaseAddress);
    memset(pMailbox, 0, mailboxSize);

    if (this->InitializeMsgDma(this))
    {
        // Run the main event loop
        this->RunEventLoop(this);
    }
}

static bool InitializeMsgDma(StreamController* this)
{
    this->_pMsgDevice = alt_msgdma_open(DLA_MSGDMA_0_CSR_NAME);
    if (this->_pMsgDevice)
    {
        alt_msgdma_register_callback(this->_pMsgDevice, MsgDmaIsr, 0, this);
        alt_dcache_flush_all();
        return true;
    }
    else
    {
        this->SetStatus(this, NiosStatusType_MsgDmaFailed, __LINE__);
        return false;
    }
}

// Lightweight hex/dec printers over the JTAG UART. We deliberately avoid printf
// here: pulling in newlib's formatted output overflows the small Nios V RAM.
#ifdef STREAM_CONTROLLER_ADDR_DEBUG
static void PrintHex32(uint32_t value)
{
    static const char kHexDigits[] = "0123456789ABCDEF";
    char buf[9];
    for (int i = 7; i >= 0; --i)
    {
        buf[i] = kHexDigits[value & 0xF];
        value >>= 4;
    }
    buf[8] = '\0';
    alt_putstr("0x");
    alt_putstr(buf);
}

static void PrintDec32(uint32_t value)
{
    char buf[11];
    int i = 10;
    buf[i] = '\0';
    if (value == 0)
    {
        buf[--i] = '0';
    }
    while (value > 0)
    {
        buf[--i] = (char)('0' + (value % 10));
        value /= 10;
    }
    alt_putstr(&buf[i]);
}
#endif // STREAM_CONTROLLER_ADDR_DEBUG

static bool ArmDmaTransfer(StreamController* this, CoreDlaJobItem* pFillJob, bool fromHPS)
{
    this->_pFillingImageJob = pFillJob;

    alt_u32* pWriteBuffer = (alt_u32*)this->_pFillingImageJob->_payload._inputAddressDDR;
    alt_u32 length = this->_sourceBufferSize;
    alt_u32 control = ALTERA_MSGDMA_DESCRIPTOR_CONTROL_TRANSFER_COMPLETE_IRQ_MASK;

#ifdef STREAM_CONTROLLER_ADDR_DEBUG
    // Debug: DDR region the msgDMA will write this source buffer into.
    alt_putstr("[stream_controller] source buffer DMA: start=");
    PrintHex32((alt_u32)pWriteBuffer);
    alt_putstr(" size=");
    PrintHex32(length);
    alt_putstr(" (");
    PrintDec32(length);
    alt_putstr(") end=");
    PrintHex32((alt_u32)pWriteBuffer + length);
    alt_putstr("\n");
#endif // STREAM_CONTROLLER_ADDR_DEBUG

    int r = 0;
    if (fromHPS)
    {
        r = alt_msgdma_construct_extended_st_to_mm_descriptor(this->_pMsgDevice,
                                                              &this->_msgdmaDescriptor,
                                                              pWriteBuffer,
                                                              length,
                                                              control,
                                                              0,
                                                              0,
                                                              1);
    }
    else
    {
        r = alt_msgdma_construct_extended_mm_to_st_descriptor(this->_pMsgDevice,
                                                              &this->_msgdmaDescriptor,
                                                              pWriteBuffer,
                                                              length,
                                                              control,
                                                              0,
                                                              0,
                                                              1);
    }

    if (r == 0)
    {
        r = alt_msgdma_extended_descriptor_async_transfer(this->_pMsgDevice, &this->_msgdmaDescriptor);
        if (r != 0)
        {
            this->SetStatus(this, NiosStatusType_AsyncTransferFailed, __LINE__);
        }
    }
    else
    {
        this->SetStatus(this, NiosStatusType_BadDescriptor, __LINE__);
    }

    return (r == 0);
}

static void RunEventLoop(StreamController* this)
{
    volatile MessageHeader* pReceiveMessage = (MessageHeader*)(mailboxBaseAddress);

    uint32_t previousIsrCount = this->_isrCount;

    while (true)
    {
        uint32_t isrCount = this->_isrCount;

        if (isrCount != previousIsrCount)
        {
            this->NewSourceBuffer(this);
        }

        if (pReceiveMessage->_messageReadyMagicNumber == messageReadyMagicNumber)
        {
            this->ReceiveMessage(this, pReceiveMessage);
        }

        previousIsrCount = isrCount;
    }
}

static MessageType ReceiveMessage(StreamController* this, volatile MessageHeader* pReceiveMessage)
{
    MessageType messageType = pReceiveMessage->_messageType;
    uint32_t sequenceId = pReceiveMessage->_sequenceID;
    this->_commandCounter++;

    bool ok = false;

    volatile uint32_t* pPayload = &pReceiveMessage->_payload;

    if (messageType == MessageType_GetStatus)
        ok = this->GetStatusMessageHandler(this, pPayload);
    else if (messageType == MessageType_ScheduleItem)
        ok = this->ScheduleItemMessageHandler(this, pPayload);
    else if (messageType == MessageType_Ping)
        ok = this->PingMessageHandler(this, pPayload);
    else if (messageType == MessageType_InitializeStreamController)
        ok = this->InitializeStreamControllerMessageHandler(this, pPayload);
    else if (messageType == MessageType_ManualArmDmaTransfer)
        ok = this->ManualArmDmaTransferMessageHandler(this, pPayload);
    else if (messageType == MessageType_ManualScheduleDlaInference)
        ok = this->ManualScheduleDlaInferenceMessageHandler(this, pPayload);

    if (!ok)
        this->SetStatus(this, NiosStatusType_BadMessage, __LINE__);

    pReceiveMessage->_messageReadyMagicNumber = sequenceId;

    if ((this->_lastReceiveSequenceID != 0) && ((this->_lastReceiveSequenceID + 1) != sequenceId))
    {
        // If the DLA plugin has restarted, the first message will be InitializeStreamController
        // with a sequence ID of 0
        if ((sequenceId != 0) || (messageType != MessageType_InitializeStreamController))
            this->SetStatus(this, NiosStatusType_BadMessageSequence, __LINE__);
    }

    this->_lastReceiveSequenceID = sequenceId;
    return messageType;
}

static bool SendMessage(StreamController* this,
                        MessageType messageType,
                        void *pPayload,
                        size_t payloadSize)
{
    uint32_t mailboxSendAddress = mailboxBaseAddress + (mailboxSize / 2);
    uint32_t* pMailbox = (uint32_t*)mailboxSendAddress;
    MessageHeader* pSendMessage = (MessageHeader*)(pMailbox);
    void* pPayloadDestination = &pSendMessage->_payload;

    pSendMessage->_messageType = messageType;
    pSendMessage->_sequenceID = this->_sendSequenceID;

    if (payloadSize > 0)
        memcpy(pPayloadDestination, pPayload, payloadSize);

    // Signal the message as ready
    pSendMessage->_messageReadyMagicNumber = messageReadyMagicNumber;

    this->_sendSequenceID++;
    return true;
}

// We have received a new source buffer via the msgdma
static void NewSourceBuffer(StreamController* this)
{
    // Read the response to flush the buffer
    CoreDlaJobItem* pJustFilledJob = this->_pFillingImageJob;
    CoreDlaJobItem* pNextFillJob = NULL;

    uint32_t bufferSequence = this->_numReceivedSourceBuffers;
    this->_numReceivedSourceBuffers++;

    // Have we just captured a manually armed DMA transfer?
    if (pJustFilledJob == &this->_debugJob)
        return;

    if (this->_dropSourceBuffers > 0)
    {
        // If _dropSourceBuffers = 1, we process 1, drop 1 etc
        // if _dropSourceBuffers = 2, we process 1, drop 2, process 1, drop 2 etc
        if (bufferSequence % (this->_dropSourceBuffers + 1) != 0)
        {
            // Drop this buffer, capture the next one in its place
            this->ArmDmaTransfer(this, pJustFilledJob, true);
            return;
        }
    }

    pJustFilledJob->_hasSourceBuffer = true;

    if (pJustFilledJob->_pNextJob->_hasSourceBuffer)
    {
        // No space in the next job, so keep filling the same job
        pNextFillJob = pJustFilledJob;

        // It already has a buffer but we have to
        // consider this as dropped as we will write another
        // in its place
        pNextFillJob->_hasSourceBuffer = false;
    }
    else
    {
        pNextFillJob = pJustFilledJob->_pNextJob;
    }

    // Re-arm the DMA transfer
    this->ArmDmaTransfer(this, pNextFillJob, true);

    // If there are less than two scheduled buffers, then we can schedule another one
    // _pNextInferenceRequestJob is the executing job if it is marked as scheduled

    uint32_t nScheduled = 0;
    if (this->_pNextInferenceRequestJob->_scheduledWithDLA)
        nScheduled++;
    if (this->_pNextInferenceRequestJob->_pNextJob->_scheduledWithDLA)
        nScheduled++;

    if (nScheduled < 2)
        this->ScheduleDlaInference(this, pJustFilledJob);
}

static void NewInferenceRequestReceived(StreamController* this, volatile CoreDlaJobPayload* pJobPayload)
{
    // Once we have received all '_totalNumInferenceRequests' inference requests,
    // we set the state to running and can now capture the input dma's
    bool wasRunning = this->_running;
    this->_numInferenceRequests++;
    this->_running = (this->_numInferenceRequests >= this->_totalNumInferenceRequests);

    CoreDlaJobItem* pThisJob = this->_pNextInferenceRequestJob;

    // Store the job details and move to the next
    uint32_t previousAddress = pThisJob->_payload._inputAddressDDR;
    pThisJob->_payload = *pJobPayload;

#ifdef STREAM_CONTROLLER_ADDR_DEBUG
    // Debug: DDR bases captured from the host for this recycled job slot.
    alt_putstr("[stream_controller] inference request: input_output_base=");
    PrintHex32(pThisJob->_payload._inputAddressDDR);
    alt_putstr(" size=");
    PrintHex32(this->_sourceBufferSize);
    alt_putstr(" (");
    PrintDec32(this->_sourceBufferSize);
    alt_putstr(") end=");
    PrintHex32(pThisJob->_payload._inputAddressDDR + this->_sourceBufferSize);
    alt_putstr(" output_base=");
    PrintHex32(pThisJob->_payload._outputAddressDDR);
    alt_putstr(" config_base=");
    PrintHex32(pThisJob->_payload._configurationBaseAddressDDR);
    alt_putstr("\n");
#endif // STREAM_CONTROLLER_ADDR_DEBUG

    // This job has just completed so clear its state
    pThisJob->_scheduledWithDLA = false;
    pThisJob->_hasSourceBuffer = false;

    // The jobs are recycled by the DLA plugin so the inputAddrDDR should
    // stay the same for each _jobs[n]
    if ((pThisJob->_payload._inputAddressDDR != previousAddress) && (previousAddress != 0))
        this->SetStatus(this, NiosStatusType_Error, __LINE__);

    this->_pNextInferenceRequestJob = this->_pNextInferenceRequestJob->_pNextJob;

    if (wasRunning)
    {
        this->_numExecutedJobs++;

        // Check if we have any jobs ready to be scheduled. Maximum of 2 can have _scheduledWithDLA set
        if (!this->_pNextInferenceRequestJob->_scheduledWithDLA && this->_pNextInferenceRequestJob->_hasSourceBuffer)
        {
            this->ScheduleDlaInference(this, this->_pNextInferenceRequestJob);
        }
        else if (!this->_pNextInferenceRequestJob->_pNextJob->_scheduledWithDLA && this->_pNextInferenceRequestJob->_pNextJob->_hasSourceBuffer)
        {
            this->ScheduleDlaInference(this, this->_pNextInferenceRequestJob->_pNextJob);
        }
    }
    else if (this->_running)
    {
        // We have just started running
        // Arm the DMA transfer to start receiving source buffers
        this->ArmDmaTransfer(this, &this->_jobs[0], true);
    }
}

static void ScheduleDlaInference(StreamController* this, CoreDlaJobItem* pJob)
{
    // The DLA has an input FIFO. By setting the base address register,
    // we add this request to the FIFO
    pJob->_scheduledWithDLA = true;
    this->_numScheduledInferences++;

    CoreDlaJobPayload* pJobPayload = &pJob->_payload;

#ifdef STREAM_CONTROLLER_ADDR_DEBUG
    // Debug: DDR bases handed to the DLA for this inference.
    alt_putstr("[stream_controller] schedule DLA: input_output_base=");
    PrintHex32(pJobPayload->_inputAddressDDR);
    alt_putstr(" output_base=");
    PrintHex32(pJobPayload->_outputAddressDDR);
    alt_putstr(" config_base=");
    PrintHex32(pJobPayload->_configurationBaseAddressDDR);
    alt_putstr(" config_size=");
    PrintHex32(pJobPayload->_configurationSize);
    alt_putstr("\n");
#endif // STREAM_CONTROLLER_ADDR_DEBUG

    this->WriteToDlaCsr(this, DLA_DMA_CSR_OFFSET_CONFIG_BASE_ADDR, pJobPayload->_configurationBaseAddressDDR);
    this->WriteToDlaCsr(this, DLA_DMA_CSR_OFFSET_CONFIG_RANGE_MINUS_TWO, pJobPayload->_configurationSize);
    this->WriteToDlaCsr(this, DLA_DMA_CSR_OFFSET_INPUT_OUTPUT_BASE_ADDR, pJobPayload->_inputAddressDDR);
}

static void SetStatus(StreamController* this, NiosStatusType statusType, uint32_t lineNumber)
{
    this->_status = statusType;
    this->_statusLineNumber = lineNumber;
}

static void InitializeStreamController(StreamController* this,
                                       uint32_t sourceBufferSize,
                                       uint32_t dropSourceBuffers,
                                       uint32_t numInferenceRequests)
{
    if ((numInferenceRequests == 0) || (numInferenceRequests > (SIZE_MAX / sizeof(CoreDlaJobItem))))
    {
        this->SetStatus(this, NiosStatusType_InvalidParameter, __LINE__);
        return;
    }

    if (this->_jobs != NULL)
    {
        if (numInferenceRequests != this->_totalNumInferenceRequests)
        {
            this->SetStatus(this, NiosStatusType_InvalidParameter, __LINE__);
            return;
        }

        this->_sourceBufferSize = sourceBufferSize;
        this->_dropSourceBuffers = dropSourceBuffers;
        this->Reset(this);
        return;
    }

    CoreDlaJobItem* pJobs = malloc(sizeof(*pJobs) * numInferenceRequests);
    if (pJobs == NULL)
    {
        this->SetStatus(this, NiosStatusType_Error, __LINE__);
        return;
    }

    this->_sourceBufferSize = sourceBufferSize;
    this->_dropSourceBuffers = dropSourceBuffers;
    this->_totalNumInferenceRequests = numInferenceRequests;
    this->_jobs = pJobs;
    this->Reset(this);
}

static void Reset(StreamController* this)
{
    if (this->_jobs != NULL)
    {
        CoreDlaJobItem emptyJob = {};
        uint32_t lastIndex = this->_totalNumInferenceRequests - 1;

        // Set up the circular job buffers
        for (uint32_t i = 0; i < this->_totalNumInferenceRequests; i++)
        {
            this->_jobs[i] = emptyJob;
            this->_jobs[i]._index = i;
            uint32_t previousIndex = (i == 0) ? lastIndex : i - 1;
            uint32_t nextIndex = (i == lastIndex) ? 0 : i + 1;
            this->_jobs[i]._pPreviousJob = &this->_jobs[previousIndex];
            this->_jobs[i]._pNextJob = &this->_jobs[nextIndex];
        }

        this->_pNextInferenceRequestJob = &this->_jobs[0];
        this->_pFillingImageJob = &this->_jobs[0];
    }
    else
    {
        this->_pNextInferenceRequestJob = NULL;
        this->_pFillingImageJob = NULL;
    }

    this->_status = NiosStatusType_OK;
    this->_statusLineNumber = 0;
    this->_commandCounter = 0;
    this->_numInferenceRequests = 0;
    this->_numExecutedJobs = 0;
    this->_numScheduledInferences = 0;
    this->_lastReceiveSequenceID = 0;
    this->_sendSequenceID = 0;
    this->_running = false;
    this->_isrCount = 0;
    this->_numReceivedSourceBuffers = 0;
}

static void WriteToDlaCsr(StreamController* this, uint32_t addr, uint32_t data)
{
    uint32_t* pRegister = (uint32_t*)(dlaBaseAddress + addr);
    pRegister[0] = data;
}

// Incrementing the ISR count here will result in NewSourceBuffer above being called
// in the event loop
static void MsgDmaIsr(void* pContext)
{
    StreamController* this = (StreamController*)pContext;
    this->_isrCount++;
}
