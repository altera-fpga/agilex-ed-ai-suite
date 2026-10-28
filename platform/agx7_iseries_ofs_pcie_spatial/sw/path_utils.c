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

#include "path_utils.h"

#include <stdio.h>
#include <string.h>

int path_dir_of(const char *filepath, char *dirbuf, size_t dirbuf_size) {
    const char *last_slash = strrchr(filepath, '/');

    if (last_slash == NULL) {
        if (dirbuf_size < 2) {
            return -1;
        }
        dirbuf[0] = '.';
        dirbuf[1] = '\0';
        return 0;
    }

    size_t dir_len = (size_t)(last_slash - filepath);
    if (dir_len == 0) {
        if (dirbuf_size < 2) {
            return -1;
        }
        dirbuf[0] = '/';
        dirbuf[1] = '\0';
        return 0;
    }

    if (dir_len >= dirbuf_size) {
        return -1;
    }

    memcpy(dirbuf, filepath, dir_len);
    dirbuf[dir_len] = '\0';
    return 0;
}

const char *path_basename(const char *filepath) {
    const char *last_slash = strrchr(filepath, '/');
    return last_slash ? last_slash + 1 : filepath;
}

int path_join(const char *dir, const char *filename, char *outbuf, size_t outbuf_size) {
    if (dir == NULL || filename == NULL || outbuf == NULL || outbuf_size == 0) {
        return -1;
    }

    int written = snprintf(outbuf, outbuf_size, "%s/%s", dir, filename);
    if (written < 0 || (size_t)written >= outbuf_size) {
        return -1;
    }

    return 0;
}
