#include <kernel.h>
#include <types.h>
static inline void outw(uint16_t port, uint16_t val) {
    __asm__ volatile ("outw %0, %1" :: "a"(val), "Nd"(port));
}

// Поиск RSDP в памяти BIOS
static uint32_t find_rsdp(void) {
    uint32_t ebda = *(uint16_t*)0x040E;
    ebda <<= 4; // сегмент -> линейный адрес

    // Проверяем EBDA (первые 1 КБ)
    for (uint32_t addr = ebda; addr < ebda + 1024; addr += 16) {
        if (*(uint32_t*)addr == 0x20445352 && *(uint32_t*)(addr+4) == 0x20525450) { // "RSD PTR "
            // Проверка контрольной суммы (v1)
            uint8_t sum = 0;
            for (int i = 0; i < 20; i++) sum += *(uint8_t*)(addr+i);
            if (sum == 0) return addr;
        }
    }

    // Область 0xE0000 - 0xFFFFF
    for (uint32_t addr = 0xE0000; addr < 0x100000; addr += 16) {
        if (*(uint32_t*)addr == 0x20445352 && *(uint32_t*)(addr+4) == 0x20525450) {
            uint8_t sum = 0;
            for (int i = 0; i < 20; i++) sum += *(uint8_t*)(addr+i);
            if (sum == 0) return addr;
        }
    }
    return 0;
}

void acpi_shutdown(void) {
    uint32_t rsdp = find_rsdp();
    if (!rsdp) return;

    // RSDP v1: FADT адрес на смещении 16
    uint32_t fadt_addr = *(uint32_t*)(rsdp + 16);
    if (!fadt_addr) return;

    // Проверяем сигнатуру "FACP"
    if (*(uint32_t*)fadt_addr != 0x50434146) return;

    // Смещение PM1a_CNT_BLK в FADT v1 = 64
    uint16_t pm1a_cnt = *(uint16_t*)(fadt_addr + 64);
    if (!pm1a_cnt) return;

    // SLP_TYPa = 5, SLP_EN = 1<<13
    outw(pm1a_cnt, (5 << 10) | (1 << 13));
}