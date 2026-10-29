// Copyright (C) 2018-2024 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//

/**
 * \brief NumpyArray reader
 * \file npy.h
 */
#pragma once

#include <memory>
#include <string>
#include <vector>

// clang-format off
#include "format_reader.h"
#include "register.h"
// clang-format on

namespace FormatReader {
/**
 * \class NumpyArray
 * \brief Reader for NPY files
 */
class NumpyArray : public Reader {
private:
    static Register<NumpyArray> reg;
    std::string type;
    size_t _size = 0;

public:
    /**
     * \brief Constructor of NumpyArray reader
     * @param filename - path to input data
     * @return NumpyArray reader object
     */
    explicit NumpyArray(const std::string& filename);
    virtual ~NumpyArray() {}

    /**
     * \brief Get size
     * @return size
     */
    size_t size() const override {
        return _size;
    }

    // langsu: ResizeType is a added by us to support custom resizing functions (only in opencv_wrapper).
    // format_reader is copied from openvino samples/cpp/common/format_reader/
    // this might need special care when doing a OV uplift
    std::shared_ptr<unsigned char> getData(size_t width, size_t height, ResizeType resize_type) override {
        if ((width * height != 0) && (_width * _height != width * height)) {
            std::cout << "[ WARNING ] Image won't be resized! Please use OpenCV.\n";
            return nullptr;
        }
        return _data;
    }
};
}  // namespace FormatReader
