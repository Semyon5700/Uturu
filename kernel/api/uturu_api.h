#ifndef UTURU_API_H
#define UTURU_API_H

#include <types.h>

// Функции API для приложений
void uturu_print(const char* str);
void uturu_print_char(char c);
void uturu_clear_screen(void);
char uturu_getchar(void);
void uturu_shutdown(void);
void uturu_reboot(void);
void uturu_get_time(uint8_t* hour, uint8_t* minute, uint8_t* second);
void uturu_sleep(uint32_t ms);

// Файловая система
int uturu_create_file(const char* name);
int uturu_delete_file(const char* name);
int uturu_file_exists(const char* name);
int uturu_file_size(const char* name);
int uturu_file_read(const char* name, char* buffer, int max_size);
int uturu_file_write(const char* name, const char* data, int size);
int uturu_file_list(char* buffer, int max_size); // возвращает список файлов

#endif
