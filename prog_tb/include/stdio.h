#pragma once

#include <stdarg.h>

void printf(const char * format, ...);

int vprintf(const char * restrict format, va_list args);

void putchar(char c);
void puts(const char * str);

char getc(void);
char * gets(char * buf, int size);

typedef char FILE;
#define stderr NULL
#define stdout NULL
static inline void fprintf(void *, const char * restrict format, ...) {
    va_list args;

    va_start(args, format);

    vprintf(format, args);

    va_end(args);
}

static inline int vfprintf(void *, const char * restrict format, va_list args) {
    return vprintf(format, args);
}

static inline void sprintf(char *, const char * restrict format, ...) { }

static inline void fflush(void *) { }

