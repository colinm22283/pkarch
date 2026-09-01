#include <print.h>

char test_hex_lut[16] = "0123456789ABCDEF";

void test_print_str(const char * str) {
    for (int i = 0; str[i] != '\0'; i++) {
        *(volatile char *) 0x10000000 = str[i];
    }
}

void test_print_hex(int num) {
    int size = 0;
    char buf[12];
    buf[11] = '\0';

    int i;
    for (i = 10; true; i--) {
        buf[i] = test_hex_lut[num % 16];
        num /= 16;

        if (num == 0) break;
    }

    test_print_str(buf + i);
}

int main() {
    /* print_str("Hello world\n"); */

    test_print_str("Hello\n");

    /* int a = 1, b = 1; */
    /* for (int i = 0; i < 40; i++) { */
        /* test_print_hex(a); */
        /* print_char('\n'); */

        /* int c = a; */
        /* a = b; */
        /* b += c; */
    /* } */
}

