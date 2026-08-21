#include <kernel.h>
#include <types.h>
#include "acpi.h"

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" :: "a"(val), "Nd"(port));
}

static inline void outw(uint16_t port, uint16_t val) {
    __asm__ volatile ("outw %0, %1" :: "a"(val), "Nd"(port));
}

void reboot_system(void) {
    outb(0x64, 0xFE);
    for(;;) __asm__ volatile ("int $0x19");
}

void shutdown_system(void) {
    // Отключаем прерывания
    __asm__ volatile ("cli");

    // Очищаем экран и выводим сообщение
    terminal_clear();
    terminal_setcolor(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    terminal_writestring("\n\n");
    terminal_writestring("  It is now safe to turn off your computer.\n\n");
    terminal_writestring("  Please press the power button to shut down.\n");

    // Бесконечный цикл — система полностью остановлена
    for(;;) {
        __asm__ volatile ("hlt");
    }
}