#include <stdio.h>
#include <print.h>

void putchar(char c) {
    print_char(c);
}

void puts(const char * str) {
    print_str(str);
    print_char('\n');
}

