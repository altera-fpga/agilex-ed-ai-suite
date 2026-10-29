// Copyright (C) 2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Spatial mode: image classification via MMD (no OpenVINO plugin).
// Loads an image, encodes pixels to the port data width, runs inference,
// decodes scores to float32, and reports top-N class indices (no label names).

#include "spatial_benchmark.hpp"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#ifdef SPATIAL_ENABLED
#include <gflags/gflags.h>

#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

#include "fpga.h"
#include "mmd.h"
#include "spatial_port_config.h"

DECLARE_string(spatial_input);
DECLARE_string(spatial_golden);
DECLARE_string(spatial_config);
DECLARE_string(spatial_weights);
DECLARE_string(spatial_resize);
DECLARE_string(output_dir);

namespace dla_benchmark {

namespace {

bool parse_resize(const std::string& s, int& height, int& width) {
    if (s.empty()) {
        height = 0;
        width = 0;
        return true;
    }
    const size_t x = s.find_first_of("xX");
    if (x == std::string::npos) {
        return false;
    }
    try {
        height = std::stoi(s.substr(0, x));
        width = std::stoi(s.substr(x + 1));
    } catch (...) {
        return false;
    }
    return height > 0 && width > 0;
}

uint64_t encode_float(float value, unsigned data_width) {
    uint32_t bits = 0;
    std::memcpy(&bits, &value, sizeof(bits));
    if (data_width == 16) {
        return bits >> 16;  // BF16 in low 16 bits of the u64 word
    }
    if (data_width == 32) {
        return bits;
    }
    throw std::invalid_argument("Unsupported input data_width (expected 16 or 32)");
}

// Load RGB image as flat NCHW float32 pixels in 0..255 (same as resnet8 Python runtime).
bool load_image_nchw_u64(const std::string& path, int resize_h, int resize_w, std::vector<uint64_t>& out) {
    cv::Mat img = cv::imread(path, cv::IMREAD_COLOR);
    if (img.empty()) {
        return false;
    }
    cv::cvtColor(img, img, cv::COLOR_BGR2RGB);
    if (resize_h > 0 && resize_w > 0) {
        cv::resize(img, img, cv::Size(resize_w, resize_h), 0, 0, cv::INTER_LINEAR);
    }
    const int h = img.rows;
    const int w = img.cols;
    const int c = 3;
    out.resize(static_cast<size_t>(c) * h * w);
    for (int ch = 0; ch < c; ++ch) {
        for (int y = 0; y < h; ++y) {
            for (int x = 0; x < w; ++x) {
                out[static_cast<size_t>(ch) * h * w + static_cast<size_t>(y) * w + x] =
                    encode_float(static_cast<float>(img.at<cv::Vec3b>(y, x)[ch]), INPUT_DATA_WIDTH);
            }
        }
    }
    return true;
}

float decode_float(uint64_t word, unsigned data_width) {
    uint32_t bits = 0;
    if (data_width == 16) {
        bits = static_cast<uint32_t>(word & 0xFFFFu) << 16;  // BF16 → FP32
    } else if (data_width == 32) {
        bits = static_cast<uint32_t>(word & 0xFFFFFFFFu);
    } else {
        throw std::invalid_argument("Unsupported output data_width (expected 16 or 32)");
    }
    float value = 0.f;
    std::memcpy(&value, &bits, sizeof(value));
    return value;
}

std::vector<float> decode_floats(const std::vector<uint64_t>& words, unsigned data_width) {
    std::vector<float> out(words.size());
    for (size_t i = 0; i < words.size(); ++i) {
        out[i] = decode_float(words[i], data_width);
    }
    return out;
}

// Print / write top-N class indices and scores (dla_benchmark style, no label names).
void report_classification(const std::vector<float>& scores, std::ostream& out) {
    using CatProbPair = std::pair<int, float>;
    const int n = static_cast<int>(scores.size());
    const int top_n = static_cast<int>(std::fmin(5, n));
    std::vector<CatProbPair> top;
    for (int i = 0; i < top_n; ++i) {
        top.emplace_back(i, scores[i]);
    }
    for (int i = top_n; i < n; ++i) {
        auto min_it = std::min_element(top.begin(), top.end(),
                                       [](const CatProbPair& a, const CatProbPair& b) {
                                           return a.second < b.second;
                                       });
        if (scores[i] > min_it->second) {
            *min_it = {i, scores[i]};
        }
    }
    std::sort(top.begin(), top.end(),
              [](const CatProbPair& a, const CatProbPair& b) { return a.second > b.second; });

    out << "image 0 top " << top_n << ":\n";
    for (const auto& pair : top) {
        out << pair.first << " : " << pair.second << '\n';
    }
}

bool load_groundtruth_class(const std::string& path, int& truth) {
    std::ifstream file(path);
    if (!file.is_open()) {
        return false;
    }
    std::string line;
    if (!std::getline(file, line)) {
        return false;
    }
    try {
        truth = std::stoi(line);
    } catch (...) {
        return false;
    }
    return true;
}

// Optional ground-truth class index (one int). Reports top1/top5 like dla_benchmark.
bool check_groundtruth(const std::vector<float>& scores, int truth, std::ostream& out) {
    using CatProbPair = std::pair<int, float>;
    const int n = static_cast<int>(scores.size());
    const int top_n = static_cast<int>(std::fmin(5, n));
    std::vector<CatProbPair> top;
    for (int i = 0; i < n; ++i) {
        top.emplace_back(i, scores[i]);
    }
    std::partial_sort(top.begin(), top.begin() + top_n, top.end(),
                      [](const CatProbPair& a, const CatProbPair& b) { return a.second > b.second; });
    top.resize(top_n);

    const bool top1 = !top.empty() && top[0].first == truth;
    bool top5 = false;
    for (const auto& g : top) {
        if (g.first == truth) {
            top5 = true;
            break;
        }
    }
    out << truth << " : truth\n";
    out << "top1 accuracy: " << (top1 ? 100.0 : 0.0) << " %\n";
    if (top_n > 1) {
        out << "top" << top_n << " accuracy: " << (top5 ? 100.0 : 0.0) << " %\n";
    }
    return top1;
}

bool write_float_file(const std::string& path, const std::vector<float>& data) {
    std::ofstream file(path);
    if (!file.is_open()) {
        return false;
    }
    file.setf(std::ios::scientific);
    file.precision(9);
    for (float v : data) {
        file << v << '\n';
    }
    return static_cast<bool>(file);
}

}  // namespace

int run_spatial_benchmark() {
    std::cout << "[SPATIAL MODE] Image classification via MMD.\n";

    if (FLAGS_spatial_input.empty()) {
        std::cerr << "[SPATIAL MODE] ERROR: -spatial_input (image path) is required.\n";
        return 1;
    }

    int resize_h = 0;
    int resize_w = 0;
    if (!parse_resize(FLAGS_spatial_resize, resize_h, resize_w)) {
        std::cerr << "[SPATIAL MODE] ERROR: -spatial_resize must be HxW (e.g. 32x32).\n";
        return 1;
    }

    if (FLAGS_spatial_config.empty()) {
        std::cerr << "[SPATIAL MODE] ERROR: -spatial_config (port_config.json) is required.\n";
        return 1;
    }
    if (load_port_config(FLAGS_spatial_config.c_str()) != 0) {
        std::cerr << "[SPATIAL MODE] ERROR: failed to load port config: " << FLAGS_spatial_config
                  << '\n';
        return 1;
    }

    std::vector<uint64_t> input_vals;
    if (!load_image_nchw_u64(FLAGS_spatial_input, resize_h, resize_w, input_vals)) {
        std::cerr << "[SPATIAL MODE] ERROR: Failed to load image: " << FLAGS_spatial_input << '\n';
        return 1;
    }
    std::cout << "[SPATIAL MODE] Loaded image: " << FLAGS_spatial_input << " (" << input_vals.size()
              << " pixels NCHW uint64)\n";

    std::vector<uint64_t> output_vals;
    std::vector<float> scores;

    if (connect_to_fpga() != 0) {
        std::cerr << "[SPATIAL MODE] ERROR: connect_to_fpga failed.\n";
        return 1;
    }

    int rc = 0;
    if (!FLAGS_spatial_weights.empty()) {
        std::cout << "[SPATIAL MODE] Loading weights from: " << FLAGS_spatial_weights << '\n';
        if (reset() != 0 || load_weights(FLAGS_spatial_weights.c_str()) != 0) {
            std::cerr << "[SPATIAL MODE] ERROR: weight load failed.\n";
            disconnect_fpga();
            return 1;
        }
    } else {
        std::cout << "[SPATIAL MODE] No -spatial_weights; skipping weight load.\n";
    }

    if (reset() != 0) {
        std::cerr << "[SPATIAL MODE] ERROR: reset failed.\n";
        disconnect_fpga();
        return 1;
    }

    const auto inference_start = std::chrono::steady_clock::now();
    rc = run_inference(input_vals, output_vals);
    const auto inference_end = std::chrono::steady_clock::now();
    disconnect_fpga();
    if (rc != 0) {
        std::cerr << "[SPATIAL MODE] ERROR: run_inference failed.\n";
        return rc;
    }
    const double inference_ms =
        std::chrono::duration<double, std::milli>(inference_end - inference_start).count();
    const double throughput_fps = inference_ms > 0.0 ? 1000.0 / inference_ms : 0.0;
    std::cout << "[SPATIAL MODE] Inference latency: " << inference_ms << " ms\n";
    std::cout << "[SPATIAL MODE] Throughput: " << throughput_fps << " FPS\n";

    try {
        scores = decode_floats(output_vals, OUTPUT_DATA_WIDTH);
    } catch (const std::exception& e) {
        std::cerr << "[SPATIAL MODE] ERROR: " << e.what() << '\n';
        return 1;
    }

    report_classification(scores, std::cout);

    std::string out_dir = FLAGS_output_dir;
    if (!out_dir.empty()) {
        std::error_code ec;
        std::filesystem::create_directories(out_dir, ec);
        if (ec || !std::filesystem::is_directory(out_dir)) {
            std::cerr << "[SPATIAL MODE] ERROR: cannot create/open output dir: " << out_dir << '\n';
            return 1;
        }
        if (out_dir.back() != '/') {
            out_dir.push_back('/');
        }
    }

    const std::string result_path = out_dir.empty() ? "result.txt" : (out_dir + "result.txt");
    if (!write_float_file(result_path, scores)) {
        std::cerr << "[SPATIAL MODE] ERROR: Failed to write " << result_path << '\n';
        return 1;
    }
    std::cout << "[SPATIAL MODE] Wrote float scores to: " << result_path << " (" << scores.size()
              << " values)\n";

    if (!FLAGS_spatial_golden.empty()) {
        int truth = -1;
        if (!load_groundtruth_class(FLAGS_spatial_golden, truth)) {
            std::cerr << "[SPATIAL MODE] ERROR: Failed to load ground truth: " << FLAGS_spatial_golden
                      << '\n';
            return 1;
        }
        const std::string accuracy_path =
            out_dir.empty() ? "accuracy_report.txt" : (out_dir + "accuracy_report.txt");
        std::ofstream accuracy_file(accuracy_path);
        if (!accuracy_file.is_open()) {
            std::cerr << "[SPATIAL MODE] ERROR: Failed to open " << accuracy_path << '\n';
            return 1;
        }
        report_classification(scores, accuracy_file);
        check_groundtruth(scores, truth, accuracy_file);
        check_groundtruth(scores, truth, std::cout);
        std::cout << "[SPATIAL MODE] Wrote accuracy report to: " << accuracy_path << '\n';
    }

    std::cout << "[SPATIAL MODE] Inference complete.\n";
    return 0;
}

}  // namespace dla_benchmark

#else

namespace dla_benchmark {

int run_spatial_benchmark() {
    std::cerr << "[SPATIAL MODE] ERROR: dla_benchmark was not built with spatial support.\n";
    return 1;
}

}  // namespace dla_benchmark

#endif  // SPATIAL_ENABLED
