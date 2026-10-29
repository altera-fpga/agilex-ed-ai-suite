// Copyright 2018-2020 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Intel's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

// This is derived from OPAE + OpenCL PAC BSP

#pragma push_macro("_GNU_SOURCE")
#undef _GNU_SOURCE
#define _GNU_SOURCE

#include <assert.h>
#include <safe_string/safe_string.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "memcpy_s_fast.h"
#include "x86-sse2.h"

#pragma pop_macro("_GNU_SOURCE")

static void *memcpy_setup(void *dst, size_t max, const void *src, size_t n);

memcpy_fn_t p_memcpy = memcpy_setup;  // Initial value points to setup routine

/**
 * SSE2_memcpy
 *
 * @brief                memcpy using SSE2 or REP MOVSB
 * @param[in] dst        Pointer to the destination memory
 * @param[in] max        Size in bytes of destination
 * @param[in] src        Pointer to the source memory
 * @param[in] n          Size in bytes to copy
 * @return dst
 *
 */
static void *SSE2_memcpy(void *dst, size_t max, const void *src, size_t n) {
  assert(n <= max);

  void *ldst = dst;
  void *lsrc = (void *)src;
  if (IS_CL_ALIGNED(src) && IS_CL_ALIGNED(dst))  // 64-byte aligned
  {
    if (n >= MIN_SSE2_SIZE)  // Arbitrary crossover performance point
    {
      debug_print("copying 0x%lx bytes with SSE2\n", (uint64_t)ALIGN_TO_CL(n));
      aligned_block_copy_sse2((int64_t * __restrict) dst, (int64_t * __restrict) src, ALIGN_TO_CL(n));
      ldst = (void *)((uint64_t)dst + ALIGN_TO_CL(n));
      lsrc = (void *)((uint64_t)src + ALIGN_TO_CL(n));
      n -= ALIGN_TO_CL(n);
    }
  } else {
    if (n >= MIN_SSE2_SIZE)  // Arbitrary crossover performance point
    {
      debug_print("copying 0x%lx bytes (unaligned) with SSE2\n", (uint64_t)ALIGN_TO_CL(n));
      unaligned_block_copy_sse2((int64_t * __restrict) dst, (int64_t * __restrict) src, ALIGN_TO_CL(n));
      ldst = (void *)((uint64_t)dst + ALIGN_TO_CL(n));
      lsrc = (void *)((uint64_t)src + ALIGN_TO_CL(n));
      n -= ALIGN_TO_CL(n);
    }
  }

  if (n) {
    register unsigned long int dummy;
    debug_print("copying 0x%lx bytes with REP MOVSB\n", n);
    __asm__ __volatile__("rep movsb\n"
                         : "=&D"(ldst), "=&S"(lsrc), "=&c"(dummy)
                         : "0"(ldst), "1"(lsrc), "2"(n)
                         : "memory");
  }

  return dst;
}

/**
 * memcpy_wrap
 *
 * @brief                Trampoline for memcpy
 * @param[in] dst        Pointer to the destination memory
 * @param[in] max        Size in bytes of destination
 * @param[in] src        Pointer to the source memory
 * @param[in] n          Size in bytes to copy
 * @return dst
 *
 */

#ifdef ENABLE_MEMCPY_ENV_VAR_CHECK
static void *memcpy_wrap(void *dst, size_t max, const void *src, size_t n) { return memcpy(dst, src, n); }
#endif  // ENABLE_MEMCPY_ENV_VAR_CHECK

/**
 * memcpy_setup
 * Will be called on the first memcpy_s_fast invocation only.
 *
 * @brief                Set up which memcpy routine will be used at runtime
 * @param[in] dst        Pointer to the destination memory
 * @param[in] max        Size in bytes of destination
 * @param[in] src        Pointer to the source memory
 * @param[in] n          Size in bytes to copy
 * @return dst
 *
 */

static void *memcpy_setup(void *dst, size_t max, const void *src, size_t n) {
  // Default to SSE2_memcpy
  p_memcpy = SSE2_memcpy;

//
#ifdef ENABLE_MEMCPY_ENV_VAR_CHECK
  char *pmemcpy = getenv(USE_MEMCPY_ENV);

  if (pmemcpy) {
    if (!strcasecmp(pmemcpy, "libc")) {
      p_memcpy = memcpy_wrap;
    } else if (!strcasecmp(pmemcpy, "sse2")) {
      p_memcpy = SSE2_memcpy;
    } else if (!strcasecmp(pmemcpy, "memcpy_s")) {
      p_memcpy = (memcpy_fn_t)memcpy_s;
    }
  }
#endif  // #ifdef ENABLE_MEMCPY_ENV_VAR_CHECK

  return p_memcpy(dst, max, src, n);
}
