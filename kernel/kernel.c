#include <kernel.h>
#include <types.h>
#include <fs/uramfs.h>
#include <multiboot.h>

multiboot_info_t* mb_info = NULL;

void kernel_main(uint32_t magic, uint32_t multiboot_addr) {
    (void)magic;
    
    // Сохраняем информацию от GRUB
    if (multiboot_addr != 0) {
        mb_info = (multiboot_info_t*)multiboot_addr;
    }

    terminal_initialize();
    terminal_setcolor(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    terminal_writestring("Uturu beta 8 starting...\n");

    gdt_install();
    // idt_install(); // пока отключено
    fs_init();

    terminal_clear();
    shell_run();

    for(;;);
}