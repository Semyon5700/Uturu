org 0x7C00
bits 16
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00
mov ax, 0x0003
int 0x10
mov si, loading_msg
call print
mov ah, 0x02
mov al, 40
mov ch, 0
mov dh, 0
mov cl, 2
mov bx, 0x7E00
int 0x13
jc error
jmp 0x7E00
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
loading_msg db 'Uturu Loading', 0
error_msg db ' Disk Error', 0
times 510-($-$$) db 0
dw 0xAA55
