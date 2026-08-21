; Multiboot header and entry point
section .multiboot
align 4
    dd 0x1BADB002              ; magic
    dd 0x00000003              ; flags (align modules, memory info)
    dd -(0x1BADB002 + 0x00000003) ; checksum

section .text
global _start
extern kernel_main

_start:
    mov esp, stack_top
    push ebx                  ; multiboot info (второй параметр)
    push eax                  ; magic (первый параметр)
    call kernel_main
    add esp, 8                ; очистка стека после cdecl вызова
    cli
    hlt

section .bss
align 16
stack_bottom:
    resb 16384                ; 16 KiB stack
stack_top: