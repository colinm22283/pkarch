#include <print.h>

char test_hex_lut[16] = "0123456789ABCDEF";

void test_print_str(const char * str) {
    for (int i = 0; str[i] != '\0'; i++) {
        *(volatile char *) 0x10000000 = str[i];
    }
}

void test_print_hex(unsigned int num) {
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

unsigned int __umodsi3(unsigned int a, unsigned int b) {
    if (b == 0) return 0;
    
    unsigned int quotient = 0;
    unsigned int remainder = 0;
    
    for (int i = 31; i >= 0; i--) {
        remainder <<= 1;
        remainder |= (a >> i) & 1;
        if (remainder >= b) {
            remainder -= b;
            quotient |= (1U << i);
        }
    }
    return remainder;
}

unsigned int __udivsi3(unsigned int dividend, unsigned int divisor) {
    if (divisor == 0) {
        return 0;
    }
    
    unsigned int quotient = 0;
    unsigned int remainder = 0;
    
    for (int i = 31; i >= 0; i--) {
        remainder <<= 1;
        remainder |= (dividend >> i) & 1;
        if (remainder >= divisor) {
            remainder -= divisor;
            quotient |= (1U << i);
        }
    }
    return quotient;
}

void test_print_dec(unsigned int num) {
    char buf[16];
    buf[15] = '\0';

    int i;
    for (i = 14; true; i--) {
        buf[i] = '0' + (num % 10);
        num /= 10;

        if (num == 0) break;
    }

    test_print_str(buf + i);
}

int main() {
    test_print_str("Hello world\n");

    test_print_str("Hello\n");

    test_print_hex(0x1FAFAFAF);
    test_print_str("\n");

    int a = 1, b = 1;
    for (int i = 0; i < 64; i++) {
        test_print_hex(i);
        test_print_str(": ");
        test_print_hex(a);
        test_print_str("\n");

        int c = a;
        a = b;
        b += c;
    }
}

