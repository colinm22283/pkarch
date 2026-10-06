#include <print.h>

int main() {
    print_hex(0x1FAFAFAF);
    print_str("\n");

    int a = 1, b = 1;
    for (int i = 0; i < 4; i++) {
        print_dec(i);
        print_str(": ");
        print_dec(a);
        print_str("\n");

        int c = a;
        a = b;
        b += c;
    }
}

