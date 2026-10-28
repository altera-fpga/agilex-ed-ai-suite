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
#include <uuid/uuid.h>
#include <time.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h> 
// OPAE API
#include <opae/fpga.h>
// State from the AFU's JSON file, extracted using OPAE's afu_json_mgr script
#include "afu_json_info.h"
// Application code
#include "fpga.h"
#include "config.h"
#include "demo.h"

// Function to get high-resolution timestamp in nanoseconds
static inline uint64_t get_timestamp_ns() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000UL + ts.tv_nsec;
}

// Function to load weights from a binary weights_ddr file.
// Filename must be of the form: weights_ddr_<bank_number>_<start_address>.bin
int load_weights_from_file(const char *filepath, fpga_handle accel_handle, bool is_ase_sim, bool verbose) {
    // Extract the base filename from the path
    const char *filename = strrchr(filepath, '/');
    filename = filename ? filename + 1 : filepath;

    // Parse bank_number and start_address from filename
    uint64_t bank_number = 0;
    uint64_t start_addr = 0;
    if (sscanf(filename, "weights_ddr_%lu_%lu.bin", &bank_number, &start_addr) != 2) {
        fprintf(stderr, "[main] Error: Could not parse bank_number and start_address from filename %s\n", filename);
        return -1;
    }

    // Open file in binary mode
    FILE *fp = fopen(filepath, "rb");
    if (!fp) {
        fprintf(stderr, "[main] Error: Could not open file %s\n", filepath);
        return -1;
    }

    // Get file size to determine num_bytes
    fseek(fp, 0, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    if (file_size <= 0) {
        fprintf(stderr, "[main] Error: File %s is empty or unreadable\n", filepath);
        fclose(fp);
        return -1;
    }

    size_t num_bytes = (size_t)file_size;
    size_t num_values = num_bytes / sizeof(uint64_t);

    if (verbose) {
        printf("[main] Loading weights from %s: bank=%lu, start_addr=0x%lx, bytes=%zu\n",
               filepath, bank_number, start_addr, num_bytes);
    }

    // Allocate buffer for weights data (64-bit aligned)
    uint64_t *weights_buffer = (uint64_t *)malloc(num_bytes);
    if (!weights_buffer) {
        fprintf(stderr, "[main] Error: Could not allocate memory for weights\n");
        fclose(fp);
        return -1;
    }

    // Read binary data
    size_t read_count = fread(weights_buffer, sizeof(uint64_t), num_values, fp);
    fclose(fp);

    if (read_count != num_values) {
        fprintf(stderr, "[main] Error: Expected %zu values but read %zu from %s\n", num_values, read_count, filepath);
        free(weights_buffer);
        return -1;
    }

    if (verbose) {
        printf("[main] Read %zu 64-bit values from %s\n", read_count, filepath);
    }

    // Call load_weights
    int result = load_weights(
        accel_handle,
        is_ase_sim,
        weights_buffer,
        num_bytes,
        start_addr,
        bank_number,
        verbose
    );

    free(weights_buffer);
    return result;
}

// Count non-empty lines in an ASCII hex file (one uint64_t value per line).
static size_t count_hex_lines(FILE *fp) {
    size_t count = 0;
    char line[256];

    while (fgets(line, sizeof(line), fp) != NULL) {
        char *hex = line;
        while (*hex == ' ' || *hex == '\t' || *hex == '\r' || *hex == '\n') {
            hex++;
        }
        if (*hex != '\0') {
            count++;
        }
    }

    return count;
}

// Function to load inputs/outputs from an ASCII hex file.
// Each non-empty line is one uint64_t value (hex digits, without 0x prefix).
uint64_t* load_data_from_file(const char *filepath, size_t *num_elements, bool verbose) {
    FILE *fp = fopen(filepath, "r");
    if (!fp) {
        fprintf(stderr, "[main] Error: Could not open file %s\n", filepath);
        return NULL;
    }

    size_t count = count_hex_lines(fp);
    if (count == 0) {
        fprintf(stderr, "[main] Error: File %s contains no data\n", filepath);
        fclose(fp);
        return NULL;
    }

    uint64_t *buffer = (uint64_t *)malloc(count * sizeof(uint64_t));
    if (!buffer) {
        fprintf(stderr, "[main] Error: Could not allocate memory for data buffer\n");
        fclose(fp);
        return NULL;
    }

    rewind(fp);

    size_t index = 0;
    char line[256];
    while (fgets(line, sizeof(line), fp) != NULL) {
        char *hex = line;
        while (*hex == ' ' || *hex == '\t' || *hex == '\r' || *hex == '\n') {
            hex++;
        }
        if (*hex == '\0') {
            continue;
        }

        char *endptr = NULL;
        uint64_t value = strtoull(hex, &endptr, 16);
        if (endptr == hex) {
            fprintf(stderr, "[main] Error: Invalid hex value '%s' in %s\n", hex, filepath);
            free(buffer);
            fclose(fp);
            return NULL;
        }

        buffer[index++] = value;
    }

    fclose(fp);

    if (index != count) {
        fprintf(stderr, "[main] Error: Expected %zu values but read %zu from %s\n", count, index, filepath);
        free(buffer);
        return NULL;
    }

    if (verbose) {
        printf("[main] Loaded %zu 64-bit values from %s\n", count, filepath);
    }

    if (num_elements != NULL) {
        *num_elements = count;
    }

    return buffer;
}

static void print_usage(const char *prog) {
    fprintf(stderr, "Usage: %s <input_file> <output_file> \n", prog);
    fprintf(stderr, "  input_file:  ASCII hex file, one uint64_t value per line\n");
    fprintf(stderr, "  output_file: ASCII hex file, one uint64_t value per line (golden output)\n");
}

//
// Run inference demo
//
int main(int argc, char *argv[])
{
    printf("[main] Starting...\n");

    if (argc < 3) {
        print_usage(argv[0]);
        return 1;
    }

    const char *input_file = argv[1];
    const char *output_file = argv[2];
    uint32_t select = 0;
    char *p;

    fpga_handle accel_handle;
    bool is_ase_sim = false;
    bool verbose = true;

    size_t input_count = 0;
    size_t golden_count = 0;
    uint64_t *input_data = load_data_from_file(input_file, &input_count, verbose);
    if (!input_data) {
        return 1;
    }

    uint64_t *golden_data = load_data_from_file(output_file, &golden_count, verbose);
    if (!golden_data) {
        free(input_data);
        return 1;
    }

    const size_t input_words_per_packet = INPUT_SUBVECTORS * INPUT_LANES;
    const size_t output_words_per_packet = OUTPUT_SUBVECTORS * OUTPUT_LANES;

    if (input_count % input_words_per_packet != 0) {
        fprintf(stderr, "[main] Error: Input file has %zu elements, not a multiple of %zu\n",
                input_count, input_words_per_packet);
        free(golden_data);
        free(input_data);
        return 1;
    }

    if (golden_count % output_words_per_packet != 0) {
        fprintf(stderr, "[main] Error: Output file has %zu elements, not a multiple of %zu\n",
                golden_count, output_words_per_packet);
        free(golden_data);
        free(input_data);
        return 1;
    }

    size_t input_packets = input_count / input_words_per_packet;
    size_t output_packets = golden_count / output_words_per_packet;

    uint64_t *output_buffer = (uint64_t *)malloc(golden_count * sizeof(uint64_t));
    if (!output_buffer) {
        fprintf(stderr, "[main] Error: Could not allocate memory for output buffer\n");
        free(golden_data);
        free(input_data);
        return 1;
    }

    printf("[main] Selecting AI instance %d\n", select);
    
    accel_handle = connect_to_selected_accel(AFU_ACCEL_UUID, select, &is_ase_sim);
    if (NULL == accel_handle) {
        fprintf(stderr, "[main] Failed to connect to accelerator\n");
        free(output_buffer);
        free(golden_data);
        free(input_data);
        return 1;
    }
    printf("[main] Connected to accelerator\n");
    // Run demo
    //ssize_t model_size_bytes = MODEL_SIZE;
    //int status = 0;
    //status = spark_demo(accel_handle, is_ase_sim, model_size_bytes);
    if (reset(accel_handle, is_ase_sim,verbose) != 0) {
        fprintf(stderr, "[main] Failed to reset FPGA\n");
        fpgaClose(accel_handle);
        free(output_buffer);
        free(golden_data);
        free(input_data);
        return 1;
    }

    // Load weights from all weights_ddr files in dump_files directory
    const char *dump_dir = "dump_files";
    DIR *dir = opendir(dump_dir);
    if (!dir) {
        fprintf(stderr, "[main] Error: Could not open directory %s\n", dump_dir);
        fpgaClose(accel_handle);
        free(output_buffer);
        free(golden_data);
        free(input_data);
        return 1;
    }

    printf("[main] Scanning %s for weights_ddr .bin files...\n", dump_dir);

    struct dirent *entry;
    int weights_loaded = 0;
    while ((entry = readdir(dir)) != NULL) {
        size_t name_len = strlen(entry->d_name);
        if (strncmp(entry->d_name, "weights_ddr", 11) == 0 &&
            name_len > 4 && strcmp(entry->d_name + name_len - 4, ".bin") == 0) {
            char filepath[512];
            snprintf(filepath, sizeof(filepath), "%s/%s", dump_dir, entry->d_name);

            printf("[main] Processing %s...\n", filepath);

            if (load_weights_from_file(filepath, accel_handle, is_ase_sim, false) != 0) {
                fprintf(stderr, "[main] Failed to load weights from %s\n", filepath);
                closedir(dir);
                fpgaClose(accel_handle);
                free(output_buffer);
                free(golden_data);
                free(input_data);
                return 1;
            }
            weights_loaded++;
        }
    }

    closedir(dir);

    if (weights_loaded == 0) {
        printf("[main] Warning: No weights_ddr files found\n");
        printf("[main] Continuing without loading weights...\n");
        sleep(3);
    } else {
        printf("[main] Successfully loaded weights from %d file(s)\n", weights_loaded);
    }

    int fail = 0;
    while(!fail){
        if (reset(accel_handle, is_ase_sim,verbose) != 0) {
            fprintf(stderr, "[main] Failed to reset FPGA\n");
            fpgaClose(accel_handle);
            free(output_buffer);
            free(golden_data);
            free(input_data);
            return 1;
        }
        uint64_t start_time, end_time, elapsed_time;

        printf("[main] Running inference...\n");
            
        start_time = get_timestamp_ns();

        if (run_inference(
                accel_handle,
                is_ase_sim,
                input_data,
                input_packets,
                output_buffer,
                output_packets,
                verbose) != 0) {
            fprintf(stderr, "[main] Inference failed\n");
            fpgaClose(accel_handle);
            free(output_buffer);
            free(golden_data);
            free(input_data);
            return 1;
        }

        end_time = get_timestamp_ns();
        elapsed_time = end_time - start_time;

        printf("[main] Inference completed in %.3f ms\n", elapsed_time / 1000000.0);

        printf("[main] Verifying output against golden data...\n");
        for (size_t i = 0; i < golden_count; i++) {
            uint64_t result = output_buffer[i];
            uint64_t expected = golden_data[i];

            if (result != expected) {
                printf("[main] \xE2\x9D\x8C Mismatch at position %zu: got 0x%lx, expected 0x%lx\n",
                    i, result, expected);
                fail = 1;
            }
        }
        break;
    }

    fpgaClose(accel_handle);
    free(output_buffer);
    free(golden_data);
    free(input_data);
    printf("[main] Done.\n");
    return fail ? 1 : 0;
}
