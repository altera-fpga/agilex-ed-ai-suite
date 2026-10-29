/* (C) 1992-2017 Intel Corporation.                             */
/* Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words     */
/* and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.   */
/* and/or other countries. Other marks and brands may be claimed as the property   */
/* of others. See Trademarks on intel.com for full list of Intel trademarks or     */
/* the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera)  */
/* Your use of Intel Corporation's design tools, logic functions and other         */
/* software and tools, and its AMPP partner logic functions, and any output        */
/* files any of the foregoing (including device programming or simulation          */
/* files), and any associated documentation or information are expressly subject   */
/* to the terms and conditions of the Altera Program License Subscription          */
/* Agreement, Intel MegaCore Function License Agreement, or other applicable       */
/* license agreement, including, without limitation, that your use is for the      */
/* sole purpose of programming logic devices manufactured by Intel and sold by     */
/* Intel or its authorized distributors.  Please refer to the applicable           */
/* agreement for further details.                                                  */

#ifndef MEMCPY_S_FAST_H_
#define MEMCPY_S_FAST_H_

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

// Constants needed in memcpy routines
// Arbitrary crossover point for using SSE2 over rep movsb
#define MIN_SSE2_SIZE 4096

// TODO: hidden environment variables to experiment with performance
// in production software are not a good idea in my opinion. Commenting out
// for now but hopefully can remove this code completely in the long term.
//#define USE_MEMCPY_ENV        "PAC_MEMCPY"

#define CACHE_LINE_SIZE 64
#define ALIGN_TO_CL(x) ((uint64_t)(x) & ~(CACHE_LINE_SIZE - 1))
#define IS_CL_ALIGNED(x) (((uint64_t)(x) & (CACHE_LINE_SIZE - 1)) == 0)

// Convenience macros
#ifdef DEBUG_MEM
#define debug_print(fmt, ...)                                \
  do {                                                       \
    if (FPGA_DMA_DEBUG) {                                    \
      fprintf(stderr, "%s (%d) : ", __FUNCTION__, __LINE__); \
      fprintf(stderr, fmt, ##__VA_ARGS__);                   \
    }                                                        \
  } while (0)

#define error_print(fmt, ...)                              \
  do {                                                     \
    fprintf(stderr, "%s (%d) : ", __FUNCTION__, __LINE__); \
    fprintf(stderr, fmt, ##__VA_ARGS__);                   \
    err_cnt++;                                             \
  } while (0)
#else
#define debug_print(...)
#define error_print(...)
#endif

typedef void *(*memcpy_fn_t)(void *dst, size_t max, const void *src, size_t len);

extern memcpy_fn_t p_memcpy;

#define memcpy_s_fast(a, b, c, d) p_memcpy(a, b, c, d)

#ifdef __cplusplus
}
#endif  // __cplusplus

#endif  // MEMCPY_S_FAST_H
