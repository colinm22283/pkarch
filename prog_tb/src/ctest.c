#include <print.h>

int main() {
    print_str("Hello world\n");

    int a = 1, b = 1;
    for (int i = 0; i < 1000000; i++) {
        print_hex(a);

        int c = a;
        a = b;
        b += c;
    }
}

