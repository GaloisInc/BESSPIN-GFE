#include "peripheral_commands.h"

void secure_boot_read32_command_failed(volatile uint32_t *addr, uint32_t actual_value) {
    // Do nothing. This function is here only for GDB to break on.
    (void)addr;
    (void)actual_value;
}

world_t secure_boot_cmd_read32(volatile uint32_t *addr, uint32_t mask, uint32_t expected_value,
                               world_t world, bool* no_failures) {
#ifndef SAW_BUILD
    uint32_t value = *addr;
    if ((value & mask) != expected_value) {
        secure_boot_read32_command_failed(addr, value);
        *no_failures = false;
        return world;
    }
#endif
    return world;
}

world_t secure_boot_cmd_write32(volatile uint32_t *addr, uint32_t mask, uint32_t value,
                                world_t world) {
#ifndef SAW_BUILD
    *addr = value | ((*addr) & mask);
#endif
    return world;
}

world_t secure_boot_cmd_fence(world_t world) {
#ifndef SAW_BUILD
    __asm__ volatile("fence" ::: "memory");
#endif
    return world;
}

world_t secure_boot_cmd_copy(uint8_t *dst, volatile uint8_t *src, uint32_t size,
                             world_t world) {
#ifndef SAW_BUILD
    while(size-- > 0) dst[size] = src[size];
#endif
    return world;
}

world_t secure_boot_cmd_sha256(uint8_t *addr, uint32_t size, sha256_bytes e,
                               world_t world, bool* no_failures) {
    uint8_t actual[SHA256_DIGEST_LENGTH] = {
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0};
#ifndef SAW_BUILD
    SHA256(addr, size, actual);
#endif
    uint8_t expected[SHA256_DIGEST_LENGTH] = {
        e.b00, e.b01, e.b02, e.b03, e.b04, e.b05, e.b06, e.b07,
        e.b10, e.b11, e.b12, e.b13, e.b14, e.b15, e.b16, e.b17,
        e.b20, e.b21, e.b22, e.b23, e.b24, e.b25, e.b26, e.b27,
        e.b30, e.b31, e.b32, e.b33, e.b34, e.b35, e.b36, e.b37};
    for(int i = 0; i < SHA256_DIGEST_LENGTH; i++)
        *no_failures = *no_failures && (actual[i] == expected[i]);
    return world;
}
