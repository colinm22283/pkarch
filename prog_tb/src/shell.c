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

int strlen(const char * str) {
    int i;
    for (i = 0; str[i] != '\0'; i++);
    return i;
}

int stoi(const char * str) {
    int  len = strlen(str);
    long mul = 1;
    long acc = 0;

    for (int i = len - 1; i >= 0; i--) {
        if (str[i] < '0' || str[i] > '9') return 0;

        int num = (int) str[i] - (int) '0';
        acc += num * mul;

        mul *= 10;
    }

    return acc;
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
        else if (strcmp(argv[0], "add") == 0) {
            if (argc != 3) {
                print_str("Invalid arguments\nUsage: add <a> <b>\n");
                continue;
            }

            print_dec(stoi(argv[1]) + stoi(argv[2]));
            print_str("\n");
        }
        else if (strcmp(argv[0], "mul") == 0) {
            if (argc != 3) {
                print_str("Invalid arguments\nUsage: mul <a> <b>\n");
                continue;
            }

            print_dec(stoi(argv[1]) * stoi(argv[2]));
            print_str("\n");
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

