#include <stdio.h>
#include <stddef.h>

char getc(void) {
    return *(volatile char *) 0x10000000;
}

char * gets(char * buf, int size) {
    int i;

    for (i = 0; i < size - 1; i++) {
        char c = getc();

        buf[i] = c;

        if (c == '\n') break;
    }

    buf[i] = '\0';

    if (i == 0) return NULL;
    else return buf;
}

