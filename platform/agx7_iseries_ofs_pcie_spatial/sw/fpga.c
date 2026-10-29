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

#include <opae/fpga.h>
//
#include <assert.h>
#include <uuid/uuid.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
//
// Search for all accelerators matching the requested properties and
// connect to them. Return handle of selected 
//
fpga_handle connect_to_selected_accel(const char *accel_uuid,
    uint32_t select,
    bool *is_ase_sim)
{
    fpga_properties filter = NULL;
    fpga_guid guid;
    const uint32_t max_tokens = 32;
    fpga_token accel_tokens[max_tokens];
    uint32_t num_matches;
    fpga_handle accel_handle;
    fpga_result r;

    // Don't print verbose messages in ASE by default
    setenv("ASE_LOG", "0", 0);
    *is_ase_sim = false;

    // Set up a filter that will search for an accelerator
    fpgaGetProperties(NULL, &filter);
    fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);

    // Add the desired UUID to the filter
    uuid_parse(accel_uuid, guid);
    fpgaPropertiesSetGUID(filter, guid);

    // Do the search across the available FPGA contexts
    r = fpgaEnumerate(&filter, 1, accel_tokens, max_tokens, &num_matches);
    fpgaDestroyProperties(&filter);

    if ((FPGA_OK != r) || (select > num_matches -1))
    {
    fprintf(stderr, "Accelerator %s not found!\n", accel_uuid);
    }

    // Open accelerator
    r = fpgaOpen(accel_tokens[select], &accel_handle, 0);
    assert(FPGA_OK == r);

    // While the token is available, check whether it is for HW
    // or for ASE simulation, recording it so probeForASE() below
    // doesn't have to run through the device list again.
    fpga_properties accel_props;
    uint16_t vendor_id, dev_id;
    fpgaGetProperties(accel_tokens[select], &accel_props);
    fpgaPropertiesGetVendorID(accel_props, &vendor_id);
    fpgaPropertiesGetDeviceID(accel_props, &dev_id);
    *is_ase_sim = (vendor_id == 0x8086) && (dev_id == 0xa5e);
    uint32_t i;  
    for (i = 0; i < num_matches; i += 1)
    {
    fpgaDestroyToken(&accel_tokens[i]);
    }

    return accel_handle;
}