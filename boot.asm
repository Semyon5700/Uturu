org 0x7C00
bits 16

; Initialize segments and stack
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

; Clear screen and set text mode
mov ax, 0x0003
int 0x10

; Show loading message
mov si, loading_msg
call print

; Load kernel from disk (40 sectors = 20KB)
mov ah, 0x02
mov al, 40        ; Number of sectors to read
mov ch, 0         ; Cylinder
mov dh, 0         ; Head  
mov cl, 2         ; Starting sector
mov bx, 0x7E00    ; Load to 0x7E00 (right after bootloader)
int 0x13
jc error          ; Jump if disk error

; Jump to loaded kernel
jmp 0x7E00

; Print string function
print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

error:
    mov si, error_msg
    call print
    jmp $

loading_msg db 'Uturu OS Beta 6 Loading...', 0
error_msg db ' Disk Error!', 0

; Boot signature
times 510-($-$$) db 0
dw 0xAA55
