#pragma once

#define SB_LIKELY(cond) __builtin_expect((cond), 1)
#define SB_UNLIKELY(cond) __builtin_expect((cond), 0)
