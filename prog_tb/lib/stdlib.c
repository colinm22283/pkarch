#include <stdlib.h>
#include <string.h>

int atoi(const char * str) {
    int len;
    for (len = 0; str[len] >= '0' && str[len] <= '9'; len++);

    int acc = 0;
    int mul = 1;

    for (int i = len - 1; i >= 0; i--) {
        if (str[i] < '0' || str[i] > '9') return 0;

        acc += mul * (str[i] - '0');
    }

    return acc;
}

