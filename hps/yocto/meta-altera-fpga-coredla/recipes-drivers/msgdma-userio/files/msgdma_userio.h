/* SPDX-License-Identifier: BSD-3-Clause */
/*
 *
 * Copyright (C) 2022 Intel Corporation, Inc.
 *
 * Authors:
 *   Richard Davies <richard.davies@intel.com>
 */
#ifndef _MSGDMA_USERIO_H_
#define _MSGDMA_USERIO_H_

#include <linux/dmaengine.h>
#include "msgdma_userio_chr.h"

struct msgdma_userio_dev_ctx {
    struct dma_chan *dma; /* Our claimed dma channel */
    struct msgdma_userio_chr_dev_ctx *chr_ctx; /* char device context */
    struct msgdma_emif_region emif_region;
    int device;
};

#endif /* _MSGDMA_USERIO_H_ */
