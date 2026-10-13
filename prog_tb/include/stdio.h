#pragma once

#include <stdarg.h>

void printf(const char * format, ...);

int vprintf(const char * restrict format, va_list args);

void putchar(char c);
void puts(const char * str);

char getc(void);
char * gets(char * buf, int size);

