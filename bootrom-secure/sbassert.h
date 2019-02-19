#pragma once

#include "expect.h"

void sb_assert_fail(const char* file, int line, const char* function,
                    const char* condition, const char* msg);

// The SB stands for secure boot.
// Unlike a normal assert.h assert, this SHOULD ALWAYS BE ENABLED! Do NOT
// DISABLE THIS ASSERT.
#define SB_ASSERT(cond, msg)                                              \
    do {                                                                  \
        if (SB_UNLIKELY(!(cond))) {                                       \
            sb_assert_fail(__FILE__, __LINE__, __FUNCTION__, #cond, msg); \
        }                                                                 \
    } while (0)
