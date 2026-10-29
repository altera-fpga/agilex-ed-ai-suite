// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: This file defines and implements functions to calculate top1 and top5 scores.

#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <utility>

class TopResultsAnalyser {
 public:
  static bool get_top_results(const std::string groundtruth_loc, const std::string results_loc, uint32_t batchSize, const std::string& export_dir) {
    // This function loads the output results from a file,
    // The dla benchmark currently uses the get_top_results(string, vector<float>, uint)
    // This function is kept as it can be used to assess accuracy post runtime,
    // although it seems awfully similar to the other version of get_top_results().
    const std::string accuracy_results_loc = export_dir + "accuracy_report.txt";
    std::ofstream accuracy_file(accuracy_results_loc);

    if (!accuracy_file.is_open()) {
      throw std::invalid_argument("Unable to open accuracy file.");
    }

    std::ifstream groundtruth_file(groundtruth_loc);
    int groundtruth_lineno = 0;

    if (!groundtruth_file.is_open()) {
      throw std::invalid_argument("Unable to open groundtruth file.");
    }

    std::ifstream results_file(results_loc);

    if (!results_file.is_open()) {
      throw std::invalid_argument("Unable to open result file.");
    }

    std::string results_line;
    std::vector<float> results;
    while (std::getline(results_file, results_line)) {
      const float result = std::stof(results_line);
      results.push_back(result);
    }

    if (results.size() % batchSize != 0) {
      std::cout << "Results size = " << results.size() << " Batch size = " << batchSize << std::endl;
      throw std::invalid_argument("Results size is not a multiple of batch size");
    }

    typedef std::pair<uint64_t, float> CatProbPair;
    const uint64_t img_output_size = results.size() / batchSize;
    uint32_t top1_correct_guesses = 0;
    uint32_t top5_correct_guesses = 0;
    const auto top_n = fmin(5, img_output_size);
    for (uint32_t img = 0; img < batchSize; img++) {
      accuracy_file << "image " << img << " top 5:" << std::endl;

      const auto start_addr = img_output_size * img;
      std::vector<CatProbPair> top5;
      for (int i = 0; i < top_n; i++) {
        top5.push_back(std::make_pair(i, results[start_addr + i]));
      }

      for (uint64_t i = 5; i < img_output_size; i++) {
        const auto e = results[start_addr + i];
        auto min_ele = &top5.at(0);
        for (size_t j = 1; j < top5.size(); j++) {
          if (top5.at(j).second < min_ele->second) {
            min_ele = &top5.at(j);
          }
        }
        if (e > min_ele->second) {
          *min_ele = std::make_pair(i, e);
        }
      }

      // sort descending
      std::sort(
          top5.begin(), top5.end(), [](const CatProbPair& a, const CatProbPair& b) { return a.second > b.second; });
      for (const auto& pair : top5) {
        accuracy_file << pair.first << " : " << pair.second << std::endl;
      }
      std::string line;
      std::getline(groundtruth_file, line);
      ++groundtruth_lineno;
      uint64_t truth;
      try {
        truth = std::stoi(line);
      } catch (const std::invalid_argument& ia) {
        OPENVINO_THROW("Unable to parse line ", groundtruth_lineno,
                       " of the ground truth file ", groundtruth_loc);
      }
      accuracy_file << truth << " : truth" << std::endl;
      top1_correct_guesses += (top5.at(0).first == truth);

      uint64_t i = 1;
      for (const auto& guess : top5) {
        if (guess.first == truth && i < img_output_size) {
          top5_correct_guesses += 1;
          break;
        }
        i += 1;
      }
    }

    const auto top_n_string = [&](std::ostream& stream, const double correct_guesses, const uint32_t N) {
      stream << "top" << N << " accuracy: " << (correct_guesses * 100.0) / (batchSize) << " %" << std::endl;
    };

    accuracy_file << "====================" << std::endl;

    top_n_string(accuracy_file, top1_correct_guesses, 1);
    top_n_string(std::cout, top1_correct_guesses, 1);
    if (2 < img_output_size && img_output_size < 6) {
      top_n_string(accuracy_file, top5_correct_guesses, img_output_size - 1);
      top_n_string(std::cout, top5_correct_guesses, img_output_size - 1);
    } else if (6 <= img_output_size) {
      top_n_string(accuracy_file, top5_correct_guesses, 5);
      top_n_string(std::cout, top5_correct_guesses, 5);
    }
    // Pretty conservative, below 50% would indicate something is very wrong
    const double THRESHOLD = 50.0;
    double top1_accuracy = (top1_correct_guesses * 100.0) / batchSize;
    if (top1_accuracy < THRESHOLD) {
      slog::err << "FAILED: Top1 accuracy " << top1_accuracy
                << "% is below threshold " << THRESHOLD << "%" << slog::endl;
      return false;
    }
    double top5_accuracy = (top5_correct_guesses * 100.0) / batchSize;
    if (top5_accuracy < THRESHOLD) {
      slog::err << "FAILED: Top5 accuracy " << top5_accuracy
                << "% is below threshold " << THRESHOLD << "%" << slog::endl;
      return false;
    }
    return true;
  }

  static bool get_top_results(const std::string groundtruth_loc, std::vector<float> results, uint32_t batchSize, const std::string& export_dir) {
    // This function takes the output results directly from runtime in a vector
    // The dla benchmark currently uses this version of get_top_results
    const std::string accuracy_results_loc = export_dir + "accuracy_report.txt";
    std::ofstream accuracy_file(accuracy_results_loc);

    if (!accuracy_file.is_open()) {
      throw std::invalid_argument("Unable to open accuracy file.");
    }

    std::ifstream groundtruth_file(groundtruth_loc);
    int groundtruth_lineno = 0;

    if (!groundtruth_file.is_open()) {
      throw std::invalid_argument("Unable to open groundtruth file.");
    }

    if (results.size() % batchSize != 0) {
      std::cout << "Results size = " << results.size() << " Batch size = " << batchSize << std::endl;
      throw std::invalid_argument("Results size is not a multiple of batch size");
    }

    typedef std::pair<int, float> CatProbPair;
    const int img_output_size = results.size() / batchSize;
    uint32_t top1_correct_guesses = 0;
    uint32_t top5_correct_guesses = 0;
    const auto top_n = fmin(5, img_output_size);
    for (uint32_t img = 0; img < batchSize; img++) {
      accuracy_file << "image " << img << " top 5:" << std::endl;

      const auto start_addr = img_output_size * img;
      std::vector<CatProbPair> top5;
      for (int i = 0; i < top_n; i++) {
        top5.push_back(std::make_pair(i, results[start_addr + i]));
      }

      for (int i = 5; i < img_output_size; i++) {
        const auto e = results[start_addr + i];
        auto min_ele = &top5.at(0);
        for (size_t j = 1; j < top5.size(); j++) {
          if (top5.at(j).second < min_ele->second) {
            min_ele = &top5.at(j);
          }
        }
        if (e > min_ele->second) {
          *min_ele = std::make_pair(i, e);
        }
      }

      // sort descending
      std::sort(
          top5.begin(), top5.end(), [](const CatProbPair& a, const CatProbPair& b) { return a.second > b.second; });
      for (const auto& pair : top5) {
        accuracy_file << pair.first << " : " << pair.second << std::endl;
      }
      std::string line;
      std::getline(groundtruth_file, line);
      ++groundtruth_lineno;
      int truth;
      try {
        truth = std::stoi(line);
      } catch (const std::invalid_argument& ia) {
        OPENVINO_THROW("Unable to parse line ", groundtruth_lineno,
                        " of the ground truth file ", groundtruth_loc);
      }
      accuracy_file << truth << " : truth" << std::endl;
      top1_correct_guesses += top5.at(0).first == truth;

      int i = 1;
      for (const auto& guess : top5) {
        if (guess.first == truth && i < img_output_size) {
          top5_correct_guesses += 1;
          break;
        }
        i += 1;
      }
    }

    const auto top_n_string = [&](std::ostream& stream, const double correct_guesses, const uint32_t N) {
      stream << "top" << N << " accuracy: " << (correct_guesses * 100.0) / (batchSize) << " %" << std::endl;
    };

    accuracy_file << "====================" << std::endl;

    top_n_string(accuracy_file, top1_correct_guesses, 1);
    top_n_string(std::cout, top1_correct_guesses, 1);
    if (2 < img_output_size && img_output_size < 6) {
      top_n_string(accuracy_file, top5_correct_guesses, img_output_size - 1);
      top_n_string(std::cout, top5_correct_guesses, img_output_size - 1);
    } else if (6 <= img_output_size) {
      top_n_string(accuracy_file, top5_correct_guesses, 5);
      top_n_string(std::cout, top5_correct_guesses, 5);
    }
    // Pretty conservative, below 20% would indicate something is very wrong
    const double THRESHOLD = 20.0;
    double top1_accuracy = (top1_correct_guesses * 100.0) / batchSize;
    if (top1_accuracy < THRESHOLD) {
      slog::err << "FAILED: Top1 accuracy " << top1_accuracy
                << "% is below threshold " << THRESHOLD << "%" << slog::endl;
      return false;
    }
    double top5_accuracy = (top5_correct_guesses * 100.0) / batchSize;
    if (top5_accuracy < THRESHOLD) {
      slog::err << "FAILED: Top5 accuracy " << top5_accuracy
                << "% is below threshold " << THRESHOLD << "%" << slog::endl;
      return false;
    }

    return true;
  }
};
