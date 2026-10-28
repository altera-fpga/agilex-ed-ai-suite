//
// spatial_config.h - Configuration file for defining constants
// Default model configuration (configurable per design)
//
#ifndef SPATIAL_CONFIG_H
#define SPATIAL_CONFIG_H

// Port geometry (data width, lanes, subvectors) is no longer a compile-time
// constant here. It is loaded at runtime into g_spatial_port_config; include
// spatial_port_config.h for the INPUT_/OUTPUT_ geometry macros.
//
// MMIO CSR Offset Mapping in HW
//
// READ
#define CSR_AFU_INFO 5
#define CSR_WEIGHTS_PROCESSED 6
#define CSR_READ_REQUESTS_PENDING 7
// WRITE
#define CSR_IP_RESET 1
#define CSR_SET_READ_BURST_LEN 2
#define CSR_SET_SRC_ADDRESS 3
#define CSR_SET_DEST_ADDRESS 4
#define CSR_SET_WRITE_BURST_LEN 5
#define CSR_SET_WRITE_ADDRESS 6
#define CSR_SET_CMPL_ADDRESS 7
//
// IP Values
//
#define IP_RESET_TRUE 1
#define IP_RESET_FALSE 0

// Destination selector written to CSR_SET_DEST_ADDRESS to route reads to the
// spatial IP (as opposed to a DDR bank) when kicking off inference.
#define CSR_DEST_SPATIAL_IP 15

//
// Burst lengths
//
#define MAX_BURST_SIZE (1 << 12) // Max 4KB pages

#define HOST_BUS_NUM_BYTES 64

// Largest host buffer used for a single weight transfer; larger weight blobs
// are partitioned into chunks of this size.
#define MAX_HOST_MEM_SIZE (1 << 21)
// Benchmarking Configuration
//
#define BENCHMARK_CPU_SPEED 2.101
#define BENCHMARK_RUNTIME_SECONDS 30
#define BENCHMARK_SIM_RUNTIME_SECONDS 300

#endif // SPATIAL_CONFIG_H
