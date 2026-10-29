// Copyright (C) 2025 Intel Corporation
// Debug logging utility for SPATIAL MMD

#ifndef SPATIAL_DEBUG_H
#define SPATIAL_DEBUG_H

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

/**
 * Debug print macro controlled by environment variable.
 * Set MMD_ENABLE_DEBUG=1 to enable debug output.
 * (Same env var as ofs_pcie MMD for consistency)
 *
 * Usage:
 *   SPATIAL_DEBUG("[func] message: %d\n", value);
 */
static inline void SPATIAL_DEBUG(const char *format, ...) {
    if (getenv("MMD_ENABLE_DEBUG")) {
        va_list arglist;
        va_start(arglist, format);
        vfprintf(stderr, format, arglist);
        va_end(arglist);
        fflush(stderr);
    }
}

#endif  // SPATIAL_DEBUG_H
