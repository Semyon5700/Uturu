#include <kernel.h>
#include <types.h>

// Заглушки для обработчиков прерываний (пока не используются)
void isr_handler() {
    terminal_writestring("Interrupt received!\n");
}
