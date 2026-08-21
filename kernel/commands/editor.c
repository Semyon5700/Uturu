#include <kernel.h>
#include <types.h>
#include <uturu_api.h>

void editor_run(const char* filename) {
    char buffer[1024];
    int size = uturu_file_read(filename, buffer, sizeof(buffer)-1);
    if (size < 0) {
        // Новый файл
        buffer[0] = '\0';
        size = 0;
    } else {
        buffer[size] = '\0';
    }

    printf("Editing %s (ESC to save & exit, Backspace to delete)\n", filename);
    printf("%s", buffer);
    int pos = strlen(buffer);
    while (1) {
        char c = keyboard_getchar();
        if (c == 27) { // ESC
            break;
        } else if (c == '\b') {
            if (pos > 0) {
                pos--;
                buffer[pos] = '\0';
                terminal_putchar('\b');
                terminal_putchar(' ');
                terminal_putchar('\b');
            }
        } else if (c == '\n') {
            if (pos < 1023) {
                buffer[pos++] = '\n';
                buffer[pos] = '\0';
                terminal_putchar('\n');
            }
        } else if (c >= ' ' && c <= '~') {
            if (pos < 1023) {
                buffer[pos++] = c;
                buffer[pos] = '\0';
                terminal_putchar(c);
            }
        }
    }
    // Сохраняем
    uturu_file_write(filename, buffer, pos);
    printf("\nSaved.\n");
}
