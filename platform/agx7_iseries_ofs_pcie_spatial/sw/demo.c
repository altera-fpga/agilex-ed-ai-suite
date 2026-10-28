// Copyright 2025 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>        // for sysconf()
#include <inttypes.h>    // for PRIu64/PRIx64
#include <uuid/uuid.h>
#include <time.h>
// OPAE API
#include <opae/fpga.h>
// Project Headers
#include "config.h"

#include <math.h>

//
//  Global Variables 
//
typedef struct
{
    volatile char *ptr;
    uint64_t wsid;
    uint64_t pa;
    size_t size;
}
t_pinned_buffer;
//
typedef struct 
{
    t_pinned_buffer *buffers;
    uint32_t num_buffers;
    size_t total_size;
    size_t chunk_size;
} t_buffer_group;
//
typedef struct {
    uint32_t burst_size;      // Size of this burst in bytes
    uint64_t physical_addr;   // Physical address for this burst
    uint32_t buffer_index;    // Which buffer this burst targets
    uint64_t buffer_offset;   // Offset within that buffer
} t_buffer_burst;
//
static fpga_handle s_accel_handle;
static bool s_is_ase_sim;
static volatile uint64_t *s_mmio_buf;
//
#define BUFFER_SIZE_4KB (4 * 1024)

//
// Allocate a single buffer in I/O memory, shared with the FPGA.
//
static volatile void* alloc_buffer(fpga_handle accel_handle,
                                   ssize_t size,
                                   uint64_t *wsid,
                                   uint64_t *io_addr)
{
    fpga_result r;
    volatile void* buf;
    // Create the single buffer
    r = fpgaPrepareBuffer(accel_handle, size, (void*)&buf, wsid, 0);
    if (FPGA_OK != r) {
        fprintf(stderr, "fpgaPrepareBuffer failed for size %ld: %s\n", 
                size, fpgaErrStr(r));
        return NULL;
    }
    
    // Get the physical address of the buffer in the accelerator
    r = fpgaGetIOAddress(accel_handle, *wsid, io_addr);
    if (FPGA_OK != r) {
        fprintf(stderr, "fpgaGetIOAddress failed: %s\n", fpgaErrStr(r));
        fpgaReleaseBuffer(accel_handle, *wsid);
        return NULL;
    }
    
    return buf;
}

//
// Get buffer information for FPGA operations
// Returns the first buffer's info (for simple cases)
//
static int get_buffer_info(const t_buffer_group *group, uint64_t *wsid, uint64_t *pa, volatile void **ptr)
{
    if (!group || group->num_buffers == 0) {
        return -1;
    }
    
    if (wsid) *wsid = group->buffers[0].wsid;
    if (pa) *pa = group->buffers[0].pa;
    if (ptr) *ptr = (volatile void*)group->buffers[0].ptr;
    
    return 0;
}

// Returns the maximum buffer size (in bytes) fpgaPrepareBuffer can allocate,
// and logs the first‐failing size.
size_t find_max_buffer_size(fpga_handle accel_handle)
{
    long page = sysconf(_SC_PAGESIZE);
    void *buf = NULL;
    uint64_t wsid, io_addr;
    fpga_result r;
    size_t n = 1;

    for (;; ++n) {
        size_t size = n * page;
        r = fpgaPrepareBuffer(accel_handle, size, &buf, &wsid, /*flags=*/0);
        if (r != FPGA_OK) {
            fprintf(stderr,
                    "[DBG] fpgaPrepareBuffer failed at %zu bytes (%zu pages): %s (%d)\n",
                    size, n, fpgaErrStr(r), r);
            break;
        }
        // clean up before next iteration
        fpgaReleaseBuffer(accel_handle, wsid);
    }

    size_t max_ok = (n - 1) * page;
    fprintf(stderr,
            "[DBG] Maximum successful size = %zu bytes (%zu pages)\n",
            max_ok, n - 1);
    return max_ok;
}

//
// Read a 64 bit CSR. When a pointer to CSR buffer is available, read directly.
// Direct reads can be significantly faster.
//
static inline uint64_t readMMIO64(uint32_t idx)
{
    if (s_mmio_buf)
    {
        return s_mmio_buf[idx];
    }
    else
    {
        fpga_result r;
        uint64_t v;
        r = fpgaReadMMIO64(s_accel_handle, 0, 8 * idx, &v);
        assert(FPGA_OK == r);
        return v;
    }
}

//
// Write a 64 bit CSR. When a pointer to CSR buffer is available, write directly.
//
static inline void writeMMIO64(uint32_t idx, uint64_t v)
{
    if (s_mmio_buf)
    {
        s_mmio_buf[idx] = v;
    }
    else
    {
        fpgaWriteMMIO64(s_accel_handle, 0, 8 * idx, v);
    }
}

//
// Function for collecting clock cycles 
//
static inline uint64_t get_rdtscp() {
    uint32_t lo, hi;
    uint32_t aux; // Will contain the processor ID, unused in this implementation
    
    // Read time-stamp counter and processor ID with serialization
    __asm__ __volatile__("rdtscp" : "=a" (lo), "=d" (hi), "=c" (aux));
    // lfence instruction after reading to prevent instruction reordering
    __asm__ __volatile__("lfence" ::: "memory");
    
    return ((uint64_t)hi << 32) | lo;
}

//THIS FUNCTION ASSUMES INPUT_DATA IS CLEAN. (0s IN UNUSED BITS)
void pack_data(
    const uint64_t *input_data,
    uint64_t *packed_input
)
{
    unsigned input_index = 0;
    unsigned word_index;
    unsigned sub_vectors_per_bus = HOST_BUS_NUM_BYTES*8 / (INPUT_DATA_WIDTH * INPUT_LANES);
    unsigned skip_bits = 0;

    for(int input_index = 0; input_index < INPUT_SUBVECTORS * INPUT_LANES; input_index++){
        //We're working with 64 bit granularity. Need to be careful when hitting bus boundaries
        int lane = input_index % INPUT_LANES;
        int subvector = (input_index / INPUT_LANES) + 1; //not 0 indexed

        //This is a bus boundary. Pad the rest of the bits to move onto the next 64 bit word
        if(subvector % sub_vectors_per_bus == 1 && lane == 0 && subvector != 1) {
            skip_bits += HOST_BUS_NUM_BYTES*8 - (INPUT_DATA_WIDTH * INPUT_LANES * sub_vectors_per_bus);
        }

        unsigned bit_offset = (INPUT_DATA_WIDTH*input_index + skip_bits) % 64;
        word_index = (INPUT_DATA_WIDTH*(input_index) + skip_bits) / 64;
        uint64_t bus_mask = ((1ULL << INPUT_DATA_WIDTH) - 1) << bit_offset;
            
        packed_input[word_index] &= ~bus_mask; // Clear existing bits
        packed_input[word_index] |= (input_data[input_index]) << (bit_offset);

        // printf("[pack_data] word_index: %d \n", word_index);
        // printf("[pack_data] bit_offset: %d \n", bit_offset);
        // printf("[pack_data] bus_mask: %lx \n", bus_mask);
        // printf("[pack_data] input_data[%d]: %lx \n", input_index, input_data[input_index]);
        // printf("[pack_data] packed_input: %lx \n", packed_input[word_index]);

        if(bit_offset + INPUT_DATA_WIDTH > 64){
            //Spills over into next word
            unsigned spillover_bits = (bit_offset + INPUT_DATA_WIDTH) - 64;
            uint64_t spillover_mask = (1ULL << spillover_bits) - 1;
            packed_input[word_index + 1] &= ~spillover_mask; 
            packed_input[word_index + 1] |= (input_data[input_index] >> (INPUT_DATA_WIDTH - spillover_bits));
        }
        
        // If only one sub_vector can fit in a bus then we've used up all useful bits from HOST_BUS_NUM_BYTES
        if(lane == INPUT_LANES -1 && sub_vectors_per_bus == 1){
            skip_bits += HOST_BUS_NUM_BYTES*8 - (INPUT_DATA_WIDTH * INPUT_LANES * sub_vectors_per_bus);
        }
        
    }
}


void validate_packing(
    const uint64_t *packed_input,
    uint64_t *input_data
)
{
    unsigned input_index = 0;
    unsigned word_index;
    unsigned sub_vectors_per_bus = HOST_BUS_NUM_BYTES*8 / (INPUT_DATA_WIDTH * INPUT_LANES);
    unsigned skip_bits = 0;
    for(int input_index = 0; input_index < INPUT_SUBVECTORS * INPUT_LANES; input_index++){
        int lane = input_index % INPUT_LANES;
        int subvector = (input_index / INPUT_LANES) + 1; //not 0 indexed                    
        //This is a bus boundary. Ignore the rest of the bits and move onto the next 64 bit word
        if(subvector % sub_vectors_per_bus == 1 && lane == 0 && subvector != 1) {
            skip_bits += HOST_BUS_NUM_BYTES*8 - (INPUT_DATA_WIDTH * INPUT_LANES * sub_vectors_per_bus);
        }

        unsigned bit_offset = (INPUT_DATA_WIDTH*input_index + skip_bits) % 64;
        word_index = (INPUT_DATA_WIDTH*(input_index) + skip_bits) / 64;
        uint64_t bus_mask = ((1ULL << INPUT_DATA_WIDTH) - 1) << bit_offset;
            
        input_data[input_index] = (packed_input[word_index] & bus_mask) >> bit_offset;

        // printf("[unpack_data] word_index: %d \n", word_index);
        // printf("[unpack_data] bit_offset: %d \n", bit_offset);
        // printf("[unpack_data] bus_mask: %lx \n", bus_mask);
        // printf("[unpack_data] packed_output: %lx \n", packed_output[word_index]);
        // printf("[unpack_data] output_data[%d]: %lx \n", output_index, output_data[output_index]);

        if(bit_offset + INPUT_DATA_WIDTH > 64){
            //Spills over into next word
            unsigned spillover_bits = (bit_offset + INPUT_DATA_WIDTH) - 64;
            uint64_t spillover_mask = (1ULL << spillover_bits) - 1;
            input_data[input_index] |= (packed_input[word_index + 1] & spillover_mask) << (INPUT_DATA_WIDTH - spillover_bits);
        }
        
        // If only one sub_vector can fit in a bus then we've used up all useful bits from HOST_BUS_NUM_BYTES
        if(lane == INPUT_LANES -1 && sub_vectors_per_bus == 1){
            skip_bits += HOST_BUS_NUM_BYTES*8 - (INPUT_DATA_WIDTH * INPUT_LANES * sub_vectors_per_bus);
        }
        
    }
}

void unpack_data(
    const uint64_t *packed_output,
    uint64_t *output_data
)
{
    unsigned output_index = 0;
    unsigned word_index;
    unsigned sub_vectors_per_bus = HOST_BUS_NUM_BYTES*8 / (OUTPUT_DATA_WIDTH * OUTPUT_LANES);
    unsigned skip_bits = 0;
    for(int output_index = 0; output_index < OUTPUT_SUBVECTORS * OUTPUT_LANES; output_index++){
        int lane = output_index % OUTPUT_LANES;
        int subvector = (output_index / OUTPUT_LANES) + 1; //not 0 indexed

        //This is a bus boundary. Ignore the rest of the bits and move onto the next 64 bit word
        if(subvector % sub_vectors_per_bus == 1 && lane == 0 && subvector != 1) {
            skip_bits += HOST_BUS_NUM_BYTES*8 - (OUTPUT_DATA_WIDTH * OUTPUT_LANES * sub_vectors_per_bus);
        }

        unsigned bit_offset = (OUTPUT_DATA_WIDTH*output_index + skip_bits) % 64;
        word_index = (OUTPUT_DATA_WIDTH*(output_index) + skip_bits) / 64;
        uint64_t bus_mask = ((1ULL << OUTPUT_DATA_WIDTH) - 1) << bit_offset;
            
        output_data[output_index] = (packed_output[word_index] & bus_mask) >> bit_offset;

        // printf("[unpack_data] word_index: %d \n", word_index);
        // printf("[unpack_data] bit_offset: %d \n", bit_offset);
        // printf("[unpack_data] bus_mask: %lx \n", bus_mask);
        // printf("[unpack_data] packed_output: %lx \n", packed_output[word_index]);
        // printf("[unpack_data] output_data[%d]: %lx \n", output_index, output_data[output_index]);

        if(bit_offset + OUTPUT_DATA_WIDTH > 64){
            //Spills over into next word
            unsigned spillover_bits = (bit_offset + OUTPUT_DATA_WIDTH) - 64;
            uint64_t spillover_mask = (1ULL << spillover_bits) - 1;
            output_data[output_index] |= (packed_output[word_index + 1] & spillover_mask) << (OUTPUT_DATA_WIDTH - spillover_bits);
        }
        
        // If only one sub_vector can fit in a bus then we've used up all useful bits from HOST_BUS_NUM_BYTES
        if(lane == OUTPUT_LANES -1 && sub_vectors_per_bus == 1){
            skip_bits += HOST_BUS_NUM_BYTES*8 - (OUTPUT_DATA_WIDTH * OUTPUT_LANES * sub_vectors_per_bus);
        }
        
    }
}

// For now we are going to have serperate functions for inference, single inference Im starting off by now using buffer groups, 
// but in future I want to look at a consolidating this code
//
// Calculate total requests needed for single buffer (simplified version)
// @param data_size Total data size
// @param max_burst_size Maximum burst size (power of 2)
// @param host_bus_size_bytes Bus width in bytes
// @return Number of requests needed, or -1 on error
//
static int calculate_total_requests_needed_simple(
    size_t data_size,
    uint32_t max_burst_size
) {
    if (data_size == 0 || max_burst_size == 0 || HOST_BUS_NUM_BYTES == 0) {
        return -1;
    }
    
    if ((max_burst_size & (max_burst_size - 1)) != 0) {
        printf("Error: max_burst_size (%u) is not a power of 2\n", max_burst_size);
        return -1;
    }
    
    if (data_size % HOST_BUS_NUM_BYTES != 0) {
        printf("Error: data_size (%ld) not aligned to bus width (%u)\n", 
               data_size, HOST_BUS_NUM_BYTES);
        return -1;
    }
    
    int total_requests = 0;
    size_t remaining = data_size;
    
    while (remaining > 0) {
        if(remaining > max_burst_size){
            remaining -= max_burst_size;
            total_requests++;

        }
        else{
            remaining = 0;
            total_requests++;
        }
    }
    
    return total_requests;
}

//
// Calculate burst breakdown for single buffer (simplified version)
// @param data_size Total data size  
// @param max_burst_size Maximum burst size (power of 2)
// @param host_bus_size_bytes Bus width in bytes
// @param burst_sizes Output array for burst sizes
// @param address_offsets Output array for address offsets
// @param axi_burst_len Output array for AXI burst lengths
// @param expected_bursts Expected number of bursts (for validation)
// @return Number of bursts calculated, or -1 on error
//
static int calculate_burst_breakdown_simple(
    size_t data_size,
    uint32_t max_burst_size,
    uint32_t *burst_sizes,
    uint64_t *address_offsets,
    uint8_t *axi_burst_len,
    int expected_bursts
) {
    if (!burst_sizes || !address_offsets || !axi_burst_len || expected_bursts <= 0) {
        return -1;
    }
    
    if (data_size % HOST_BUS_NUM_BYTES != 0) {
        printf("Error: data_size (%ld) not aligned to bus width (%u)\n", 
               data_size, HOST_BUS_NUM_BYTES);
        return -1;
    }
    
    int burst_count = 0;
    size_t remaining = data_size;
    size_t current_offset = 0;
    
    while (remaining > 0) {
        // Find optimal burst size
        uint32_t burst_size = remaining;
        if(burst_size > max_burst_size){
            burst_size = max_burst_size;
        }
        
        // Record burst info
        burst_sizes[burst_count] = burst_size;
        address_offsets[burst_count] = current_offset;
        
        // Convert to AXI burst length
        uint32_t num_transfers = burst_size / HOST_BUS_NUM_BYTES;
        if (num_transfers == 0 || num_transfers > 256) {
            printf("Error: Invalid number of transfers: %u\n", num_transfers);
            return -1;
        }
        axi_burst_len[burst_count] = (uint8_t)(num_transfers - 1);
        
        // Update counters
        current_offset += burst_size;
        remaining -= burst_size;
        burst_count++;
    }
    
    // Verify complete processing
    if (remaining > 0) {
        printf("Error: %ld bytes of data could not be processed\n", remaining);
        return -1;
    }
    
    if (burst_count != expected_bursts) {
        printf("Error: Calculated %d bursts, expected %d\n", burst_count, expected_bursts);
        return -1;
    }
    
    return burst_count;
}

//
// Helper function to allocate and calculate burst metadata
// @param data_size Total data size
// @param max_burst_size Maximum burst size (power of 2)
// @param expected_bursts Expected number of bursts
// @param burst_sizes_out Pointer to burst sizes array (will be allocated)
// @param axi_burst_len_out Pointer to AXI burst length array (will be allocated)
// @param address_offsets_out Pointer to address offsets array (will be allocated)
// @param verbose Enable verbose output
// @param label Label for debug messages (e.g., "Input" or "Output")
// @return Number of bursts calculated, or -1 on error
//
static int allocate_and_calculate_bursts(
    size_t data_size,
    uint32_t max_burst_size,
    int expected_bursts,
    uint32_t **burst_sizes_out,
    uint8_t **axi_burst_len_out,
    uint64_t **address_offsets_out,
    bool verbose,
    const char *label
) {
    // Allocate arrays
    *burst_sizes_out = malloc(expected_bursts * sizeof(uint32_t));
    *axi_burst_len_out = malloc(expected_bursts * sizeof(uint8_t));
    *address_offsets_out = malloc(expected_bursts * sizeof(uint64_t));
    
    if (!*burst_sizes_out || !*axi_burst_len_out || !*address_offsets_out) {
        printf("[allocate_and_calculate_bursts] Error allocating %s burst metadata for %d requests\n", 
               label, expected_bursts);
        free(*burst_sizes_out);
        free(*axi_burst_len_out);
        free(*address_offsets_out);
        *burst_sizes_out = NULL;
        *axi_burst_len_out = NULL;
        *address_offsets_out = NULL;
        return -1;
    }

    // Calculate burst breakdown
    int num_bursts = calculate_burst_breakdown_simple(
        data_size,
        max_burst_size,
        *burst_sizes_out,
        *address_offsets_out,
        *axi_burst_len_out,
        expected_bursts
    );

    if (num_bursts != expected_bursts) {
        printf("[allocate_and_calculate_bursts] Error: %s burst calculation mismatch (%d vs %d)\n",
               label, num_bursts, expected_bursts);
        free(*burst_sizes_out);
        free(*axi_burst_len_out);
        free(*address_offsets_out);
        *burst_sizes_out = NULL;
        *axi_burst_len_out = NULL;
        *address_offsets_out = NULL;
        return -1;
    }

    if (verbose) {
        printf("[allocate_and_calculate_bursts] %s burst breakdown (%d bursts):\n", label, num_bursts);
        for (int i = 0; i < num_bursts; i++) {
            printf("  - Burst %d: %u bytes, offset=0x%lx, AXI len=%u\n",
                   i, (*burst_sizes_out)[i], (*address_offsets_out)[i], (*axi_burst_len_out)[i]);
        }
    }

    return num_bursts;
}

long min(long a, long b){
    return a < b? a : b;
}

long max(long a, long b){
    return a > b? a : b;
}

//
// Function to reset FPGA IP
//
int reset(
    fpga_handle accel_handle,
    bool is_ase_sim,
    bool verbose
)
{
    if (verbose) printf("[reset] Entered function\n");

    s_accel_handle = accel_handle;
    s_is_ase_sim = is_ase_sim;

    if (!is_ase_sim) {
        if (verbose) printf("[reset] Mapping MMIO...\n");
        uint64_t *tmp_ptr;
        fpga_result r = fpgaMapMMIO(accel_handle, 0, &tmp_ptr);
        if (r != FPGA_OK) {
            printf("[reset] Error: fpgaMapMMIO failed\n");
            return -1;
        }
        s_mmio_buf = tmp_ptr;
    } else {
        if (verbose) printf("[reset] Running in ASE sim mode — MMIO not mapped\n");
        s_mmio_buf = NULL;
    }

    // Reset hardware
    if (verbose) printf("[reset] Resetting SPARK Engine...\n");
    writeMMIO64(CSR_IP_RESET, IP_RESET_TRUE );
    writeMMIO64(CSR_IP_RESET, IP_RESET_FALSE);

    return 0;
}


//
// Function to reset FPGA IP
//
int load_weights(
    fpga_handle accel_handle,
    bool is_ase_sim,
    const uint64_t *weights_data,
    size_t weights_bytes,
    uint64_t start_addr,
    uint64_t bank_number,
    bool verbose
){
    if (verbose) printf("[load_weights] Entered function\n");
    if(weights_bytes > MAX_HOST_MEM_SIZE){
        unsigned partitions = 0;
        long offset = 0;
        while(offset < weights_bytes){
            if(load_weights(
                accel_handle,
                is_ase_sim,
                &weights_data[offset/sizeof(uint64_t)], //Assuming 8 bytes per value (uint64_t)
                min(weights_bytes-offset, MAX_HOST_MEM_SIZE),
                start_addr + offset,
                bank_number,
                verbose
            )){
                return 1;
            }
            offset += MAX_HOST_MEM_SIZE;
        }
        return 0;
    }

    s_accel_handle = accel_handle;
    s_is_ase_sim = is_ase_sim;

    if (!is_ase_sim) {
        if (verbose) printf("[load_weights] Mapping MMIO...\n");
        uint64_t *tmp_ptr;
        fpga_result r = fpgaMapMMIO(accel_handle, 0, &tmp_ptr);
        if (r != FPGA_OK) {
            printf("[load_weights] Error: fpgaMapMMIO failed\n");
            return -1;
        }
        s_mmio_buf = tmp_ptr;
    } else {
        if (verbose) printf("[load_weights] Running in ASE sim mode — MMIO not mapped\n");
        s_mmio_buf = NULL;
    }

    // Loading weights
    if (verbose) printf("[load_weights] Loading weights...\n");
    volatile uint64_t *weights_buf;
    uint64_t weights_pa, weights_wsid;
    uint32_t *weights_burst_sizes = NULL;
    uint8_t  *weights_axi_burst_len = NULL;
    uint64_t *weights_address_offsets = NULL;
    
    int total_weights_requests = calculate_total_requests_needed_simple(
        weights_bytes, 
        MAX_BURST_SIZE    
    );

    int weights_num_bursts = allocate_and_calculate_bursts(
        weights_bytes,
        MAX_BURST_SIZE,
        total_weights_requests,
        &weights_burst_sizes,
        &weights_axi_burst_len,
        &weights_address_offsets,
        verbose,
        "Weights"
    );

    //weights buffer
    if (verbose) printf("[load_weights] Allocating weights buffer...\n");
    weights_buf = (volatile uint64_t*)alloc_buffer(accel_handle, weights_bytes, &weights_wsid, &weights_pa);
    if (!weights_buf) {
        printf("[load_weights] Error: weights buffer allocation failed\n");
        return -1;
    }

    int current_index = 0;
    for (int i = 0; i < weights_bytes/sizeof(uint64_t); i++) {
        weights_buf[i] = weights_data[i];
    }

    if (verbose) printf("[load_weights] Starting ddr write bursts...\n");
    uint16_t current_read_len = 0;
    for (int i = 0; i < weights_num_bursts; i++) {
        // Update read burst length if changed
        while(readMMIO64(CSR_READ_REQUESTS_PENDING) > 250){
            if(verbose)
                printf("[load_weights] Stalling \n");
        }
        if (weights_axi_burst_len[i] != current_read_len) {
            writeMMIO64(CSR_SET_READ_BURST_LEN, weights_axi_burst_len[i]);
            current_read_len = weights_axi_burst_len[i];
        }

        if (verbose) {
            printf("  - DDR write burst %d: src=0x%lx, dst=0x%lx, size=%u bytes, AXI len=%u\n", 
                i, weights_pa + weights_address_offsets[i], start_addr + weights_address_offsets[i], weights_burst_sizes[i], weights_axi_burst_len[i]);
        }
        
        writeMMIO64(CSR_SET_DEST_ADDRESS, start_addr + weights_address_offsets[i] + bank_number);
        writeMMIO64(CSR_SET_SRC_ADDRESS, weights_pa + weights_address_offsets[i]);
    }

    while(readMMIO64(CSR_WEIGHTS_PROCESSED) == 0){
    }

    fpgaReleaseBuffer(accel_handle, weights_wsid);
    free(weights_burst_sizes);
    free(weights_axi_burst_len);
    free(weights_address_offsets);

    return 0;
}

//
// Function for running inference on input array with burst management
//
int run_inference(
    fpga_handle accel_handle,
    bool is_ase_sim,
    const uint64_t *input_data,
    size_t input_packets,
    uint64_t *output_data,
    size_t output_packets,
    bool verbose
)
{
    if (verbose) printf("[run_inference] Entered function\n");

    s_accel_handle = accel_handle;
    s_is_ase_sim = is_ase_sim;

    if (!is_ase_sim) {
        if (verbose) printf("[run_inference] Mapping MMIO...\n");
        uint64_t *tmp_ptr;
        fpga_result r = fpgaMapMMIO(accel_handle, 0, &tmp_ptr);
        if (r != FPGA_OK) {
            printf("[run_inference] Error: fpgaMapMMIO failed\n");
            return -1;
        }
        s_mmio_buf = tmp_ptr;
    } else {
        if (verbose) printf("[run_inference] Running in ASE sim mode — MMIO not mapped\n");
        s_mmio_buf = NULL;
    }

    // Calculate input and output sizes with padding to 64 byte aligned words
    int input_bus_transactions_per_packet = ceil((float)(INPUT_SUBVECTORS)/(HOST_BUS_NUM_BYTES*8/(INPUT_DATA_WIDTH * INPUT_LANES)));
    int output_bus_transactions_per_packet = ceil((float)(OUTPUT_SUBVECTORS)/(HOST_BUS_NUM_BYTES*8/(OUTPUT_DATA_WIDTH * OUTPUT_LANES)));

    size_t input_bytes =  HOST_BUS_NUM_BYTES * input_bus_transactions_per_packet * input_packets;
    size_t output_bytes = HOST_BUS_NUM_BYTES * output_bus_transactions_per_packet * output_packets;
 
    if (verbose) {
        printf("[run_inference] Input size: %zu bytes (%zu packets)\n", input_bytes, input_packets);
        printf("[run_inference] Output size: %zu bytes (%zu packets)\n", output_bytes, output_packets);
    }

    uint64_t* packed_input = (uint64_t*)malloc(input_bytes);
    for(int packet = 0; packet < input_packets; packet++) {
        pack_data(&input_data[packet * INPUT_SUBVECTORS * INPUT_LANES], 
                  &packed_input[packet * input_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t)]);
        // printf("[run_inference] packed_input index: %d \n", packet * input_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t));
    }

    uint64_t validate_data[input_packets* INPUT_SUBVECTORS * INPUT_LANES];
    for(int i = 0; i < input_packets; i++){
        validate_packing(
            &packed_input[i * input_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t)],
            (uint64_t*)&validate_data[i * INPUT_SUBVECTORS * INPUT_LANES]
        );
        // printf("[run_inference] bustransactions per packet: %d %d words per bus \n", input_bus_transactions_per_packet, (HOST_BUS_NUM_BYTES)/sizeof(uint64_t));
        // for(int j = 0; j < input_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t); j++){
        //     printf("[run_inference] packed_input[%d]: %lx\n", 
        //            i * input_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t) + j,
        //            packed_input[i * input_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t) + j]);
        // }
    }
    
    for(int i = 0; i < input_packets * INPUT_SUBVECTORS * INPUT_LANES; i++){
        if(input_data[i] != validate_data[i]){
            printf("[run_inference] Error: Data packing/unpacking mismatch at index %d: original=%lx, unpacked=%lx\n",
                   i, input_data[i], validate_data[i]);
        }
        // printf("[run_inference] validate_data[%d]: %lx, %lx\n", i, input_data[i], validate_data[i]);
    }

    // for(int i = 0; i < input_bytes/HOST_BUS_NUM_BYTES; i++) {
    //     if (verbose) {
    //         printf("[run_inference] Packed input bus word %d: ", i);
    //         for(int j = HOST_BUS_NUM_BYTES/sizeof(uint64_t) - 1; j >= 0 ; j--)
    //             printf("%016lx", packed_input[i * (HOST_BUS_NUM_BYTES/sizeof(uint64_t)) + j]);
    //         printf("\n");
    //     }
    // }
    // free(packed_input);
    // return 1;

    // Read AFU Info
    // uint64_t v = readMMIO64(CSR_AFU_INFO);
    const uint16_t max_reqs_in_flight = 256;
    const uint16_t max_burst_size = MAX_BURST_SIZE;

    if (verbose) {
        printf("[run_inference] AFU info:\n");
        printf("  - Max burst size: %u bytes\n", max_burst_size);
        printf("  - Max inflight reqs: %u\n", max_reqs_in_flight);
    }

    // Calculate total number of requests needed for input
    int total_input_requests = calculate_total_requests_needed_simple(
        input_bytes, 
        max_burst_size    
    );
    
    if (total_input_requests <= 0) {
        printf("[run_inference] Error: failed to calculate input request count\n");
        return -1;
    }

    if (total_input_requests > max_reqs_in_flight) {
        printf("[run_inference] Error: Input requires %d requests, but max allowed is %u\n",
               total_input_requests, max_reqs_in_flight);
        printf("[run_inference] Consider reducing input size or using load_weights for large transfers\n");
        return -1;
    }

    if (verbose) {
        printf("[run_inference] Input requests needed: %d (within limit of %u)\n", 
               total_input_requests, max_reqs_in_flight);
    }

    // Allocate and calculate input burst metadata
    uint32_t *input_burst_sizes = NULL;
    uint8_t  *input_axi_burst_len = NULL;
    uint64_t *input_address_offsets = NULL;
    
    int input_num_bursts = allocate_and_calculate_bursts(
        input_bytes,
        max_burst_size,
        total_input_requests,
        &input_burst_sizes,
        &input_axi_burst_len,
        &input_address_offsets,
        verbose,
        "Input"
    );
    
    if (input_num_bursts != total_input_requests) {
        printf("[run_inference] Error: input burst calculation failed\n");
        free(input_burst_sizes); free(input_axi_burst_len); free(input_address_offsets);
        return -1;
    }

    // Calculate total number of requests needed for output
    int total_output_requests = calculate_total_requests_needed_simple(
        output_bytes,
        max_burst_size
    );
    
    if (total_output_requests <= 0) {
        printf("[run_inference] Error: failed to calculate output request count\n");
        free(input_burst_sizes); free(input_axi_burst_len); free(input_address_offsets);
        return -1;
    }

    if (total_output_requests > max_reqs_in_flight) {
        printf("[run_inference] Error: Output requires %d requests, but max allowed is %u\n",
               total_output_requests, max_reqs_in_flight);
        free(input_burst_sizes); free(input_axi_burst_len); free(input_address_offsets);
        return -1;
    }

    if (verbose) {
        printf("[run_inference] Output requests needed: %d (within limit of %u)\n",
               total_output_requests, max_reqs_in_flight);
    }

    // Allocate and calculate output burst metadata
    uint32_t *output_burst_sizes = NULL;
    uint8_t  *output_axi_burst_len = NULL;
    uint64_t *output_address_offsets = NULL;
    
    int output_num_bursts = allocate_and_calculate_bursts(
        output_bytes,
        max_burst_size,
        total_output_requests,
        &output_burst_sizes,
        &output_axi_burst_len,
        &output_address_offsets,
        verbose,
        "Output"
    );
    
    if (output_num_bursts != total_output_requests) {
        printf("[run_inference] Error: output burst calculation failed\n");
        free(input_burst_sizes); free(input_axi_burst_len); free(input_address_offsets);
        free(output_burst_sizes); free(output_axi_burst_len); free(output_address_offsets);
        return -1;
    }

    // Allocate single buffers (efficient for small data)
    volatile uint64_t *src_buf;
    volatile uint64_t *dst_buf;
    volatile uint64_t *cmp_buf;
    uint64_t src_wsid, dst_wsid, cmp_wsid;
    uint64_t src_pa, dst_pa, cmp_pa;

    // Source buffer
    if (verbose) printf("[run_inference] Allocating source buffer...\n");
    src_buf = (volatile uint64_t*)alloc_buffer(accel_handle, input_bytes, &src_wsid, &src_pa);
    if (!src_buf) {
        printf("[run_inference] Error: source buffer allocation failed\n");
        free(input_burst_sizes); free(input_axi_burst_len); free(input_address_offsets);
        free(output_burst_sizes); free(output_axi_burst_len); free(output_address_offsets);
        return -1;
    }

    // Destination buffer
    if (verbose) printf("[run_inference] Allocating destination buffer...\n");
    dst_buf = (volatile uint64_t*)alloc_buffer(accel_handle, output_bytes, &dst_wsid, &dst_pa);
    if (!dst_buf) {
        printf("[run_inference] Error: destination buffer allocation failed\n");
        fpgaReleaseBuffer(accel_handle, src_wsid);
        free(input_burst_sizes); free(input_axi_burst_len); free(input_address_offsets);
        free(output_burst_sizes); free(output_axi_burst_len); free(output_address_offsets);
        return -1;
    }

    // Completion buffer
    if (verbose) printf("[run_inference] Allocating completion buffer...\n");
    cmp_buf = (volatile uint64_t*)alloc_buffer(accel_handle, 64, &cmp_wsid, &cmp_pa);
    if (!cmp_buf) {
        printf("[run_inference] Error: completion buffer allocation failed\n");
        fpgaReleaseBuffer(accel_handle, src_wsid);
        fpgaReleaseBuffer(accel_handle, dst_wsid);
        free(input_burst_sizes); free(input_axi_burst_len); free(input_address_offsets);
        free(output_burst_sizes); free(output_axi_burst_len); free(output_address_offsets);
        return -1;
    }

    // Copy input data
    if (verbose) printf("[run_inference] Copying input data...\n");
    // printf("[run_inference] input_bytes/(sizeof(uint64_t)/8) = %lx\n", input_bytes/(sizeof(uint64_t)/8));
    for (size_t i = 0; i < input_bytes/sizeof(uint64_t); ++i) {
        src_buf[i] = packed_input[i];
        // printf("[run_inference] src_buf[%zu] = %lx\n", i, src_buf[i]);
        // printf("[run_inference] packed[%zu] = %lx\n", i, packed_input[i]);
    }

    // Set up inference parameters
    writeMMIO64(CSR_SET_CMPL_ADDRESS, cmp_pa);
    cmp_buf[0] = 0;

    // Send all read and write burst requests
    if (verbose) {
        printf("[run_inference] Issuing %d read burst requests and %d write burst requests...\n", 
               input_num_bursts, output_num_bursts);
    }

    // Issue all the read requests
    uint8_t current_read_len = input_axi_burst_len[0];
    writeMMIO64(CSR_SET_READ_BURST_LEN, current_read_len);
    writeMMIO64(CSR_SET_DEST_ADDRESS, 15); // Selects spark IP as destination for reads
    if (verbose) printf("[run_inference] Starting read bursts...\n");
    for (int i = 0; i < input_num_bursts; i++) {
        // Update read burst length if changed
        if (input_axi_burst_len[i] != current_read_len) {
            writeMMIO64(CSR_SET_READ_BURST_LEN, input_axi_burst_len[i]);
            current_read_len = input_axi_burst_len[i];
        }
        
        if (verbose) {
            printf("  - Read burst %d: src=0x%lx, size=%u bytes, AXI len=%u\n", 
                i, src_pa + input_address_offsets[i], input_burst_sizes[i], input_axi_burst_len[i]);
        }
        
        writeMMIO64(CSR_SET_SRC_ADDRESS, src_pa + input_address_offsets[i]);
    }

    // Issue all the write requests
    uint8_t current_write_len = output_axi_burst_len[0];
    writeMMIO64(CSR_SET_WRITE_BURST_LEN, current_write_len);
    
    if (verbose) printf("[run_inference] Starting write bursts...\n");
    for (int i = 0; i < output_num_bursts; i++) {
        // Update write burst length if changed
        if (output_axi_burst_len[i] != current_write_len) {
            writeMMIO64(CSR_SET_WRITE_BURST_LEN, output_axi_burst_len[i]);
            current_write_len = output_axi_burst_len[i];
        }
        
        bool is_last_req = (i == output_num_bursts - 1);
        uint64_t current_dst_pa = dst_pa + output_address_offsets[i];
        
        if (verbose) {
            printf("  - Write burst %d: dst=0x%lx, size=%u bytes, AXI len=%u%s\n", 
                i, current_dst_pa, output_burst_sizes[i], output_axi_burst_len[i],
                is_last_req ? " (with completion)" : "");
        }
        
        if (is_last_req) {
            writeMMIO64(CSR_SET_WRITE_ADDRESS, current_dst_pa | 1);  // Last write with completion flag
        } else {
            writeMMIO64(CSR_SET_WRITE_ADDRESS, current_dst_pa);
        }
    }

    // Wait for completion
    if (verbose) printf("[run_inference] Waiting for inference to complete...\n");
    while (cmp_buf[0] == 0) {
        // Tight poll for small, fast operations
    }

    if (verbose) printf("[run_inference] Inference complete\n");

    // // Copy results back
    if (verbose) printf("[run_inference] Copying results...\n");
    uint64_t* packed_output = (uint64_t*)malloc(output_bytes);
    memcpy(packed_output, (const void *)(dst_buf), output_bytes);
    
    for(int packet = 0; packet < output_packets; packet++) {
        unpack_data(&packed_output[packet * output_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t)], 
                    &output_data[packet * OUTPUT_SUBVECTORS * OUTPUT_LANES]);
    }
    // for(int i = 0; i < output_packets * OUTPUT_SUBVECTORS * OUTPUT_LANES; i++) {
    //     if (verbose) {
    //         printf("[run_inference] Output data[%d]: %lx\n", i, output_data[i]);
    //     }
    // }


    // Cleanup
    fpgaReleaseBuffer(accel_handle, src_wsid);
    fpgaReleaseBuffer(accel_handle, dst_wsid);
    fpgaReleaseBuffer(accel_handle, cmp_wsid);
    free(input_burst_sizes);
    free(input_axi_burst_len);
    free(input_address_offsets);
    free(output_burst_sizes);
    free(output_axi_burst_len);
    free(output_address_offsets);
    free(packed_input);
    free(packed_output);

    if (verbose) printf("[run_inference] Done.\n");
    return 0;
}

