// Copyright(c) 2017 - 2019, Intel Corporation
//
// Redistribution  and  use  in source  and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//   may be used to  endorse or promote  products derived  from this  software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * @file manage.h
 * @brief Functions for managing FPGA configurations
 *
 * FPGA accelerators can be reprogrammed at run time by providing new partial
 * bitstreams ("green bitstreams"). This file defines API functions for
 * programming green bitstreams as well as for assigning accelerators to host
 * interfaces for more complex deployment setups, such as virtualized systems.
 */

#ifndef __FPGA_MANAGE_H__
#define __FPGA_MANAGE_H__

#include <opae/types.h>

BEGIN_C_DECL

/**
* Assign Port to a host interface.
*
* This function assign Port to a host interface for subsequent use. Only
* Port that have been assigned to a host interface can be opened by
* fpgaOpen().
*
* @param[in]  fpga           Handle to an FPGA object previously opened that
*                            both the host interface and the slot belong to
* @param[in]  interface_num  Host interface number
* @param[in]  slot_num       Slot number
* @param[in]  flags          Flags (to be defined)
* @returns                   FPGA_OK on success
*                            FPGA_INVALID_PARAM if input parameter combination
*                            is not valid.
*                            FPGA_EXCEPTION if an exception occcurred accessing
*                            the `fpga` handle.
*                            FPGA_NOT_SUPPORTED if driver does not support
*                            assignment.
*/
__FPGA_API__ fpga_result fpgaAssignPortToInterface(fpga_handle fpga,
                    uint32_t interface_num,
                    uint32_t slot_num,
                    int flags);

/**
 * Assign an accelerator to a host interface
 *
 * This function assigns an accelerator to a host interface for subsequent use. Only
 * accelerators that have been assigned to a host interface can be opened by
 * fpgaOpen().
 *
 * @note This function is currently not supported.
 *
 * @param[in]  fpga           Handle to an FPGA object previously opened that
 *                            both the host interface and the accelerator belong to
 * @param[in]  afc            Accelerator to assign
 * @param[in]  host_interface Host interface to assign accelerator to
 * @param[in]  flags          Flags (to be defined)
 * @returns                   FPGA_OK on success
 */
__FPGA_API__ fpga_result fpgaAssignToInterface(fpga_handle fpga,
                  fpga_token afc,
                  uint32_t host_interface,
                  int flags);

/**
 * Unassign a previously assigned accelerator
 *
 * This function removes the assignment of an accelerator to an host interface (e.g. to
 * be later assigned to a different host interface). As a consequence, the accelerator
 * referred to by token 'accelerator' will be reset during the course of this function.
 *
 * @note This function is currently not supported.
 *
 * @param[in]  fpga           Handle to an FPGA object previously opened that
 *                            both the host interface and the accelerator belong to
 * @param[in]  afc            Accelerator to unassign/release
 * @returns                   FPGA_OK on success
 */
__FPGA_API__ fpga_result fpgaReleaseFromInterface(fpga_handle fpga,
                     fpga_token afc);

/**
 * Reconfigure a slot
 *
 * Sends a green bitstream file to an FPGA to reconfigure a specific slot. This
 * call, if successful, will overwrite the currently programmed AFU in that
 * slot with the AFU in the provided bitstream.
 *
 * As part of the reconfiguration flow, all accelerators associated with this slot will
 * be unassigned and reset.
 *
 * @param[in]  fpga           Handle to an FPGA object previously opened
 * @param[in]  slot           Token identifying the slot to reconfigure
 * @param[in]  bitstream      Pointer to memory holding the bitstream
 * @param[in]  bitstream_len  Length of the bitstream in bytes
 * @param[in]  flags          Flags (to be defined)
 * @returns FPGA_OK on success. FPGA_INVALID_PARAM if the provided parameters
 * are not valid. FPGA_EXCEPTION if an internal error occurred accessing the
 * handle or while sending the bitstream data to the driver. FPGA_RECONF_ERROR
 * on errors reported by the driver (such as CRC or protocol errors).
 */
__FPGA_API__ fpga_result fpgaReconfigureSlot(fpga_handle fpga,
             uint32_t slot,
             const uint8_t *bitstream,
             size_t bitstream_len, int flags);

/**
 * Process device specific commands
 *
 * Sends a device specific command to the driver and driver performs that action
 * and returns if needed with the data.
 *
 * @param[in]  fpga           Handle to an FPGA object previously opened
 * @param[in]  cmd            GUID identifying the command to process
 * @param[in]  buffer         Pointer to memory where data will be returned.
 * @param[in]  buffer_len     Length of the buffer passed.
 * @returns FPGA_OK on success. FPGA_INVALID_PARAM if the provided parameters
 * are not valid. FPGA_EXCEPTION if an internal error occurred accessing the
 * handle or while sending the data to the driver.
 */
__FPGA_API__ fpga_result fpgaProcessDeviceCmd(fpga_handle fpga,
    fpga_guid cmd,
    void *arg,
    void *buffer,
    size_t buffer_len);

/**
 * Enumerate all the commands supported by the device.
 *
 * To enumerate all the commands supported by a specific device, call this
 * function by passing NULL to buffer arg and it returns the number of bytes
 * that needs to be allocated to get all the commands.
 *
 * Then allocate buffer for that size and call this function to get the list
 * of all device supported CMDs.
 *
 * @param[in]  fpga         Handle to an FPGA object previously opened
 * @param[in]  cmds         Pointer to memory where cmds will be returned.
 * @param[in]  num_cmds     Pointer to memory where num cmds will be returned.
 * @returns FPGA_OK on success. FPGA_INVALID_PARAM if the provided parameters
 * are not valid. FPGA_EXCEPTION if an internal error occurred accessing the
 * handle or while sending the data to the driver.
 */
__FPGA_API__ fpga_result fpgaGetSupportedCommands(fpga_handle fpga,
    fpga_guid *cmds,
    uint32_t  *num_cmds);

END_C_DECL

#endif // __FPGA_MANAGE_H__

