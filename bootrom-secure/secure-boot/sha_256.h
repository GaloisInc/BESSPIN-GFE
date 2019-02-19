#pragma once

#include <stddef.h>
#include <stdint.h>

#define SHA256_DIGEST_LENGTH 32

void SHA256(const uint8_t *d, size_t n, uint8_t *md);
