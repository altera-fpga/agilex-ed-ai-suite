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
 * @file macrodefs.h
 * @brief Definitions of conveinence macros for the OPAE C API
 *
 * This file defines convenience macros for the OPAE C API functions.
 */

#ifndef __FPGA_MACRODEFS_H__
#define __FPGA_MACRODEFS_H__

// Check for conflicting definitions
#ifdef BEGIN_C_DECL
#error BEGIN_C_DECL already defined, but used by the OPAE library
#endif

#ifdef END_C_DECL
#error END_C_DECL already defined, but used by the OPAE library
#endif

#ifdef __FPGA_API__
#error __FPGA_API__ already defined, but used by the OPAE library
#endif

// Macro for symbol visibility
#ifdef _WIN32
#ifdef FpgaLib_EXPORTS
#define __FPGA_API__ __declspec(dllexport)
#else
#define __FPGA_API__ __declspec(dllimport)
#endif
#else
#define __FPGA_API__ __attribute__((visibility("default")))
#endif

// Macro for disabling name mangling
#ifdef __cplusplus
#define BEGIN_C_DECL extern "C" {
#define END_C_DECL }
#else
#define BEGIN_C_DECL
#define END_C_DECL
#endif

#endif // __FPGA_MACRODEFS_H__
