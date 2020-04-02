#include "sbassert.h"

void sb_assert_fail(const char* file, int line, const char* function,
                    const char* condition, const char* msg) {
    // GDB can break here and read out the arguments.
    (void)file;
    (void)line;
    (void)function;
    (void)condition;
    (void)msg;
    while (1) {
    }
}
