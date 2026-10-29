#ifndef FPGA_H
#define FPGA_H

#include <opae/fpga.h>

#include "afu_json_info.h"

/**
 * Process-wide OPAE handle for the spatial MMD. nullptr if not connected.
 */
fpga_handle spatial_fpga_handle();

/**
 * Opens the process-wide FPGA session (first accelerator matching AFU_ACCEL_UUID).
 * Only one device per process is supported.
 *
 * @return 0 on success, non-zero on failure.
 */
int connect_to_fpga();

/**
 * Closes the process-wide FPGA session opened by connect_to_fpga().
 *
 * @return 0 on success, non-zero on failure.
 */
int disconnect_fpga();

#endif  // FPGA_H
