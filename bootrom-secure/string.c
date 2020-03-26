// We need to manually implement these, since we don't have a standard library.
// The compiler expects these functions to be here.

#include <stddef.h>

#ifndef SAW_BUILD

// The following functions were taken from libgcc. They are in the public
// domain.

// From
// https://github.com/gcc-mirror/gcc/blob/4d600d2551b85bbe282a4f94b7fbf04c6bfd6a49/libgcc/memcpy.c
void *memcpy(void *dest, const void *src, size_t len) {
    char *d = dest;
    const char *s = src;
    while (len--) *d++ = *s++;
    return dest;
}

// From
// https://github.com/gcc-mirror/gcc/blob/4d600d2551b85bbe282a4f94b7fbf04c6bfd6a49/libgcc/memcmp.c
int memcmp(const void *str1, const void *str2, size_t count) {
    const unsigned char *s1 = str1;
    const unsigned char *s2 = str2;

    while (count-- > 0) {
        if (*s1++ != *s2++) return s1[-1] < s2[-1] ? -1 : 1;
    }
    return 0;
}

// From
// https://github.com/gcc-mirror/gcc/blob/4d600d2551b85bbe282a4f94b7fbf04c6bfd6a49/libgcc/memset.c
void *memset(void *dest, int val, size_t len) {
    unsigned char *ptr = dest;
    while (len-- > 0) *ptr++ = val;
    return dest;
}

#endif
