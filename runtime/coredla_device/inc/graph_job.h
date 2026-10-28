// Copyright 2020-2023 Altera Corporation.
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

#ifndef GRAPH_JOB_H
#define GRAPH_JOB_H

#include <memory>
#include "batch_job.h"
using namespace std;
class GraphJob {
 public:
  // Returns an unused batch job object
  // If all batch jobs are used, returns null
  virtual std::shared_ptr<BatchJob> GetBatchJob() = 0;

  virtual ~GraphJob(){}
};

#endif
