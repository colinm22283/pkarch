#include <print.h>
#include <unistd.h>

char command[256];

int argc;
char * argv[16];

char getc(void) {
    return *(volatile char *) 0x10000000;
}

void get_command(void) {
    int i;

    for (i = 0; i < 255; i++) {
        command[i] = getc();

        if (command[i] == '\n') {
            break;
        }
    }

    command[i] = '\0';

    argc = 1;
    argv[0] = &command[0];

    for (i = 0; command[i] != '\0'; i++) {
        if (command[i] == ' ') {
            command[i] = '\0';
            argv[argc++] = &command[i + 1];
        }
    }
}

int strcmp(const char * a, const char * b) {
    for (int i = 0; 1; i++) {
        if (a[i] == '\0' && b[i] == '\0') return 0;

        unsigned char diff = (unsigned char) a[i] - (unsigned char) b[i];

        if (diff != 0) return diff;
    }
}

int stoi(const char * str) {
    char *endptr;
    errno = 0;
    
    long val = strtol(str, &endptr, 10);

    // Check for errors (no digits found or out of range)
    if ((errno == ERANGE && (val == LONG_MAX || val == LONG_MIN)) || (errno != 0 && val == 0)) {
        perror("stoi overflow/underflow");
        exit(EXIT_FAILURE);
    }

    if (endptr == str) {
        fprintf(stderr, "No digits found in string.\n");
        exit(EXIT_FAILURE);
    }

    // Check if value fits in a standard integer
    if (val > INT_MAX || val < INT_MIN) {
        fprintf(stderr, "Value out of int range.\n");
        exit(EXIT_FAILURE);
    }

    return (int)val;
}

int main() {
    while (true) {
        print_str("> ");
        get_command();

        if (strcmp(argv[0], "args") == 0) {
            for (int i = 1; i < argc; i++) {
                print_str(argv[i]);
                print_str("\n");
            }
        }
        else if (strcmp(argv[0], "exit") == 0) {
            print_str("Bye!\n");

            exit(0);
        }
        else {
            print_str("Unrecognized command\n");
        }
    }
}

