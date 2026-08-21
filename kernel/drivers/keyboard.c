#include <kernel.h>
#include <types.h>

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" :: "a"(val), "Nd"(port));
}

// Таблицы сканкодов
static const char scancode_lower[] = {
    0, 27, '1','2','3','4','5','6','7','8','9','0','-','=','\b',
    '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',0,
    'a','s','d','f','g','h','j','k','l',';','\'','`',0,'\\',
    'z','x','c','v','b','n','m',',','.','/',0,
    '*',0,' ',0
};

static const char scancode_upper[] = {
    0, 27, '!','@','#','$','%','^','&','*','(',')','_','+','\b',
    '\t','Q','W','E','R','T','Y','U','I','O','P','{','}','\n',0,
    'A','S','D','F','G','H','J','K','L',':','"','~',0,'|',
    'Z','X','C','V','B','N','M','<','>','?',0,
    '*',0,' ',0
};

static int shift_pressed = 0;

char keyboard_getchar(void) {
    uint8_t scancode;
    while (1) {
        while ((inb(0x64) & 1) == 0);
        scancode = inb(0x60);

        // Отслеживаем Shift
        if (scancode == 0x2A || scancode == 0x36) { // левый/правый Shift нажат
            shift_pressed = 1;
            continue;
        }
        if (scancode == 0xAA || scancode == 0xB6) { // левый/правый Shift отпущен
            shift_pressed = 0;
            continue;
        }

        // Игнорируем отпускание остальных клавиш
        if (scancode & 0x80) continue;

        if (scancode < sizeof(scancode_lower)) {
            char c = shift_pressed ? scancode_upper[scancode] : scancode_lower[scancode];
            if (c != 0) return c;
        }
    }
}