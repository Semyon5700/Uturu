#include <kernel.h>
#include <types.h>

static char input[128];

void shell_run(void) {
    terminal_writestring("Uturu OS Beta 8 Shell\n");
    while (1) {
        terminal_writestring("> ");
        // Чтение строки
        int pos = 0;
        while (1) {
            char c = keyboard_getchar();
            if (c == '\n') {
                input[pos] = '\0';
                terminal_putchar('\n');
                break;
            } else if (c == '\b') {
                if (pos > 0) {
                    pos--;
                    terminal_putchar('\b');
                    terminal_putchar(' ');
                    terminal_putchar('\b');
                }
            } else {
                if (pos < (int)(sizeof(input)-1)) {
                    input[pos++] = c;
                    terminal_putchar(c);
                }
            }
        }
        if (pos > 0) {
            execute_command(input);
        }
    }
}
