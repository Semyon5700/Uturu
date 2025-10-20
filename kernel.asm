org 0x7E00
bits 16
mov ax, 0x03
int 0x10
mov si, welcome_msg
call print_string
main_loop:
mov si, prompt
call print_string
mov di, input_buffer
call read_string
mov si, input_buffer
mov di, cmd_ver
call strcmp
je .ver
mov si, input_buffer
mov di, cmd_cube
call strcmp
je .cube
mov si, input_buffer
mov di, cmd_reboot
call strcmp
je .reboot
mov si, input_buffer
mov di, cmd_time
call strcmp
je .time
mov si, input_buffer
mov di, cmd_time_update
call strcmp
je .time_update
mov si, input_buffer
mov di, cmd_shutdown
call strcmp
je .shutdown
mov si, input_buffer
mov di, cmd_browser
call strcmp
je .browser
mov si, input_buffer
mov di, cmd_bsod
call strcmp
je .bsod
mov si, input_buffer
mov di, cmd_lox
call strcmp
je .lox
mov si, input_buffer
mov di, cmd_minesweeper
call strcmp
je .minesweeper
mov si, input_buffer
mov di, cmd_kernel
call strcmp
je .kernel
mov si, input_buffer
mov di, cmd_help
call strcmp
je .help
mov si, input_buffer
mov di, cmd_crash
call strcmp
je .crash
mov si, unknown_cmd
call print_string
jmp main_loop
.ver:
mov si, welcome_msg
call print_string
jmp main_loop
.cube:
call draw_cube
jmp main_loop
.reboot:
jmp 0xFFFF:0x0000
.time:
call show_time
jmp main_loop
.time_update:
call update_time_24h
jmp main_loop
.shutdown:
mov ax, 0x5307
mov bx, 0x0001
mov cx, 0x0003
int 0x15
jmp $
.browser:
mov si, browser_msg
call print_string
jmp main_loop
.bsod:
mov si, bsod_confirm
call print_string
mov di, confirm_buffer
call read_string
mov si, confirm_buffer
mov di, yes_cmd
call strcmp
je .do_bsod
jmp main_loop
.do_bsod:
mov ax, 0x0003
int 0x10
mov ax, 0xB800
mov es, ax
xor di, di
mov cx, 2000
mov ax, 0x1F20
rep stosw
mov si, bsod_msg1
mov di, 160
call .print_bsod
mov si, bsod_msg2
mov di, 320
call .print_bsod
mov si, bsod_msg3
mov di, 480
call .print_bsod
.hang:
mov ah, 0x00
int 0x16
jmp 0xFFFF:0x0000
.print_bsod:
.loop:
lodsb
test al, al
jz .done
mov [es:di], al
inc di
mov byte [es:di], 0x1F
inc di
jmp .loop
.done:
ret
.lox:
mov si, lox_msg
call print_string
jmp main_loop
.minesweeper:
call start_minesweeper
jmp main_loop
.kernel:
mov si, kernel_info
call print_string
jmp main_loop
.help:
mov si, help_msg
call print_string
jmp main_loop
.crash:
mov si, panic_msg
call print_string
xor ax, ax
mov es, ax
mov di, 0xFFFF
mov al, 0xFF
stosb
jmp $
print_string:
mov ah, 0x0E
mov bh, 0x00
.loop:
lodsb
test al, al
jz .done
int 0x10
jmp .loop
.done:
ret
read_string:
xor cx, cx
.loop:
mov ah, 0x00
int 0x16
cmp al, 0x0D
je .done
cmp al, 0x08
je .backspace
cmp cx, 31
je .loop
mov [di], al
inc di
inc cx
mov ah, 0x0E
int 0x10
jmp .loop
.backspace:
test cx, cx
jz .loop
dec di
dec cx
mov ah, 0x0E
mov al, 0x08
int 0x10
mov al, ' '
int 0x10
mov al, 0x08
int 0x10
jmp .loop
.done:
mov byte [di], 0
mov ah, 0x0E
mov al, 0x0D
int 0x10
mov al, 0x0A
int 0x10
ret
strcmp:
.loop:
mov al, [si]
mov bl, [di]
cmp al, bl
jne .not_equal
test al, al
jz .equal
inc si
inc di
jmp .loop
.not_equal:
clc
ret
.equal:
stc
ret
draw_cube:
mov ax, 0x13
int 0x10
mov cx, 64
mov dx, 64
mov al, 0x0F
mov ah, 0x0C
.loop_h:
int 0x10
inc cx
cmp cx, 192
jne .loop_h
mov cx, 64
inc dx
cmp dx, 192
jne .loop_h
.wait_key:
mov ah, 0x00
int 0x16
cmp al, 'q'
jne .wait_key
mov ax, 0x03
int 0x10
ret
show_time:
mov ah, 0x02
int 0x1A
mov al, ch
call bcd_to_ascii
mov [time_str], ah
mov [time_str+1], al
mov al, cl
call bcd_to_ascii
mov [time_str+3], ah
mov [time_str+4], al
mov al, dh
call bcd_to_ascii
mov [time_str+6], ah
mov [time_str+7], al
mov si, time_str
call print_string
ret
update_time_24h:
mov si, time_update_msg
call print_string
mov di, time_input
call read_string
mov si, time_input
call parse_time_24h
jc .error
mov ch, al
mov cl, ah
mov dh, dl
mov ah, 0x03
int 0x1A
mov si, time_updated_msg
call print_string
ret
.error:
mov si, time_error_msg
call print_string
ret
parse_time_24h:
xor ax, ax
xor dx, dx
mov bx, 10
mov cx, 2
.loop_h:
lodsb
cmp al, '0'
jb .error
cmp al, '9'
ja .error
sub al, '0'
imul dx, bx
add dl, al
loop .loop_h
cmp dl, 24
jae .error
lodsb
cmp al, ':'
jne .error
mov al, dl
xor dx, dx
mov cx, 2
.loop_m:
lodsb
cmp al, '0'
jb .error
cmp al, '9'
ja .error
sub al, '0'
imul dx, bx
add dl, al
loop .loop_m
cmp dl, 60
jae .error
lodsb
cmp al, ':'
jne .error
mov ah, dl
xor dx, dx
mov cx, 2
.loop_s:
lodsb
cmp al, '0'
jb .error
cmp al, '9'
ja .error
sub al, '0'
imul dx, bx
add dl, al
loop .loop_s
cmp dl, 60
jae .error
stc
ret
.error:
clc
ret
bcd_to_ascii:
mov ah, al
shr al, 4
add al, '0'
and ah, 0x0F
add ah, '0'
ret
start_minesweeper:
mov ax, 0x13
int 0x10
mov cx, 50
mov dx, 50
mov al, 0x0F
.draw_field:
mov ah, 0x0C
int 0x10
add cx, 16
cmp cx, 210
jb .draw_field
mov cx, 50
add dx, 16
cmp dx, 210
jb .draw_field
mov si, exit_text
mov cx, 120
mov dx, 220
call .draw_text
mov byte [cursor_x], 50
mov byte [cursor_y], 50
mov byte [cursor_color], 0x0E
.draw_cursor:
mov cx, [cursor_x]
mov dx, [cursor_y]
mov al, [cursor_color]
mov ah, 0x0C
int 0x10
.key_loop:
mov ah, 0x00
int 0x16
cmp ah, 0x48
je .up
cmp ah, 0x50
je .down
cmp ah, 0x4B
je .left
cmp ah, 0x4D
je .right
cmp al, 0x0D
je .select
cmp al, 'q'
je .quit
jmp .key_loop
.up:
mov cx, [cursor_x]
mov dx, [cursor_y]
mov al, 0x0F
mov ah, 0x0C
int 0x10
sub word [cursor_y], 16
jmp .draw_cursor
.down:
mov cx, [cursor_x]
mov dx, [cursor_y]
mov al, 0x0F
mov ah, 0x0C
int 0x10
add word [cursor_y], 16
jmp .draw_cursor
.left:
mov cx, [cursor_x]
mov dx, [cursor_y]
mov al, 0x0F
mov ah, 0x0C
int 0x10
sub word [cursor_x], 16
jmp .draw_cursor
.right:
mov cx, [cursor_x]
mov dx, [cursor_y]
mov al, 0x0F
mov ah, 0x0C
int 0x10
add word [cursor_x], 16
jmp .draw_cursor
.select:
mov cx, [cursor_x]
mov dx, [cursor_y]
mov al, 0x04
mov ah, 0x0C
int 0x10
jmp .key_loop
.quit:
mov ax, 0x0003
int 0x10
ret
.draw_text:
mov ah, 0x0E
mov bh, 0x00
.text_loop:
lodsb
test al, al
jz .text_done
int 0x10
inc cx
jmp .text_loop
.text_done:
ret
cursor_x dw 50
cursor_y dw 50
cursor_color db 0x0E
welcome_msg db 'Uturu OS Beta 5', 0x0D, 0x0A, 0
prompt db '> ', 0
input_buffer times 32 db 0
confirm_buffer times 32 db 0
cmd_ver db 'ver', 0
cmd_cube db 'cube', 0
cmd_reboot db 'reboot', 0
cmd_time db 'time', 0
cmd_time_update db 'time update', 0
cmd_shutdown db 'shutdown', 0
cmd_browser db 'browser', 0
cmd_bsod db 'bsod', 0
cmd_lox db 'lox', 0
cmd_minesweeper db 'minesweeper', 0
cmd_kernel db 'kernel', 0
cmd_help db 'help', 0
cmd_crash db 'crash', 0
yes_cmd db 'yes', 0
unknown_cmd db 'Unknown command', 0x0D, 0x0A, 0
browser_msg db 'Browser not implemented yet', 0x0D, 0x0A, 0
bsod_confirm db 'Are you sure? (yes/no): ', 0
bsod_msg1 db ':-(', 0
bsod_msg2 db 'Your PC ran into a problem', 0
bsod_msg3 db 'Press any key to restart', 0
lox_msg db 'lox', 0x0D, 0x0A, 0
kernel_info db 'Kernel: Uturu OS Beta 5', 0x0D, 0x0A, 0
help_msg db 'Commands: ver, cube, reboot, time, time update, shutdown, browser, bsod, lox, minesweeper, kernel, help, crash', 0x0D, 0x0A, 0
time_str db '00:00:00', 0x0D, 0x0A, 0
time_update_msg db 'Enter new time (HH:MM:SS): ', 0
time_updated_msg db 'Time updated', 0x0D, 0x0A, 0
time_error_msg db 'Invalid time format', 0x0D, 0x0A, 0
time_input times 9 db 0
exit_text db 'EXIT (Q)', 0
panic_msg db 'KERNEL PANIC', 0x0D, 0x0A, 0
