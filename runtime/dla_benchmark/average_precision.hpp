// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: The file defines functions calculate mAP and COCO AP metrics. See average_precision.cpp for a
// detailed explaination.

#ifndef DLA_BENCHMARK_OBJECT_DETECTION_H_
#define DLA_BENCHMARK_OBJECT_DETECTION_H_

#pragma once

#include <map>
#include <unordered_map>
#include <set>
#include <unordered_set>
#include <string>
#include <vector>
#include <utility>
#include <algorithm>
#include <iterator>


#include "openvino/openvino.hpp"
#include "format_reader_ptr.h"

#undef UNICODE

// Indexes for raw bounding box.
#define BBOX_X 0
#define BBOX_Y 1
#define BBOX_W 2
#define BBOX_H 3
#define BBOX_CONFIDENCE 4
#define YOLOv8_CLASS_IDX 4  // YOLOv8 starts at idx 4 instead of 5 like YOLOv3

// Indexes for annotation bounding boxes
#define ANNOTATION_X 0
#define ANNOTATION_Y 1
#define ANNOTATION_W 2
#define ANNOTATION_H 3
#define ANNOTATION_CLASS 4

// Indices for input image shapes.
#define IMG_W 0
#define IMG_H 1

// Indices for parsed bounding boxes.
#define X_MAX 0
#define X_MIN 1
#define Y_MAX 2
#define Y_MIN 3

// Convenient aliases.
template <typename T>
using Box = std::vector<T>;

template <typename T>
using Tensor2d = std::vector<std::vector<T>>;

template <typename T>
using Tensor3d = std::vector<std::vector<std::vector<T>>>;

#define NUM_SUPPORTED_YOLO_GRAPHS 3

// Supported YOLO graphs and its variants.
static constexpr std::array<const char*, NUM_SUPPORTED_YOLO_GRAPHS> supported_yolo_versions = {
    "yolo-v3-tf", "yolo-v3-tiny-tf", "yolo-v8"
};

// Each image will have a prediction entry containing coordinates,
// class scores of prediction boxes, predicted class, and size.
typedef struct prediction_entry_t {
  std::vector<double> x_max;
  std::vector<double> x_min;
  std::vector<double> y_max;
  std::vector<double> y_min;
  // scores for highest class
  std::vector<double> cls_score;
  // class with highest probability
  std::vector<int> cls;
  unsigned size;

  Box<double> box_at(unsigned idx) { return {x_max[idx], x_min[idx], y_max[idx], y_min[idx]}; }
} PredictionEntry;

// Each image will have an annotation entry containing coordinates and
// the true label specified in `cls`.
typedef struct annotation_entry_t {
  std::vector<double> x_max;
  std::vector<double> x_min;
  std::vector<double> y_max;
  std::vector<double> y_min;
  std::vector<int> cls;
  unsigned size;

  Box<double> box_at(unsigned idx) { return {x_max[idx], x_min[idx], y_max[idx], y_min[idx]}; }
} AnnotationEntry;

// Stores runtime variables.
static struct runtime_const_t {
  // Actually means number of validation image.
  unsigned niter;
  unsigned batch_size;
  std::string name;
  std::string groundtruth_loc;
  std::string input_loc;
  std::string report_folder;
  const std::string gt_extension = "txt";
  FormatReader::Reader::ResizeType resize_type;

  Tensor2d<std::string> input_image_path;
  Tensor2d<double> source_image_sizes;
} runtime_vars;

// Stores constants for evaluation.
static struct meta_t {
  // Filtering parameters,
  const double yolo_v3_confidence_threshold = 0.001;
  const double yolo_v3_iou_threshold        = 0.5;

  const double yolo_v8_confidence_threshold = 0.001;
  const double yolo_v8_iou_threshold        = 0.7;
  const int nms_max_detections              = 300;

  struct parsing_resizing_params_t {
    // Parameters for parsing and resizing.
    unsigned num_classes;
    unsigned output_channel;
    unsigned anchors_per_cell;
    unsigned prediction_box_size;
    unsigned grid_num;
  };

  parsing_resizing_params_t yolo_v3 = {
    80,   // num_classes
    255,  // output_channel
    3,    // anchors_per_cell
    85,   // prediction_box_size
    3     // grid_num
  };
  parsing_resizing_params_t yolo_v8 = {
    80,   // num_classes
    84,   // output_channel
    1,    // anchors_per_cell
    84,   // prediction_box_size
    1     // grid_num
  };

  const std::unordered_map<std::string, std::vector<double>> yolo_thresholds {
    {"yolo-v3-tf", {yolo_v3_confidence_threshold, yolo_v3_iou_threshold}},
    {"yolo-v3-tiny-tf", {yolo_v3_confidence_threshold, yolo_v3_iou_threshold}},
    {"yolo-v8", {yolo_v8_confidence_threshold, yolo_v8_iou_threshold}}
  };

  // A map for parsing and resizing parameters dependent on the yolo model
  const std::unordered_map<std::string, parsing_resizing_params_t> parsingResizingParams {
    {"yolo-v3-tf", yolo_v3},
    {"yolo-v3-tiny-tf", yolo_v3},
    {"yolo-v8", yolo_v8}
  };

  const std::unordered_map<std::string, std::vector<double>> dst_image_sizes {
    {"yolo-v3-tf", {416, 416}},
    {"yolo-v3-tiny-tf", {416, 416}},
    {"yolo-v8", {640, 640}}
  };

  // Dimensions of grid cells and anchor boxes.
  const std::unordered_map<std::string, std::unordered_map<unsigned, std::vector<double>>> anchor_sizes{
      {
          "yolo-v3-tiny-tf",
          {{13, {81, 82, 135, 169, 344, 319}}, {26, {23, 27, 37, 58, 81, 82}}},
      },
      {
          "yolo-v3-tf",
          {{13, {116, 90, 156, 198, 373, 326}}, {26, {30, 61, 62, 45, 59, 119}}, {52, {10, 13, 16, 30, 33, 23}}},
      }};
  const std::unordered_map<std::string, std::vector<unsigned>> grid_sizes = {
      {"yolo-v3-tiny-tf", {26, 13}},
      {"yolo-v3-tf", {13, 26, 52}},
      {"yolo-v8", {20, 40, 80}},
  };

  // Use of `boundary` in IoU calculation.
  const int boundary = 1;

  // IoU threshold for metrics calculation.
  const double pascal_voc_metric = 0.5;
  const std::vector<double> coco_metric = {0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95};

  // AP calculation
  const unsigned ap_interval = 11;
  const unsigned coco_interval = 101;
} yolo_meta;

// Stores intermediate statistics for AP calculation. AP's are calculated from
// true-positive, false-positive, and the number of targets, sorted
// by the class score of the predicted bounding box.
typedef struct _map_stats {
  int num_gt_object;
  std::vector<double> scores;
  std::vector<int> true_positive;
  std::vector<int> false_positive;

  _map_stats() { this->num_gt_object = 0; }
} mAPStats;

// Return type of function `validate_yolo`.
struct metrics {
  std::vector<mAPStats> map;
  Tensor2d<mAPStats> coco;
};

// =============================================================================
// FUNCTION DECLARATIONS
// =============================================================================

// Returns `true` if the given YOLO graph, `name`, is supported. Else, `false` is returned.
bool inline is_yolo_supported(std::string &name) {
  return (std::find(supported_yolo_versions.begin(), supported_yolo_versions.end(), name) != supported_yolo_versions.end());
}

/**
 * @brief Attempts to do some type of checking if a graph is actually a yolo graph if yolo_version is set.
 * Note that this is not a comprehensive check, just a basic sanity check, best to just use the correct YOLO graph for the correct YOLO version.
 * @param network The model to check
 * @param yolo_version The version of yolo to check against
 * @return true if the model is a yolo model of the specified version, false otherwise
 */
template <class T>
bool CheckIsYOLO(const T& network, const std::string& yolo_version) {
  const std::vector<unsigned>& expected_grid_sizes = yolo_meta.grid_sizes.at(yolo_version);

  if (yolo_version == "yolo-v8") {
    int64_t total_prediction_boxes = 0;
    for (unsigned grid_size : expected_grid_sizes) {
      total_prediction_boxes += static_cast<int64_t>(grid_size) * grid_size;
    }
    for (auto& output : network.outputs()) {
      if (output.get_partial_shape()[2] != total_prediction_boxes) return false;
    }
    return true;
  }

  // Match each output head to its grid size
  std::vector<unsigned> unmatched_grid_sizes = expected_grid_sizes;
  for (auto& output : network.outputs()) {
    const ov::PartialShape& shape = output.get_partial_shape();
    ov::Dimension H = shape[2];
    ov::Dimension W = shape[3];
    if (ov::layout::get_layout(output).to_string() == "[N,H,W,C]") {
      H = shape[1];
      W = shape[2];
    }
    if (H != W) return false;
    const int64_t grid_size = H.get_length();
    const auto match = std::find(unmatched_grid_sizes.begin(), unmatched_grid_sizes.end(), grid_size);
    if (match == unmatched_grid_sizes.end()) return false;
    unmatched_grid_sizes.erase(match);
  }
  return unmatched_grid_sizes.empty();
}

// Initializes runtime variables in `runtime_vars` struct.
void set_runtime(std::string name,
                 unsigned niter,
                 unsigned batch_size,
                 const std::string &input_loc,
                 const std::string &annotation_loc,
                 FormatReader::Reader::ResizeType &resize_type);

// Wrapper of the function `validate_yolo`. This function prepares data and dispatches metrics calculations for each
// validation image, accumulates metrics results, and returns the batched mAP and COCO AP.
std::pair<double, double> validate_yolo_wrapper(std::map<std::string, ov::TensorVector> &raw_results,
                                                const std::vector<ov::Output<const ov::Node>> &result_layout,
                                                std::vector<std::string> input_files,
                                                const std::string& export_dir);
#endif  // DLA_BENCHMARK__OBJECT_DETECTION_H_
