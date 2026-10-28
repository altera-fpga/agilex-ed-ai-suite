#include <cstdint>
#include <cstdio>
#include <cstdlib>

#include <opae/fpga.h>
#include <uuid/uuid.h>

#include "fpga.h"
#include "spatial_debug.h"

static fpga_handle g_handle = nullptr;

fpga_handle spatial_fpga_handle() {
    return g_handle;
}

int connect_to_fpga() {
    fpga_properties filter = nullptr;
    fpga_guid guid;
    constexpr uint32_t max_tokens = 32;
    fpga_token accel_tokens[max_tokens];
    uint32_t num_matches = 0;
    fpga_handle accel_handle = nullptr;
    fpga_result r;
    const char* accel_uuid = AFU_ACCEL_UUID;
    constexpr uint32_t select = 0;

    if (g_handle != nullptr) {
        fprintf(stderr, "connect_to_fpga: session already open\n");
        return -1;
    }

    SPATIAL_DEBUG("[fpga] connect_to_fpga UUID: %s\n", accel_uuid);

    fpgaGetProperties(nullptr, &filter);
    fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);

    uuid_parse(accel_uuid, guid);
    fpgaPropertiesSetGUID(filter, guid);

    r = fpgaEnumerate(&filter, 1, accel_tokens, max_tokens, &num_matches);
    fpgaDestroyProperties(&filter);

    if ((FPGA_OK != r) || (num_matches == 0)) {
        fprintf(stderr, "Accelerator %s not found! (result=%d, matches=%u)\n", accel_uuid, r,
                num_matches);
        return -1;
    }

    r = fpgaOpen(accel_tokens[select], &accel_handle, 0);
    if (FPGA_OK != r) {
        fprintf(stderr, "fpgaOpen failed: %d\n", r);
        for (uint32_t i = 0; i < num_matches; i++) {
            fpgaDestroyToken(&accel_tokens[i]);
        }
        return -1;
    }

    fpga_properties accel_props = nullptr;
    uint16_t vendor_id = 0;
    uint16_t dev_id = 0;
    fpgaGetProperties(accel_tokens[select], &accel_props);
    fpgaPropertiesGetVendorID(accel_props, &vendor_id);
    fpgaPropertiesGetDeviceID(accel_props, &dev_id);
    fpgaDestroyProperties(&accel_props);

    for (uint32_t i = 0; i < num_matches; i++) {
        fpgaDestroyToken(&accel_tokens[i]);
    }

    g_handle = accel_handle;
    return 0;
}

int disconnect_fpga() {
    if (!g_handle) {
        return 0;
    }
    const fpga_result r = fpgaClose(g_handle);
    g_handle = nullptr;
    if (r != FPGA_OK) {
        fprintf(stderr, "disconnect_fpga: fpgaClose failed: %d\n", r);
        return -1;
    }
    return 0;
}
