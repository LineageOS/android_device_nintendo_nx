// SPDX-License-Identifier: Apache-2.0
/**
 * @name recovery_updater.cpp
 * @author Thomas Makin
 * @brief NX-specific edify updater command additions.
 * @copyright 2024 The LineageOS Project
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <android-base/logging.h>

#include "edify/expr.h"
#include "otautil/error_code.h"

#define MAGIC_OFFSET 4096
#define MAGIC_SZ 4
#define MAGIC "gDla" // 67446c61

Value *CheckSuperFn(const char *name, State *state,
        [[maybe_unused]] const std::vector<std::unique_ptr<Expr>> &argv)
{
    FILE *fd = fopen("/dev/block/by-name/super", "r");
    char read_magic[MAGIC_SZ+1];

    if(!fd)
        return ErrorAbort(state, kArgsParsingFailure, "%s(): Failed to get file", name);

    fseek(fd, MAGIC_OFFSET, SEEK_SET);
    fgets(read_magic, (MAGIC_SZ + 1), fd);

    LOG(INFO) << name << ": magic read from file: " << read_magic;

    fclose(fd);

    if(!strcmp(read_magic, MAGIC))
        return StringValue("SUCCESS");

    return StringValue("");
}

void Register_librecovery_updater_nx()
{
    RegisterFunction("nx.check_super", CheckSuperFn);
}
