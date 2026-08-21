#include <kernel.h>
#include <types.h>
#include <uturu_api.h>
#include <fs/uramfs.h>
#include <multiboot.h>
extern multiboot_info_t* mb_info;

// Объявления команд
static void cmd_ver(char* args);
static void cmd_help(char* args);
static void cmd_clear(char* args);
static void cmd_echo(char* args);
static void cmd_calc(char* args);
static void cmd_shutdown(char* args);
static void cmd_reboot(char* args);
static void cmd_fetch(char* args);
static void cmd_author(char* args);
static void cmd_crash(char* args);
static void cmd_cat(char* args);
static void cmd_ls(char* args);
static void cmd_create(char* args);
static void cmd_edit(char* args);
static void cmd_rm(char* args);

typedef struct {
    const char* name;
    const char* desc;
    void (*handler)(char*);
} command_t;

static const command_t commands[] = {
    {"ver",     "Show OS version",       cmd_ver},
    {"help",    "List all commands",     cmd_help},
    {"clear",   "Clear screen",          cmd_clear},
    {"echo",    "Print text",            cmd_echo},
    {"calc",    "Calculator",            cmd_calc},
    {"shutdown","Shutdown system",       cmd_shutdown},
    {"reboot",  "Reboot system",         cmd_reboot},
    {"fetch",   "System information",    cmd_fetch},
    {"author",  "Show author info",      cmd_author},
    {"crash",   "Trigger kernel panic",  cmd_crash},
    {"cat",     "View file content",     cmd_cat},
    {"ls",      "List files",            cmd_ls},
    {"create",  "Create file",           cmd_create},
    {"edit",    "Edit file",             cmd_edit},
    {"rm",      "Delete file",           cmd_rm},
    {0,0,0}
};

void execute_command(char* input) {
    char cmd[32];
    char args[128];
    // Разделяем команду и аргументы
    int i = 0, j = 0;
    while (input[i] && input[i] != ' ' && i < 31) cmd[j++] = input[i++];
    cmd[j] = '\0';
    while (input[i] == ' ') i++;
    j = 0;
    while (input[i] && j < 127) args[j++] = input[i++];
    args[j] = '\0';

    // Поиск команды
    for (int k = 0; commands[k].name; k++) {
        if (strcmp(cmd, commands[k].name) == 0) {
            commands[k].handler(args);
            return;
        }
    }
    if (cmd[0] != '\0')
        printf("Unknown command: %s\nType 'help' for list.\n", cmd);
}

static void cmd_ver(char* args) {
    (void)args;
    printf("Uturu OS Beta 8\n");
}

static void cmd_help(char* args) {
    (void)args;
    printf("Available commands:\n");
    for (int i = 0; commands[i].name; i++)
    printf("%s - %s\n", commands[i].name, commands[i].desc);
}

static void cmd_clear(char* args) {
    (void)args;
    terminal_clear();
}

static void cmd_echo(char* args) {
    printf("%s\n", args);
}


static void cmd_calc(char* args) {
    (void)args;
    calculator_run();  // функция из calculator.c
}

static void cmd_shutdown(char* args) {
    (void)args;
    printf("Shutting down...\n");
    shutdown_system();
}

static void cmd_reboot(char* args) {
    (void)args;
    printf("Rebooting...\n");
    reboot_system();
}

static int get_memory_mb(void) {
    if (mb_info == NULL) return 0;

    // Основной метод: mmap (точный для любых объёмов)
    if ((mb_info->flags & (1 << 6)) && mb_info->mmap_length && mb_info->mmap_addr) {
        uint64_t total_bytes = 0;
        multiboot_memory_map_t* mmap = (multiboot_memory_map_t*)(uint32_t)mb_info->mmap_addr;
        uint32_t end = mb_info->mmap_addr + mb_info->mmap_length;

        while ((uint32_t)mmap < end) {
            if (mmap->type == 1) {
                total_bytes += mmap->length;
            }
            mmap = (multiboot_memory_map_t*)((uint32_t)mmap + mmap->size + sizeof(mmap->size));
        }

        return (int)(total_bytes / (1024 * 1024));
    }

    // Fallback: mem_upper + нижний 1 МБ
    if (mb_info->flags & (1 << 0)) {
        uint32_t total_kb = mb_info->mem_upper + 1024;
        return (int)(total_kb / 1024);
    }

    return 0;
}

static void cmd_fetch(char* args) {
    (void)args;
    printf("OS: Uturu beta 8\n");
    printf("Architecture: i386\n");
    printf("RAM: %d MB\n", get_memory_mb());
    printf("URamFS files: %d/%d\n", fs_count_used(), MAX_FILES);
}
static void cmd_author(char* args) {
    (void)args;
    printf("Author: Semyon5700\n");
    printf("License: License: GNU General Public License version 3\n");
}

static void cmd_crash(char* args) {
    (void)args;
    terminal_setcolor(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    terminal_clear();

    terminal_writestring("*** KERNEL PANIC ***\n\n");
    terminal_writestring("System has been halted.\n");
    terminal_writestring("Press any key to reboot...\n");

    keyboard_getchar();
    reboot_system();
}

static void cmd_cat(char* args) {
    if (args[0] == '\0') {
        printf("Usage: cat <filename>\n");
        return;
    }
    char buffer[1024];
    int size = uturu_file_read(args, buffer, sizeof(buffer)-1);
    if (size >= 0) {
        buffer[size] = '\0';
        printf("%s", buffer);
        if (size > 0 && buffer[size-1] != '\n') printf("\n");
    } else {
        printf("File not found: %s\n", args);
    }
}

static void cmd_ls(char* args) {
    (void)args;
    char list[1024];
    int len = uturu_file_list(list, sizeof(list));
    if (len == 0) {
        printf("No files.\n");
        return;
    }
    // list содержит строки, разделённые '\n'
    printf("%s", list);
}

static void cmd_create(char* args) {
    if (args[0] == '\0') {
        printf("Usage: create <filename>\n");
        return;
    }
    if (uturu_create_file(args) == 0)
        printf("Created file: %s\n", args);
    else
        printf("Error: file already exists or FS full.\n");
}

static void cmd_edit(char* args) {
    if (args[0] == '\0') {
        printf("Usage: edit <filename>\n");
        return;
    }
    editor_run(args); // функция из editor.c
}

static void cmd_rm(char* args) {
    if (args[0] == '\0') {
        printf("Usage: rm <filename>\n");
        return;
    }
    if (uturu_delete_file(args) == 0)
        printf("File removed: %s\n", args);
    else
        printf("File not found: %s\n", args);
}
