#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>       // for memcpy/strrchr/strncmp
#include <dirent.h>       // for directory scan
#include <assert.h>
#include <unistd.h>        // for sysconf()
#include <inttypes.h>    // for PRIu64/PRIx64
#include <uuid/uuid.h>
#include <time.h>
#include <cmath>
#include <vector>

// OPAE API
#include <opae/fpga.h>
// Project Headers
#include "mmd.h"
#include "fpga.h"
#include "spatial_config.h"        // CSR offsets, burst/host constants
#include "spatial_port_config.h"   // runtime port geometry (INPUT_/OUTPUT_ macros)
#include "spatial_debug.h"


// MMIO context - passed to read/write functions instead of using globals
typedef struct {
    fpga_handle handle;
    volatile uint64_t *buf;  // NULL in ASE sim mode (uses fpgaReadMMIO64/fpgaWriteMMIO64)
} mmio_ctx_t;

//
// Allocate a single buffer in host memory, shared with the FPGA.
//
static volatile void* alloc_buffer(fpga_handle accel_handle,
                                   ssize_t size,
                                   uint64_t *wsid,
                                   uint64_t *io_addr)
{
    fpga_result r;
    // fpgaPrepareBuffer takes void**; keep a non-volatile pointer for the API.
    void* buf = nullptr;
    r = fpgaPrepareBuffer(accel_handle, static_cast<uint64_t>(size), &buf, wsid, 0);
    if (FPGA_OK != r) {
        fprintf(stderr, "fpgaPrepareBuffer failed for size %ld: %s\n",
                static_cast<long>(size), fpgaErrStr(r));
        return NULL;
    }

    // Get the physical address of the buffer in the accelerator
    r = fpgaGetIOAddress(accel_handle, *wsid, io_addr);
    if (FPGA_OK != r) {
        fprintf(stderr, "fpgaGetIOAddress failed: %s\n", fpgaErrStr(r));
        fpgaReleaseBuffer(accel_handle, *wsid);
        return NULL;
    }

    return static_cast<volatile void*>(buf);
}

//
// Read a 64 bit CSR. When a pointer to CSR buffer is available, read directly.
// Direct reads can be significantly faster.
//
static inline uint64_t readMMIO64(const mmio_ctx_t *ctx, uint32_t idx)
{
    if (ctx->buf){
        return ctx->buf[idx];
    }
    else{
        fpga_result r;
        uint64_t v;
        r = fpgaReadMMIO64(ctx->handle, 0, 8 * idx, &v);
        assert(FPGA_OK == r);
        return v;
    }
}

//
// Write a 64 bit CSR. When a pointer to CSR buffer is available, write directly.
//
static inline void writeMMIO64(const mmio_ctx_t *ctx, uint32_t idx, uint64_t v)
{
    if (ctx->buf){
        ctx->buf[idx] = v;
    }
    else{
        fpgaWriteMMIO64(ctx->handle, 0, 8 * idx, v);
    }
}

// DMA burst schedule for a contiguous host buffer transfer.
struct BurstPlan {
    std::vector<uint32_t> sizes;
    std::vector<uint64_t> address_offsets;
    std::vector<uint8_t> axi_burst_len;
};

// Count, allocate, and fill burst metadata for a contiguous transfer.
// If max_reqs_in_flight > 0, fails when the burst count exceeds that limit.
static bool build_burst_plan(size_t data_size,
                             uint32_t max_burst_size,
                             BurstPlan& plan,
                             const char* label,
                             uint32_t max_reqs_in_flight = 0) {
    plan = BurstPlan{};

    if (data_size == 0 || max_burst_size == 0 || HOST_BUS_NUM_BYTES == 0) {
        fprintf(stderr, "[build_burst_plan] Error: invalid %s size/burst parameters\n", label);
        return false;
    }
    if ((max_burst_size & (max_burst_size - 1)) != 0) {
        fprintf(stderr, "[build_burst_plan] Error: max_burst_size (%u) is not a power of 2\n",
                max_burst_size);
        return false;
    }
    if (data_size % HOST_BUS_NUM_BYTES != 0) {
        fprintf(stderr, "[build_burst_plan] Error: %s data_size (%zu) not aligned to bus width (%u)\n",
                label, data_size, HOST_BUS_NUM_BYTES);
        return false;
    }

    size_t remaining = data_size;
    size_t current_offset = 0;
    while (remaining > 0) {
        const uint32_t burst_size =
            static_cast<uint32_t>(remaining > max_burst_size ? max_burst_size : remaining);
        const uint32_t num_transfers = burst_size / HOST_BUS_NUM_BYTES;
        if (num_transfers == 0 || num_transfers > 256) {
            fprintf(stderr, "[build_burst_plan] Error: invalid number of transfers: %u\n",
                    num_transfers);
            plan = BurstPlan{};
            return false;
        }
        plan.sizes.push_back(burst_size);
        plan.address_offsets.push_back(current_offset);
        plan.axi_burst_len.push_back(static_cast<uint8_t>(num_transfers - 1));
        current_offset += burst_size;
        remaining -= burst_size;
    }

    if (max_reqs_in_flight > 0 && plan.sizes.size() > max_reqs_in_flight) {
        fprintf(stderr, "[build_burst_plan] Error: %s requires %zu requests, but max allowed is %u\n",
                label, plan.sizes.size(), max_reqs_in_flight);
        plan = BurstPlan{};
        return false;
    }

    SPATIAL_DEBUG("[build_burst_plan] %s burst breakdown (%zu bursts):\n", label, plan.sizes.size());
    for (size_t i = 0; i < plan.sizes.size(); ++i) {
        SPATIAL_DEBUG("  - Burst %zu: %u bytes, offset=0x%lx, AXI len=%u\n", i, plan.sizes[i],
                      plan.address_offsets[i], plan.axi_burst_len[i]);
    }
    return true;
}


//
// Function to reset FPGA IP
//
int reset(void)
{
    SPATIAL_DEBUG("[reset] Entered function\n");

    fpga_handle accel_handle = spatial_fpga_handle();
    if (!accel_handle) {
        fprintf(stderr, "[reset] Error: no active FPGA session (call connect_to_fpga first)\n");
        return -1;
    }

    mmio_ctx_t mmio;
    mmio.handle = accel_handle;
    mmio.buf = NULL;

    SPATIAL_DEBUG("[reset] Mapping MMIO...\n");
    uint64_t *tmp_ptr;
    fpga_result r = fpgaMapMMIO(accel_handle, 0, &tmp_ptr);
    if (r != FPGA_OK) {
        fprintf(stderr, "[reset] Error: fpgaMapMMIO failed\n");
        return -1;
    }
    mmio.buf = tmp_ptr;

    // Reset hardware
    SPATIAL_DEBUG("[reset] Resetting SPATIAL Engine...\n");
    writeMMIO64(&mmio, CSR_IP_RESET, IP_RESET_TRUE );
    writeMMIO64(&mmio, CSR_IP_RESET, IP_RESET_FALSE);

    return 0;
}


//
// Load weights from a single binary file. The filename encodes the destination:
// weights_ddr_<bank_number>_<start_address>.bin
//
int load_weights_from_file(const char *filepath)
{
    const char *filename = strrchr(filepath, '/');
    filename = filename ? filename + 1 : filepath;

    uint64_t bank_number = 0;
    uint64_t start_addr = 0;
    if (sscanf(filename, "weights_ddr_%" SCNu64 "_%" SCNu64 ".bin", &bank_number, &start_addr) != 2) {
        fprintf(stderr, "[load_weights_from_file] Error: could not parse bank/start from %s\n", filename);
        return -1;
    }

    FILE *fp = fopen(filepath, "rb");
    if (!fp) {
        fprintf(stderr, "[load_weights_from_file] Error: could not open %s\n", filepath);
        return -1;
    }

    fseek(fp, 0, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    if (file_size <= 0) {
        fprintf(stderr, "[load_weights_from_file] Error: %s is empty or unreadable\n", filepath);
        fclose(fp);
        return -1;
    }

    size_t num_bytes = (size_t)file_size;
    size_t num_values = num_bytes / sizeof(uint64_t);

    uint64_t *weights_buffer = (uint64_t *)malloc(num_bytes);
    if (!weights_buffer) {
        fprintf(stderr, "[load_weights_from_file] Error: could not allocate weights buffer\n");
        fclose(fp);
        return -1;
    }

    size_t read_count = fread(weights_buffer, sizeof(uint64_t), num_values, fp);
    fclose(fp);

    if (read_count != num_values) {
        fprintf(stderr, "[load_weights_from_file] Error: expected %zu values but read %zu from %s\n",
                num_values, read_count, filepath);
        free(weights_buffer);
        return -1;
    }

    SPATIAL_DEBUG("[load_weights_from_file] %s: bank=%" PRIu64 ", start_addr=0x%" PRIx64 ", bytes=%zu\n",
                filepath, bank_number, start_addr, num_bytes);

    int result = load_weights_buffer(weights_buffer, num_bytes, start_addr, bank_number);

    free(weights_buffer);
    return result;
}

//
// Scan a directory for weights_ddr_*.bin files and load each of them.
//
int load_weights(const char *dir_path)
{
    DIR *dir = opendir(dir_path);
    if (!dir) {
        fprintf(stderr, "[load_weights] Error: could not open directory %s\n", dir_path);
        return -1;
    }

    SPATIAL_DEBUG("[load_weights] Scanning %s for weights_ddr .bin files...\n", dir_path);

    struct dirent *entry;
    int weights_loaded = 0;
    int result = 0;
    while ((entry = readdir(dir)) != NULL) {
        size_t name_len = strlen(entry->d_name);
        if (strncmp(entry->d_name, "weights_ddr", 11) == 0 &&
            name_len > 4 && strcmp(entry->d_name + name_len - 4, ".bin") == 0) {
            char filepath[512];
            snprintf(filepath, sizeof(filepath), "%s/%s", dir_path, entry->d_name);

            SPATIAL_DEBUG("[load_weights] Processing %s...\n", filepath);

            if (load_weights_from_file(filepath) != 0) {
                fprintf(stderr, "[load_weights] Failed to load weights from %s\n", filepath);
                result = -1;
                break;
            }
            weights_loaded++;
        }
    }

    closedir(dir);

    if (result != 0) {
        return result;
    }

    if (weights_loaded == 0) {
        fprintf(stderr, "[load_weights] Warning: no weights_ddr files found in %s\n", dir_path);
    } else {
        SPATIAL_DEBUG("[load_weights] Loaded weights from %d file(s)\n", weights_loaded);
    }

    return 0;
}

//
// Load a block of weights into device DDR. Blocks larger than MAX_HOST_MEM_SIZE
// are partitioned into chunks and loaded recursively.
//
int load_weights_buffer(
    const uint64_t *weights_data,
    size_t weights_bytes,
    uint64_t start_addr,
    uint64_t bank_number
)
{
    SPATIAL_DEBUG("[load_weights_buffer] Entered function\n");

    fpga_handle accel_handle = spatial_fpga_handle();
    if (!accel_handle) {
        fprintf(stderr, "[load_weights_buffer] Error: no active FPGA session (call connect_to_fpga first)\n");
        return -1;
    }

    // Partition transfers that exceed the host buffer limit
    if (weights_bytes > MAX_HOST_MEM_SIZE) {
        size_t offset = 0;
        while (offset < weights_bytes) {
            size_t chunk = weights_bytes - offset;
            if (chunk > MAX_HOST_MEM_SIZE) {
                chunk = MAX_HOST_MEM_SIZE;
            }
            if (load_weights_buffer(&weights_data[offset / sizeof(uint64_t)],
                             chunk,
                             start_addr + offset,
                             bank_number)) {
                return 1;
            }
            offset += MAX_HOST_MEM_SIZE;
        }
        return 0;
    }

    // Return code: -1 = error, 0 = success
    int result = -1;

    BurstPlan weights_bursts;
    volatile uint64_t *weights_buf = NULL;
    uint64_t weights_wsid = 0, weights_pa = 0;
    // Declared before any goto cleanup (C++ forbids jumping over init).
    uint16_t current_read_len = 0;

    // Initialize local MMIO context (no globals)
    mmio_ctx_t mmio;
    mmio.handle = accel_handle;
    mmio.buf = NULL;

    SPATIAL_DEBUG("[load_weights_buffer] Mapping MMIO...\n");
    uint64_t *tmp_ptr;
    fpga_result r = fpgaMapMMIO(accel_handle, 0, &tmp_ptr);
    if (r != FPGA_OK) {
        fprintf(stderr, "[load_weights_buffer] Error: fpgaMapMMIO failed\n");
        return -1;  // Nothing allocated yet, safe to return directly
    }
    mmio.buf = tmp_ptr;

    if (!build_burst_plan(weights_bytes, MAX_BURST_SIZE, weights_bursts, "Weights")) {
        fprintf(stderr, "[load_weights_buffer] Error: weights burst plan failed\n");
        goto cleanup;
    }

    SPATIAL_DEBUG("[load_weights_buffer] Allocating weights buffer...\n");
    weights_buf = (volatile uint64_t*)alloc_buffer(accel_handle, weights_bytes, &weights_wsid, &weights_pa);
    if (!weights_buf) {
        fprintf(stderr, "[load_weights_buffer] Error: weights buffer allocation failed\n");
        goto cleanup;
    }

    for (size_t i = 0; i < weights_bytes / sizeof(uint64_t); i++) {
        weights_buf[i] = weights_data[i];
    }

    SPATIAL_DEBUG("[load_weights_buffer] Starting ddr write bursts...\n");
    for (size_t i = 0; i < weights_bursts.sizes.size(); i++) {
        // Stall while the IP already has too many outstanding read requests
        while (readMMIO64(&mmio, CSR_READ_REQUESTS_PENDING) > 250) {
            SPATIAL_DEBUG("[load_weights_buffer] Stalling\n");
        }

        if (weights_bursts.axi_burst_len[i] != current_read_len) {
            writeMMIO64(&mmio, CSR_SET_READ_BURST_LEN, weights_bursts.axi_burst_len[i]);
            current_read_len = weights_bursts.axi_burst_len[i];
        }

        SPATIAL_DEBUG("  - DDR write burst %zu: src=0x%lx, dst=0x%lx, size=%u bytes, AXI len=%u\n",
                      i, weights_pa + weights_bursts.address_offsets[i],
                      start_addr + weights_bursts.address_offsets[i], weights_bursts.sizes[i],
                      weights_bursts.axi_burst_len[i]);

        writeMMIO64(&mmio, CSR_SET_DEST_ADDRESS,
                    start_addr + weights_bursts.address_offsets[i] + bank_number);
        writeMMIO64(&mmio, CSR_SET_SRC_ADDRESS, weights_pa + weights_bursts.address_offsets[i]);
    }

    SPATIAL_DEBUG("[load_weights_buffer] Waiting for weights to be processed...\n");
    while (readMMIO64(&mmio, CSR_WEIGHTS_PROCESSED) == 0) {
        // Tight poll until the IP reports the weights have been consumed
    }

    // Success
    result = 0;
    SPATIAL_DEBUG("[load_weights_buffer] Done.\n");

cleanup:
    if (weights_buf) fpgaReleaseBuffer(accel_handle, weights_wsid);

    return result;
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

void unpack_data(
    const uint64_t *packed_output,
    uint64_t *output_data
)
{
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

static int issue_read_requests(const mmio_ctx_t* mmio,
                               const BurstPlan& plan,
                               uint64_t src_pa) {
    if (!mmio) {
        fprintf(stderr, "[issue_read_requests] Error: null MMIO context\n");
        return -1;
    }
    if (plan.sizes.empty() || plan.sizes.size() != plan.axi_burst_len.size() ||
        plan.sizes.size() != plan.address_offsets.size()) {
        fprintf(stderr, "[issue_read_requests] Error: empty or inconsistent burst plan\n");
        return -1;
    }

    SPATIAL_DEBUG("[issue_read_requests] Issuing %zu read bursts...\n", plan.sizes.size());

    uint8_t current_read_len = plan.axi_burst_len[0];
    writeMMIO64(mmio, CSR_SET_READ_BURST_LEN, current_read_len);
    writeMMIO64(mmio, CSR_SET_DEST_ADDRESS, CSR_DEST_SPATIAL_IP);

    for (size_t i = 0; i < plan.sizes.size(); i++) {
        if (plan.axi_burst_len[i] != current_read_len) {
            writeMMIO64(mmio, CSR_SET_READ_BURST_LEN, plan.axi_burst_len[i]);
            current_read_len = plan.axi_burst_len[i];
        }

        const uint64_t burst_src = src_pa + plan.address_offsets[i];
        SPATIAL_DEBUG("  - Read burst %zu: src=0x%lx, size=%u bytes, AXI len=%u\n", i, burst_src,
                      plan.sizes[i], plan.axi_burst_len[i]);
        writeMMIO64(mmio, CSR_SET_SRC_ADDRESS, burst_src);
    }

    return 0;
}

static int issue_write_requests(const mmio_ctx_t* mmio,
                                const BurstPlan& plan,
                                uint64_t dst_pa) {
    if (!mmio) {
        fprintf(stderr, "[issue_write_requests] Error: null MMIO context\n");
        return -1;
    }
    if (plan.sizes.empty() || plan.sizes.size() != plan.axi_burst_len.size() ||
        plan.sizes.size() != plan.address_offsets.size()) {
        fprintf(stderr, "[issue_write_requests] Error: empty or inconsistent burst plan\n");
        return -1;
    }

    SPATIAL_DEBUG("[issue_write_requests] Issuing %zu write bursts...\n", plan.sizes.size());

    uint8_t current_write_len = plan.axi_burst_len[0];
    writeMMIO64(mmio, CSR_SET_WRITE_BURST_LEN, current_write_len);

    for (size_t i = 0; i < plan.sizes.size(); i++) {
        if (plan.axi_burst_len[i] != current_write_len) {
            writeMMIO64(mmio, CSR_SET_WRITE_BURST_LEN, plan.axi_burst_len[i]);
            current_write_len = plan.axi_burst_len[i];
        }

        const bool is_last_req = (i + 1 == plan.sizes.size());
        const uint64_t current_dst_pa = dst_pa + plan.address_offsets[i];

        SPATIAL_DEBUG("  - Write burst %zu: dst=0x%lx, size=%u bytes, AXI len=%u%s\n", i,
                      current_dst_pa, plan.sizes[i], plan.axi_burst_len[i],
                      is_last_req ? " (with completion)" : "");

        // Last write sets the completion flag in the low bit of the address.
        writeMMIO64(mmio, CSR_SET_WRITE_ADDRESS, is_last_req ? (current_dst_pa | 1) : current_dst_pa);
    }

    return 0;
}

//
// Function for running inference on input array with burst management
//
int run_inference(
    const std::vector<uint64_t>& input_data,
    std::vector<uint64_t>& output_data
)
{
    SPATIAL_DEBUG("[run_inference] Entered function\n");

    fpga_handle accel_handle = spatial_fpga_handle();
    if (!accel_handle) {
        fprintf(stderr, "[run_inference] Error: no active FPGA session (call connect_to_fpga first)\n");
        return -1;
    }
    if (INPUT_LANES == 0 || OUTPUT_LANES == 0 || INPUT_PACKETS == 0 || OUTPUT_PACKETS == 0 ||
        INPUT_PACKET_ELEMS == 0 || OUTPUT_PACKET_ELEMS == 0) {
        fprintf(stderr, "[run_inference] Error: port config not loaded\n");
        return -1;
    }
    if (input_data.empty() || input_data.size() % INPUT_PACKET_ELEMS != 0) {
        fprintf(stderr, "[run_inference] Error: input elems %zu not divisible by packet size %u\n",
                input_data.size(), INPUT_PACKET_ELEMS);
        return -1;
    }
    const size_t input_packets = input_data.size() / INPUT_PACKET_ELEMS;
    // Scale design I/O packet ratio: N * INPUT_PACKETS in → N * OUTPUT_PACKETS out
    if (input_packets % INPUT_PACKETS != 0) {
        fprintf(stderr, "[run_inference] Error: input packets %zu not a multiple of design input_packets %u\n",
                input_packets, INPUT_PACKETS);
        return -1;
    }
    const size_t output_packets = (input_packets / INPUT_PACKETS) * OUTPUT_PACKETS;
    output_data.resize(output_packets * OUTPUT_PACKET_ELEMS);

    // Return code: -1 = error, 0 = success
    int result = -1;

    // Declare all dynamically allocated pointers at the start (for goto cleanup)
    uint64_t *packed_input = NULL;
    uint64_t *packed_output = NULL;
    BurstPlan input_bursts;
    BurstPlan output_bursts;
    volatile uint64_t *src_buf = NULL;
    volatile uint64_t *dst_buf = NULL;
    volatile uint64_t *cmp_buf = NULL;
    uint64_t src_wsid = 0, dst_wsid = 0, cmp_wsid = 0;
    uint64_t src_pa = 0, dst_pa = 0, cmp_pa = 0;
    // Declared before any goto cleanup (C++ forbids jumping over init).
    uint64_t v = 0;
    uint16_t max_reqs_in_flight = 0;
    uint16_t max_burst_size = MAX_BURST_SIZE;

    mmio_ctx_t mmio;
    mmio.handle = accel_handle;
    mmio.buf = NULL;

    SPATIAL_DEBUG("[run_inference] Mapping MMIO...\n");
    uint64_t *tmp_ptr;
    fpga_result r = fpgaMapMMIO(accel_handle, 0, &tmp_ptr);
    if (r != FPGA_OK) {
        fprintf(stderr, "[run_inference] Error: fpgaMapMMIO failed\n");
        return -1;  // Nothing allocated yet, safe to return directly
    }
    mmio.buf = tmp_ptr;

    // Calculate input and output sizes with padding to 64 byte aligned words
    int input_bus_transactions_per_packet = static_cast<int>(std::ceil(
        static_cast<float>(INPUT_SUBVECTORS) /
        (HOST_BUS_NUM_BYTES * 8 / (INPUT_DATA_WIDTH * INPUT_LANES))));
    int output_bus_transactions_per_packet = static_cast<int>(std::ceil(
        static_cast<float>(OUTPUT_SUBVECTORS) /
        (HOST_BUS_NUM_BYTES * 8 / (OUTPUT_DATA_WIDTH * OUTPUT_LANES))));

    size_t input_bytes =  HOST_BUS_NUM_BYTES * input_bus_transactions_per_packet * input_packets;
    size_t output_bytes = HOST_BUS_NUM_BYTES * output_bus_transactions_per_packet * output_packets;

    SPATIAL_DEBUG("[run_inference] Input size: %zu bytes (%zu packets)\n", input_bytes, input_packets);
    SPATIAL_DEBUG("[run_inference] Output size: %zu bytes (%zu packets)\n", output_bytes, output_packets);

    packed_input = (uint64_t*)malloc(input_bytes);
    if (!packed_input) {
        fprintf(stderr, "[run_inference] Error: failed to allocate packed_input\n");
        goto cleanup;
    }

    for (size_t packet = 0; packet < input_packets; packet++) {
        pack_data(&input_data[packet * INPUT_PACKET_ELEMS],
                  &packed_input[packet * input_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t)]);
    }

    // Read AFU Info
    v = readMMIO64(&mmio, CSR_AFU_INFO);
    max_reqs_in_flight = (v >> 16) & 0xffff;
    max_burst_size = MAX_BURST_SIZE;

    SPATIAL_DEBUG("[run_inference] AFU info:\n");
    SPATIAL_DEBUG("  - Max burst size: %u bytes\n", max_burst_size);
    SPATIAL_DEBUG("  - Max inflight reqs: %u\n", max_reqs_in_flight);

    if (!build_burst_plan(input_bytes, max_burst_size, input_bursts, "Input", max_reqs_in_flight)) {
        fprintf(stderr, "[run_inference] Error: input burst plan failed\n");
        goto cleanup;
    }
    if (!build_burst_plan(output_bytes, max_burst_size, output_bursts, "Output", max_reqs_in_flight)) {
        fprintf(stderr, "[run_inference] Error: output burst plan failed\n");
        goto cleanup;
    }


    SPATIAL_DEBUG("[run_inference] Allocating buffers...\n");
    // Source buffer. The FPGA will read inputs from here.
    src_buf = (volatile uint64_t*)alloc_buffer(accel_handle, input_bytes, &src_wsid, &src_pa);
    if (!src_buf) {
        fprintf(stderr, "[run_inference] Error: source buffer allocation failed\n");
        goto cleanup;
    }

    // Destination buffer. The FPGA will write outputs here.
    dst_buf = (volatile uint64_t*)alloc_buffer(accel_handle, output_bytes, &dst_wsid, &dst_pa);
    if (!dst_buf) {
        fprintf(stderr, "[run_inference] Error: destination buffer allocation failed\n");
        goto cleanup;
    }

    // Completion buffer. A 1 will be stored here by the FPGA when it has completed all output requests.
    cmp_buf = (volatile uint64_t*)alloc_buffer(accel_handle, 64, &cmp_wsid, &cmp_pa);
    if (!cmp_buf) {
        fprintf(stderr, "[run_inference] Error: completion buffer allocation failed\n");
        goto cleanup;
    }
    // Initialize to 0 so we know when the FPGA has written to the completion buffer
    cmp_buf[0] = 0;

    // Copy input data
    SPATIAL_DEBUG("[run_inference] Copying input data...\n");
    for (size_t i = 0; i < input_bytes/sizeof(uint64_t); ++i) {
        src_buf[i] = packed_input[i];
    }

    // Set up inference parameters
    writeMMIO64(&mmio, CSR_SET_CMPL_ADDRESS, cmp_pa);

    if (issue_read_requests(&mmio, input_bursts, src_pa) != 0) {
        fprintf(stderr, "[run_inference] Error: issue_read_requests failed\n");
        goto cleanup;
    }
    if (issue_write_requests(&mmio, output_bursts, dst_pa) != 0) {
        fprintf(stderr, "[run_inference] Error: issue_write_requests failed\n");
        goto cleanup;
    }

    // Wait for completion
    SPATIAL_DEBUG("[run_inference] Waiting for inference to complete...\n");
    while (cmp_buf[0] == 0) {
        // Tight poll for small, fast operations
    }

    SPATIAL_DEBUG("[run_inference] Inference complete\n");

    // Copy results back
    SPATIAL_DEBUG("[run_inference] Unpacking data...\n");
    packed_output = (uint64_t*)malloc(output_bytes);
    if (!packed_output) {
        fprintf(stderr, "[run_inference] Error: failed to allocate packed_output\n");
        goto cleanup;
    }
    memcpy(packed_output, (const void *)(dst_buf), output_bytes);

    for (size_t packet = 0; packet < output_packets; packet++) {
        unpack_data(&packed_output[packet * output_bus_transactions_per_packet * HOST_BUS_NUM_BYTES/sizeof(uint64_t)],
                    &output_data[packet * OUTPUT_PACKET_ELEMS]);
    }

    // Success
    result = 0;
    SPATIAL_DEBUG("[run_inference] Done.\n");

cleanup:
    // Release FPGA buffers (check pointer before releasing)
    if (cmp_buf) fpgaReleaseBuffer(accel_handle, cmp_wsid);
    if (dst_buf) fpgaReleaseBuffer(accel_handle, dst_wsid);
    if (src_buf) fpgaReleaseBuffer(accel_handle, src_wsid);

    free(packed_output);
    free(packed_input);

    return result;
}
