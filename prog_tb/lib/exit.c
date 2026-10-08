#include <unistd.h>

__attribute__((noreturn)) void exit(int code) {
    *(volatile int *) 0x10000004 = code;

    __builtin_unreachable();
}

