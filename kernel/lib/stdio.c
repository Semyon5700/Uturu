#include <kernel.h>
#include <types.h>
#include <stdarg.h>

void putchar(char c) {
    terminal_putchar(c);
}

void puts(const char* s) {
    terminal_writestring(s);
    terminal_putchar('\n');
}

// Минимальный printf (только %s, %d, %c)
int printf(const char* fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    char buf[32];
    while (*fmt) {
        if (*fmt == '%') {
            fmt++;
            switch (*fmt) {
                case 's': {
                    char* s = va_arg(ap, char*);
                    terminal_writestring(s);
                    break;
                }
                case 'd': {
                    int d = va_arg(ap, int);
                    itoa(d, buf, 10);
                    terminal_writestring(buf);
                    break;
                }
                case 'c': {
                    char c = (char)va_arg(ap, int);
                    terminal_putchar(c);
                    break;
                }
                default:
                    terminal_putchar('%');
                    terminal_putchar(*fmt);
            }
        } else {
            terminal_putchar(*fmt);
        }
        fmt++;
    }
    va_end(ap);
    return 0;
}

void read_line(char* buffer, int max_len) {
    int pos = 0;
    while (1) {
        char c = keyboard_getchar();
        if (c == '\n') {
            buffer[pos] = '\0';
            terminal_putchar('\n');
            break;
        } else if (c == '\b') {
            if (pos > 0) {
                pos--;
                terminal_putchar('\b');
                terminal_putchar(' ');
                terminal_putchar('\b');
            }
        } else if (c >= ' ' && c <= '~') {
            if (pos < max_len - 1) {
                buffer[pos++] = c;
                terminal_putchar(c);
            }
        }
    }
}
