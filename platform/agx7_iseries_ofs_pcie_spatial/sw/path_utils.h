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

#ifndef PATH_UTILS_H
#define PATH_UTILS_H

#include <stddef.h>

// Return the directory containing filepath (e.g. dump_files/din.txt -> dump_files).
// Returns 0 on success, -1 if dirbuf is too small.
int path_dir_of(const char *filepath, char *dirbuf, size_t dirbuf_size);

// Return the final path component (e.g. dump_files/din.txt -> din.txt).
const char *path_basename(const char *filepath);

// Join dir and filename into outbuf (e.g. dump_files + din.txt -> dump_files/din.txt).
// Returns 0 on success, -1 if outbuf is too small.
int path_join(const char *dir, const char *filename, char *outbuf, size_t outbuf_size);

#endif // PATH_UTILS_H
