#ifndef OS_H
#define OS_H

#if defined(_MSC_VER)
#define OT_DECORATED(ident, ...) __VA_ARGS__ ident
#define OT_ALIGNED(alignment) __declspec(align(alignment))
#define OT_NORETURN __declspec(noreturn)
#else
#define OT_DECORATED(ident, ...) ident __VA_ARGS__
#define OT_ALIGNED(alignment) __attribute__((packed, aligned(alignment)))
#define OT_NORETURN __attribute__((noreturn))
#endif

#endif
