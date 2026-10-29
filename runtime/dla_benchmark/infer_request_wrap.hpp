// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: Wrappers for single inference requests and queues of inference requests.
//              Largely based off OpenVino's benchmark_app/infer_request_wrap.hpp
//              [openvinotoolkit/openvino › samples/cpp/benchmark_app/infer_request_wrap.hpp]
//              Note: Not all functions of ov::InferRequest is wrapped. More functions can be added.

#pragma once

#include <atomic>
#include <condition_variable>
#include <functional>
#include <map>
#include <memory>
#include <mutex>
#include <queue>
#include <string>
#include <vector>
#include <algorithm>
#include <chrono>

#include <openvino/openvino.hpp>
#include "statistics_report.hpp"
#include "utils.hpp"

#include "dla_performance_profiler.hpp"

typedef std::function<void(size_t id, const double latency, const std::exception_ptr& ptr)> QueueCallbackFunction;

// Wrapper class for ov::InferRequest. Handles asynchronous callbacks
class InferReqWrap final {
 public:
  using Ptr = std::shared_ptr<InferReqWrap>;

  ~InferReqWrap() = default;

  explicit InferReqWrap(ov::CompiledModel& model, size_t id, QueueCallbackFunction callbackQueue)
      : _request(model.create_infer_request()), _id(id), _callbackQueue(callbackQueue) {
#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
    _model_name = model.get_property(ov::model_name.name()).as<std::string>();
#endif
    _request.set_callback([&](const std::exception_ptr& ptr) {
      _endTime = Time::now();
      _callbackQueue(_id, get_execution_time_in_milliseconds(), ptr);
    });
  }

  void start_async() {
    _startTime = Time::now();
#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
    _traceId = _traceIdCounter++;
    PerformanceProfiler::get_instance().RegisterActiveTraceId(_model_name, static_cast<uint32_t>(_id), _traceId);
#endif
    TRACE_SCOPE_ENTER("InferenceRequest", _traceId, _id, _model_name);
    _request.start_async();
  }

  void wait() { _request.wait(); }

  void infer() {
    _startTime = Time::now();
    _request.infer();
    _endTime = Time::now();
    _callbackQueue(_id, get_execution_time_in_milliseconds(), nullptr);
  }

  std::vector<ov::ProfilingInfo> get_performance_counts() { return _request.get_profiling_info(); }

  ov::Tensor get_tensor(const std::string& name) { return _request.get_tensor(name); }
  ov::Tensor get_tensor(const ov::Output<const ov::Node>& port) { return _request.get_tensor(port); }

  double get_execution_time_in_milliseconds() const {
    auto execTime = std::chrono::duration_cast<ns>(_endTime - _startTime);
    return static_cast<double>(execTime.count()) * 0.000001;
  }

  void set_tensor(const std::string& name, const ov::Tensor& data) { _request.set_tensor(name, data); }

  void set_tensor(const ov::Output<const ov::Node>& port, const ov::Tensor& data) { _request.set_tensor(port, data); }

  ov::Tensor get_output_tensor() { return _request.get_output_tensor(); }
  ov::Tensor get_output_tensor(size_t idx) { return _request.get_output_tensor(idx); }

 private:
  ov::InferRequest _request;
  Time::time_point _startTime;
  Time::time_point _endTime;
  size_t _id;
  QueueCallbackFunction _callbackQueue;

#ifdef OPT_ENABLE_PERFORMANCE_PROFILER

 public:
  uint32_t get_trace_id() const { return _traceId; }
  std::string get_model_name() const { return _model_name; }

 private:
  std::string _model_name;
  uint32_t _traceId = 0;
  static inline std::atomic<uint32_t> _traceIdCounter{0};
#endif
};

// Handles a queue of inference requests.
class InferRequestsQueue final {
 public:
  InferRequestsQueue(ov::CompiledModel& model, size_t nireq, size_t model_number = 0, bool collect_perf_counts = false)
      : _collectPerfCounts(collect_perf_counts) {
    for (size_t id = 0; id < nireq; id++) {
      requests.push_back(std::make_shared<InferReqWrap>(model,
                                                        id,
                                                        std::bind(&InferRequestsQueue::put_idle_request,
                                                                  this,
                                                                  std::placeholders::_1,
                                                                  std::placeholders::_2,
                                                                  std::placeholders::_3)));
      _idleIds.push(id);
    }
#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
    if (_collectPerfCounts) {
      _perfAggregates.resize(nireq);
    }
    reset_times();
#endif
  }

  ~InferRequestsQueue() {
    // Inference Request guarantee that it will wait for all asynchronous internal tasks in destructor
    // So it should be released before any context that the request can use inside internal asynchronous tasks
    // For example all members of InferRequestsQueue would be destroyed before `requests` vector
    // So requests can try to use this members from `put_idle_request()` that would be called from request callback
    // To avoid this we should move this vector declaration after all members declaration or just clear it manually in
    // destructor
    requests.clear();
  }

  void reset_times() {
    _startTime = Time::time_point::max();
    _endTime = Time::time_point::min();
    _latencies.clear();
  }

  double get_durations_in_milliseconds() {
    return std::chrono::duration_cast<ns>(_endTime - _startTime).count() * 0.000001;
  }

  void put_idle_request(size_t id, const double latency, const std::exception_ptr& ptr = nullptr) {
    std::unique_lock<std::mutex> lock(_mutex);
    if (ptr) {
      inferenceException = ptr;
    } else {
#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
      if (_collectPerfCounts) {
        try {
          const auto perf_counts = requests.at(id)->get_performance_counts();
          aggregate_perf_counts(perf_counts);
        } catch (const std::exception&) {
          // Ignore profiling errors to avoid breaking inference flow
        }
      }
#endif
      _latencies.push_back(latency);
      _idleIds.push(id);
      _endTime = std::max(Time::now(), _endTime);

    // If the inference run successfully completed we want to know what the end time is
    TRACE_SCOPE_EXIT("InferenceRequest", requests.at(id)->get_trace_id(), id, requests.at(id)->get_model_name());
    }
    _cv.notify_one();
  }

  InferReqWrap::Ptr get_idle_request() {
    std::unique_lock<std::mutex> lock(_mutex);
    _cv.wait(lock, [this] {
      if (inferenceException) {
        std::rethrow_exception(inferenceException);
      }
      return _idleIds.size() > 0;
    });
    auto request = requests.at(_idleIds.front());
    _idleIds.pop();
    _startTime = std::min(Time::now(), _startTime);
    return request;
  }

  void wait_all() {
    std::unique_lock<std::mutex> lock(_mutex);
    _cv.wait(lock, [this] {
      if (inferenceException) {
        std::rethrow_exception(inferenceException);
      }
      return _idleIds.size() == requests.size();
    });
  }

  std::vector<double>& get_latencies() { return _latencies; }

#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
  std::vector<RuntimeAnalyzer::LayerInfo> get_average_performance_counts(size_t id) const {
    if (!_collectPerfCounts || id >= _perfAggregates.size() || _perfAggregates.at(id).empty()) {
      // Return raw performance counts if no aggregation was successfully collected
      const std::vector<ov::ProfilingInfo> raw_counts = requests.at(id)->get_performance_counts();
      std::vector<RuntimeAnalyzer::LayerInfo> layer_infos;
      layer_infos.reserve(raw_counts.size());
      for (const auto& pi : raw_counts) {
        RuntimeAnalyzer::LayerInfo info;
        info.node_name = pi.node_name;
        info.layer_type = pi.node_type;
        info.exec_type = pi.exec_type;
        info.layer_status = pi.status == ov::ProfilingInfo::Status::EXECUTED ? "EXECUTED" : "NOT_EXECUTED";
        info.exec_time = static_cast<double>(pi.real_time.count());
        layer_infos.push_back(info);
      }
      return layer_infos;
    }

    std::vector<RuntimeAnalyzer::LayerInfo> averaged;
    averaged.reserve(_perfAggregates.at(id).size());
    for (const auto& entry : _perfAggregates.at(id)) {
      const auto& agg = entry.second;
      if (agg.count == 0) {
        continue;
      }
      RuntimeAnalyzer::LayerInfo info;
      info.node_name = entry.first;
      info.layer_type = agg.layer_type;
      info.exec_type = agg.exec_type;
      info.layer_status = agg.status == ov::ProfilingInfo::Status::EXECUTED ? "EXECUTED" : "NOT_EXECUTED";
      info.exec_time = agg.real_time_sum / agg.count;
      averaged.push_back(info);
    }
    return averaged;
  }

#endif

  Time::time_point get_start_time() { return _startTime; }

  Time::time_point get_end_time() { return _endTime; }

  std::vector<InferReqWrap::Ptr> requests;

 private:
#ifdef OPT_ENABLE_PERFORMANCE_PROFILER
  struct PerfAggregate {
    double real_time_sum = 0.0;
    size_t count = 0;
    ov::ProfilingInfo::Status status = ov::ProfilingInfo::Status::NOT_RUN;
    std::string layer_type;
    std::string exec_type;
  };

  std::vector<std::map<std::string, PerfAggregate>> _perfAggregates;

  void aggregate_perf_counts(const std::vector<ov::ProfilingInfo>& perf_counts, size_t id = 0) {
    for (const auto& pi : perf_counts) {
      auto& agg = _perfAggregates[id][pi.node_name];
      agg.real_time_sum += static_cast<double>(pi.real_time.count());
      agg.count += 1;
      agg.status = pi.status;
      agg.layer_type = pi.node_type;
      agg.exec_type = pi.exec_type;
    }
  }

#endif

  bool _collectPerfCounts = false;
  std::queue<size_t> _idleIds;
  std::mutex _mutex;
  std::condition_variable _cv;
  Time::time_point _startTime;
  Time::time_point _endTime;
  std::vector<double> _latencies;
  std::exception_ptr inferenceException = nullptr;
};
