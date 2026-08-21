#include <kernel.h>
#include <uturu_api.h>
#include <fs/uramfs.h>

void uturu_print(const char* str) { terminal_writestring(str); }
void uturu_print_char(char c) { terminal_putchar(c); }
void uturu_clear_screen(void) { terminal_clear(); }
char uturu_getchar(void) { return keyboard_getchar(); }
void uturu_shutdown(void) { shutdown_system(); }
void uturu_reboot(void) { reboot_system(); }
void uturu_sleep(uint32_t ms) { sleep(ms); }

int uturu_create_file(const char* name) { return fs_create(name); }
int uturu_delete_file(const char* name) { return fs_remove(name); }
int uturu_file_exists(const char* name) { return fs_file_exists(name); }
int uturu_file_size(const char* name) { return fs_file_size(name); }
int uturu_file_read(const char* name, char* buffer, int max_size) { return fs_read(name, buffer, max_size); }
int uturu_file_write(const char* name, const char* data, int size) { return fs_write(name, data, size); }
int uturu_file_list(char* buffer, int max_size) { return fs_list_to_buffer(buffer, max_size); }
