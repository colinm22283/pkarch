#include <print.h>
#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>

void printf(const char * format, ...) {
    va_list args;

    va_start(args, format);

    vprintf(format, args);

    va_end(args);
}

int vprintf(const char * restrict format, va_list args) {
    bool in_field = false;

    for (size_t i = 0; format[i] != '\0'; i++) {
        if (in_field) {
            switch (format[i]) {
                case 'u': {
                    int v = va_arg(args, int);
                    print_dec(v);
                } break;
                case 'd': {
                    int v = va_arg(args, int);
                    print_sdec(v);
                } break;
                case 'i': {
                    int v = va_arg(args, int);
                    print_sdec(v);
                } break;

                case 'c': {
                    char v = va_arg(args, int);
                    print_char(v);
                } break;

                case 's': {
                    const char * v = va_arg(args, const char *);
                    print_str(v);
                } break;

                default: {
                    print_char('%');

                    print_char(format[i]);
                } break;
            }

            in_field = false;
        }
        else {
            if (format[i] == '%') in_field = true;
            else {
                print_char(format[i]);
            }
        }
    }
}
