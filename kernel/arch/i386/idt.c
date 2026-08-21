#include <kernel.h>
#include <types.h>

struct idt_entry {
    uint16_t base_low;
    uint16_t sel;
    uint8_t  always0;
    uint8_t  flags;
    uint16_t base_high;
} __attribute__((packed));

struct idt_ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

static struct idt_entry idt[256];
static struct idt_ptr ip;

extern void idt_flush(uint32_t);
extern void isr0();
extern void isr1();
extern void isr2();
// ... (другие обработчики можно добавить по мере необходимости)

static void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags) {
    idt[num].base_low = base & 0xFFFF;
    idt[num].base_high = (base >> 16) & 0xFFFF;
    idt[num].sel = sel;
    idt[num].always0 = 0;
    idt[num].flags = flags;
}

void idt_install() {
    ip.limit = sizeof(struct idt_entry) * 256 - 1;
    ip.base = (uint32_t)&idt;

    // Пока просто заполняем нулями, реальные обработчики добавим позже
    for (int i = 0; i < 256; i++)
        idt_set_gate(i, 0, 0x08, 0x8E);

    idt_flush((uint32_t)&ip);
}
