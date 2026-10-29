# Copyright (C) 2018-2020 Altera Corporation
# SPDX-License-Identifier: Apache-2.0
#

# Add dependencies for the following modules
find_package(OpenCV COMPONENTS core REQUIRED)

# pull in plugin apis and preproc
add_subdirectory(utils)
add_subdirectory(format_reader)
add_subdirectory(monitors)

if(DEFINED BUILD_DEMO)
    # This dependency defines CNN prototypes used by text-detection demos.
    include_directories("$ENV{COREDLA_ROOT}/transformations/inc/")
    add_subdirectory(demo_utils)
    add_subdirectory(models)
    # This dependency is needed for runtime demos. The config_factory is used
    # to produce hardware configurations and is required by pipelines.
    #add_subdirectory(utils)

    # Following steps compile and link the pipelines library from OpenVINO 2021.4 installation folder.
    # This dependency is required by segmentation demo. It implements a pipeline for sending streaming input and output for inference.
    add_subdirectory(pipelines)
endif()
