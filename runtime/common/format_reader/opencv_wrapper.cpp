// Copyright (C) 2018-2024 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//

#ifdef USE_OPENCV
#    include <fstream>
#    include <iostream>

// clang-format off
#    include <opencv2/opencv.hpp>

#    include "samples/slog.hpp"
#    include "opencv_wrapper.h"
// clang-format on

using namespace std;
using namespace FormatReader;

OCVReader::OCVReader(const string& filename) {
    img = cv::imread(filename);
    _size = 0;

    if (img.empty()) {
        return;
    }

    _size = img.size().width * img.size().height * img.channels();
    _width = img.size().width;
    _height = img.size().height;
    _shape.push_back(_height);
    _shape.push_back(_width);
}

// Set the maximum number of printed warnings; large image directories can otherwise be overwhelming
static size_t resize_warning_count = 0;
const size_t max_resize_warnings = 5;

std::shared_ptr<unsigned char> OCVReader::getData(size_t width = 0, size_t height = 0, ResizeType resize_type = ResizeType::RESIZE) {
    if (width == 0)
        width = img.cols;

    if (height == 0)
        height = img.rows;

    size_t size = width * height * img.channels();
    _data.reset(new unsigned char[size], std::default_delete<unsigned char[]>());

    if (width != static_cast<size_t>(img.cols) || height != static_cast<size_t>(img.rows)) {
        if (resize_warning_count < max_resize_warnings) {
            slog::warn << "Image is resized from (" << img.cols << ", " << img.rows << ") to (" << width << ", " << height
                       << ")" << slog::endl;
            resize_warning_count++;
        } else if (resize_warning_count == max_resize_warnings) {
            slog::warn << "Additional image resizing messages have been suppressed." << slog::endl;
            resize_warning_count++;
        }
    }

    cv::Mat resized;
    if (resize_type == ResizeType::RESIZE) {
        resized = cv::Mat(cv::Size(width, height), img.type(), _data.get());
        // cv::resize() just copy data to output image if sizes are the same
        cv::resize(img, resized, cv::Size(width, height));
    } else if (resize_type == ResizeType::PAD_RESIZE)
    {
        cv::Mat padded;
        // Find the larger side out of width and height of the image
        int max_dim = std::max(img.rows, img.cols);
        // Calculate padding for shorter dimension
        int top = (max_dim - img.rows) / 2;
        int bottom = (max_dim - img.rows + 1) / 2;
        int left = (max_dim - img.cols) / 2;
        int right = (max_dim - img.cols + 1) / 2;
        // Add padding (0, i.e., black) to make the image a square
        cv::copyMakeBorder(img, padded, top, bottom, left, right, cv::BORDER_CONSTANT, cv::Scalar());
        cv::resize(padded, resized, cv::Size(width, height));
        std::memcpy(_data.get(), resized.data, resized.total() * resized.elemSize());
    } else {
        slog::err << "Specified resize type is not implemented." << slog::endl;
        std::exit(1);
    }

    return _data;
}
#endif
