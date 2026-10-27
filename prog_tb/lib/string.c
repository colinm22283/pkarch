#include <string.h>

int strcmp(const char * a, const char * b) {
    int i = 0;

    while (true) {
        int diff = a[i] - b[i];

        if (diff != 0) return diff;

        if (a[i] == '\0') {
            return 0;
        }

        i++;
    }
}

int strlen(const char * str) {
    int i;

    for (i = 0; str[i] != '\0'; i++);

    return i;
}

void strcpy(char * dst, const char * src) {
    int i;
    for (i = 0; src[i] != '\0'; i++) {
        dst[i] = src[i];
    }
    dst[i] = '\0';
}

void memcpy(void * _dst, const void * _src, int size) {
    char * dst = _dst;
    const char * src = _src;

    for (int i = 0; i < size; i++) {
        dst[i] = src[i];
    }
}

