#ifndef OS_H
#define OS_H

#if defined(_MSC_VER)
#include <intrin.h>

#pragma intrinsic(_BitScanReverse)

#define OT_DECORATED(ident, ...) __VA_ARGS__ ident
#define OT_ALIGNED(alignment) __declspec(align(alignment))
#define OT_NORETURN __declspec(noreturn)

static inline int OT_LEADING_ZERO_BITS(unsigned int num)
{
    unsigned long pos;
    if (_BitScanReverse(&pos, num) == 0)
    {
        return -1;
    }
    else
    {
        return 31 - pos;
    }
}
#else
#define OT_DECORATED(ident, ...) ident __VA_ARGS__
#define OT_ALIGNED(alignment) __attribute__((packed, aligned(alignment)))
#define OT_LEADING_ZERO_BITS(num) __builtin_clz(num)
#define OT_NORETURN __attribute__((noreturn))
#endif

#endif
