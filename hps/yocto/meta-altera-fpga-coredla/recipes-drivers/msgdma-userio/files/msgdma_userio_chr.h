/* SPDX-License-Identifier: BSD-3-Clause */
/*
 * Header file for char device for the msgdma_userio driver
 *
 * Copyright (C) 2022 Intel Corporation, Inc.
 *
 * Authors:
 *   Richard Davies <richard.davies@intel.com>
 */
#ifndef _MSGDMA_USERIO_CHR_H_
#define _MSGDMA_USERIO_CHR_H_

#include <linux/cdev.h>

#define MSGDMA_USERIO_CLASS_NAME "msgdma_userio_class"
#define MSGDMA_USERIO_DRIVER_NAME "msgdma_userio_driver"

/**
 * Character Device Name Prefix
 */
#define MSGDMA_USERIO_CHARDEV_NAME_PREFIX "msgdma"

/**
 * Allow binding to upto 4 DMA Engines
 */
#define MSGDMA_USERIO_MAX_DEV 4

#define MAX_MSGDMA_USERIO_CHAR_DEVICE_NAME (30)

struct msgdma_emif_region {
    phys_addr_t start_addr;
    phys_addr_t end_addr;
};

struct msgdma_userio_chr_dev_ctx {
    char chr_dev_name[MAX_MSGDMA_USERIO_CHAR_DEVICE_NAME]; /* char device name */
    struct cdev msgdma_userio_cdev;
    struct device *msgdma_userio_device;
    int major;
    int minor;

    struct dma_chan *dma;
    struct msgdma_emif_region emif_region;
};

extern int msgdma_userio_chr_init(struct msgdma_userio_chr_dev_ctx **dctx,
                  struct dma_chan *dma,
                  const struct msgdma_emif_region emif_region,
                  const char *device_name);
extern void msgdma_userio_chr_exit(struct msgdma_userio_chr_dev_ctx *ctx);

/* Global char device */
struct msgdma_userio_global_ctx {
    struct class *gclass;
    dev_t device_number;
};

extern int msgdma_userio_global_chr_init(void);
extern void msgdma_userio_global_chr_exit(void);

#endif /* _MSGDMA_USERIO_CHR_H_ */
