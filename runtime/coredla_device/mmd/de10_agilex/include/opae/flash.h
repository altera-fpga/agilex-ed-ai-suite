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
 * @file flash.h
 * @brief Functions to erase the flash memory and reconfigure a slot with a new bitstream .
 */

#ifndef __FLASH_H__
#define __FLASH_H__

BEGIN_C_DECL

/**
*
*   Erase flash memory
*
*   This function erases the flash memory of the FPGA device
*
*   Arguments:
*   @param[in]   fpga_handle              handle to previously opened FPGA_DEVICE resource
*
*   Return Value:
*   FPGA_OK on success.
*   FPGA_INVALID_PARAM if the handle does not refer to an owned resource.
*   FPGA_NOT_FOUND if this host interface number is not found .
*   FPGA_NOT_SUPPORTED if funcionality not supported
*
**/
__FPGA_API__ fpga_result
fpgaEraseFlash(
    fpga_handle  fpga_handle
    );


/**
*   Writes flash memory
*
*   This function programs the flash chip on the FPGA with the provided bitstream.
*
*   Arguments:
*   @param[in]  handle                handle to an FPGA_DEVICE resource
*   @param[in]  flashBitstream        pointer to memory holding the flash bitstream
*   @param[in]  flashBitstreamLen     length of the bitstream in bytes
*   @param[in]  offset                offset in flash controller to begin writing from
*
*   Return Value:
*   FPGA_OK on success.
*   FPGA_INVALID_PARAM if the handle does not refer to an owned resource.
*   FPGA_NOT_FOUND if this host interface number is not found .
*   FPGA_NOT_SUPPORTED if funcionality not supported.
*/

__FPGA_API__ fpga_result
fpgaWriteFlash(
    fpga_handle handle,
    PUINT8      flashBitstream,
    UINT64      flashBitstreamLen,
    UINT64      offset
);

END_C_DECL

#endif // __FLASH_H__
