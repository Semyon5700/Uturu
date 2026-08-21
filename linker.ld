/* Точка входа (метка _start из boot.asm) */
ENTRY(_start)

SECTIONS
{
    /* Ядро загружается по адресу 1 МБ (стандарт для Multiboot) */
    . = 1M;

    /* Секция Multiboot-заголовка должна идти первой в файле */
    .multiboot ALIGN(4K) :
    {
        KEEP(*(.multiboot))
    }

    /* Исполняемый код */
    .text ALIGN(4K) :
    {
        *(.text)
    }

    /* Данные только для чтения */
    .rodata ALIGN(4K) :
    {
        *(.rodata)
    }

    /* Инициализированные данные */
    .data ALIGN(4K) :
    {
        *(.data)
    }

    /* Неинициализированные данные (BSS) */
    .bss ALIGN(4K) :
    {
        *(COMMON)
        *(.bss)
    }

    /* Конец ядра — может использоваться для расчёта размера */
    _kernel_end = .;
}