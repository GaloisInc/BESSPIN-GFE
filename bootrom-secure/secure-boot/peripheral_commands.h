#pragma once

#include <stdint.h>
#include <stdbool.h>
#include "sha_256.h"

// This world type isn't actually used in the computation, it's just used in the
// verification.
typedef int world_t;

// value == *addr & mask
world_t secure_boot_cmd_read32(volatile uint32_t *addr, uint32_t mask, uint32_t value,
                               world_t world, bool* no_failures);

// *addr = value | ((*addr) & mask)
world_t secure_boot_cmd_write32(volatile uint32_t *addr, uint32_t mask, uint32_t value,
                                world_t world);

// memcpy, but gives us a handle to check that
// 1. things happen in the right order (the world_t stuff)
// 2. all destinations are in RAM
world_t secure_boot_cmd_copy(uint8_t *dst, volatile uint8_t *src, uint32_t size,
                             world_t world);

// This looks unnatural from a C API design perspective -- why not use an
// array? But from a verification perspective, it's very nice, as it is very
// easy to see statically that the "array" has exactly the right length, even
// when passing across function boundaries.
//
// Read the indices in octal.
typedef struct {
    uint8_t b00, b01, b02, b03, b04, b05, b06, b07,
            b10, b11, b12, b13, b14, b15, b16, b17,
            b20, b21, b22, b23, b24, b25, b26, b27,
            b30, b31, b32, b33, b34, b35, b36, b37;
} sha256_bytes;

// SHA256(addr, size) == expected
world_t secure_boot_cmd_sha256(uint8_t *addr, uint32_t size, sha256_bytes expected,
                               world_t world, bool* no_failures);

world_t secure_boot_cmd_fence(world_t world);
