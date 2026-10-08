#include <print.h>

char hex_lut[16] = "0123456789ABCDEF";

void print_str(const char * str) {
    for (int i = 0; str[i] != '\0'; i++) {
        *(volatile char *) 0x10000000 = str[i];
    }
}

void print_hex(unsigned int num) {
    char buf[12];
    buf[11] = '\0';

    int i;
    for (i = 10; true; i--) {
        buf[i] = hex_lut[num % 16];
        num /= 16;

        if (num == 0) break;
    }

    print_str(buf + i);
}

void print_dec(unsigned int num) {
    char buf[16];
    buf[15] = '\0';

    int i;
    for (i = 14; true; i--) {
        buf[i] = '0' + (num % 10);
        num /= 10;

        if (num == 0) break;
    }

    print_str(buf + i);
}

