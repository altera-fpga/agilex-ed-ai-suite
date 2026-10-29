/* SPDX-License-Identifier: BSD-3-Clause */
/*
 * Driver to provide user mode access to the MSGDMA DMA Engine driver
 *
 * Copyright (C) 2022 Intel Corporation, Inc.
 *
 * Authors:
 *   Richard Davies <richard.davies@intel.com>
 */

#include <linux/device.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/version.h>
#include <linux/dma-mapping.h>
#include <linux/io.h>
#include <linux/types.h>
#include <linux/slab.h>
#include <linux/dmaengine.h>

#include "msgdma_userio.h"

#define DRV_NAME "msgdma-userio"

int msgdma_userio_create_dma_engine(struct platform_device *pdev,
                    struct msgdma_userio_dev_ctx *ctx)
{
    const char *chan_str = { 0 };
    phys_addr_t of_val;

    /* We need to get the DT entry for the EMIF connected memory region */
#ifdef CONFIG_PHYS_ADDR_T_64BIT
    if (of_property_read_u64(pdev->dev.of_node, "mem_start", &of_val)) {
#else
    if (of_property_read_u32(pdev->dev.of_node, "mem_start", &of_val)) {
#endif
        dev_err(&pdev->dev, "mem_start not specified.\n");
        return -ENODEV;
    }
    ctx->emif_region.start_addr = of_val;

#ifdef CONFIG_PHYS_ADDR_T_64BIT
    if (of_property_read_u64(pdev->dev.of_node, "mem_end", &of_val)) {
#else
    if (of_property_read_u32(pdev->dev.of_node, "mem_end", &of_val)) {
#endif
        dev_err(&pdev->dev, "mem_start not specified.\n");
        return -ENODEV;
    }
    ctx->emif_region.end_addr = of_val;

    if (of_property_read_string(pdev->dev.of_node, "dma-names",
                    &chan_str)) {
        dev_err(&pdev->dev, "dma_chan name not found in devicetree.\n");
        return -ENODEV;
    }
    ctx->dma = dma_request_chan(&pdev->dev, chan_str);
    if (IS_ERR(ctx->dma)) {
        dev_err(&pdev->dev, "Failed to request dma %px\n", ctx->dma);
        return PTR_ERR(ctx->dma);
    }

    return 0;
}

void msgdma_userio_destroy_dma_engine(struct platform_device *pdev,
                      struct msgdma_userio_dev_ctx *ctx)
{
    if (ctx == NULL) {
        dev_warn(&pdev->dev, "Driver context is NULL\n");
    } else {
        if (ctx->dma) {
            dma_release_channel(ctx->dma);
            ctx->dma = NULL;
        }
    }
}

static int msgdma_userio_probe(struct platform_device *pdev)
{
    struct msgdma_userio_dev_ctx *dev_ctx;
    int ret = 0;

    /* Create a device context */
    dev_ctx = devm_kzalloc(
        &(pdev->dev), sizeof(struct msgdma_userio_dev_ctx), GFP_KERNEL);
    if (!dev_ctx) {
        ret = -ENOMEM;
        goto exit;
    }

    /* create dma_engine platform driver */
    ret = msgdma_userio_create_dma_engine(pdev, dev_ctx);
    if (ret < 0) {
        dev_err(&pdev->dev, "Failed to create dma_engine\n");
        goto exit;
    }

    /* create the char device interface */
    ret = msgdma_userio_chr_init(&(dev_ctx->chr_ctx), dev_ctx->dma,
                     dev_ctx->emif_region,
                     pdev->dev.of_node->name);
    if (ret < 0) {
        dev_err(&pdev->dev, "Failed to create char device\n");
        goto exit;
    }
    platform_set_drvdata(pdev, dev_ctx);

    dev_notice(&pdev->dev, "Altera mSGDMA Userio driver probe success\n");

exit:
    return ret;
}

static void msgdma_userio_remove(struct platform_device *pdev)
{
    struct msgdma_userio_dev_ctx *dev_ctx = platform_get_drvdata(pdev);

    msgdma_userio_destroy_dma_engine(pdev, dev_ctx);

    msgdma_userio_chr_exit(dev_ctx->chr_ctx);
    platform_set_drvdata(pdev, NULL);
    dev_notice(&pdev->dev, "Altera mSGDMA Userio driver removed\n");
}

static const struct of_device_id msgdma_userio_match[] = {
    {
        .compatible = "intel,msgdma-userio-1.0",
    },
    {},
};
MODULE_DEVICE_TABLE(of, msgdma_userio_match);

static const struct platform_device_id msgdma_userio_ids[] = { { DRV_NAME, 0 },
                                   {} };
MODULE_DEVICE_TABLE(platform, msgdma_userio_ids);

static struct platform_driver msgdma_userio_driver = {
    .probe = msgdma_userio_probe,
    .remove = msgdma_userio_remove,
    .driver = {
        .name = DRV_NAME,
        .pm = NULL,
        .of_match_table = of_match_ptr(msgdma_userio_match),
    },
    .id_table = msgdma_userio_ids,
};

static int __init msgdma_userio_init_module(void)
{
    int ret;

    ret = msgdma_userio_global_chr_init();
    if (unlikely(ret < 0)) {
        return ret;
    }

    ret = platform_driver_register(&msgdma_userio_driver);

    if (ret < 0) {
        return ret;
    }
    return 0;
}

static void __exit msgdma_userio_exit_module(void)
{
    platform_driver_unregister(&msgdma_userio_driver);
    msgdma_userio_global_chr_exit();
}

module_init(msgdma_userio_init_module);
module_exit(msgdma_userio_exit_module);

// module_platform_driver(msgdma_userio_driver);

MODULE_DESCRIPTION("mSGDMA UserIO Device Driver");
MODULE_AUTHOR("Altera Corporation");
MODULE_LICENSE("GPL v2");
