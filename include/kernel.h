#ifndef KERNEL_H
#define KERNEL_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>


enum vga_color {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
};

/* Строковые функции */
size_t strlen(const char* s);
int strcmp(const char* s1, const char* s2);
char* strcpy(char* dest, const char* src);
char* strncpy(char* dest, const char* src, size_t n);
void* memset(void* s, int c, size_t n);
void* memcpy(void* dest, const void* src, size_t n);
int atoi(const char* s);
void itoa(int value, char* str, int base);

void terminal_initialize(void);
void terminal_setcolor(uint8_t fg, uint8_t bg);
void terminal_putchar(char c);
void terminal_write(const char* data, size_t size);
void terminal_writestring(const char* data);
void terminal_clear(void);

char keyboard_getchar(void);
void read_line(char* buffer, int max_len);

void timer_install(uint32_t freq);
void sleep(uint32_t ms);

void serial_init(void);
void serial_write(char c);
void serial_writestring(const char* s);

void reboot_system(void);
void shutdown_system(void);
void get_time(uint8_t* hour, uint8_t* minute, uint8_t* second);

void gdt_install(void);
void idt_install(void);

void shell_run(void);
void execute_command(char* input);
void calculator_run(void);
void editor_run(const char* filename);

void fs_init(void);

int printf(const char* fmt, ...);
void terminal_setcolor(uint8_t fg, uint8_t bg);
void acpi_shutdown(void);
void update_cursor(void);
int printf(const char* fmt, ...);

#endif
