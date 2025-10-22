org 0x7E00
bits 16

kernel_start:
    mov ax, 0x03
    int 0x10
    mov si, welcome_msg
    call print_string

main_loop:
    mov si, prompt
    call print_string
    mov di, input_buffer
    call read_string_safe
    mov si, input_buffer
    call parse_and_execute
    jmp main_loop

; --- Safe string input with bounds checking ---
read_string_safe:
    xor cx, cx
.input_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je .done
    cmp al, 0x08
    je .backspace
    cmp cx, 31
    jae .input_loop
    mov [di], al
    inc di
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .input_loop
.backspace:
    test cx, cx
    jz .input_loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .input_loop
.done:
    mov byte [di], 0
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

; --- Command parser and executor ---
parse_and_execute:
    ; Make copy of input for argument parsing
    mov di, command_copy
    mov si, input_buffer
    call strcpy
    
    ; Find command end (first space or null)
    mov si, command_copy
.find_cmd_end:
    lodsb
    test al, al
    jz .cmd_only
    cmp al, ' '
    jne .find_cmd_end
    
    ; Replace space with null to separate command
    dec si
    mov byte [si], 0
    inc si ; SI now points to arguments
    
.save_args:
    mov di, command_args
    call strcpy
    
    ; Now command_copy contains just the command, command_args contains arguments
    mov si, command_copy
    
    ; Compare with known commands
    mov di, cmd_echo
    call strcmp
    je .echo_cmd
    
    mov di, cmd_ver
    call strcmp
    je .ver_cmd
    
    mov di, cmd_cube
    call strcmp
    je .cube_cmd
    
    mov di, cmd_reboot  
    call strcmp
    je .reboot_cmd
    
    mov di, cmd_time
    call strcmp
    je .time_cmd
    
    mov di, cmd_shutdown
    call strcmp
    je .shutdown_cmd
    
    mov di, cmd_browser
    call strcmp
    je .browser_cmd
    
    mov di, cmd_minesweeper
    call strcmp
    je .minesweeper_cmd
    
    mov di, cmd_kernel
    call strcmp
    je .kernel_cmd
    
    mov di, cmd_crash
    call strcmp
    je .crash_cmd
    
    mov di, cmd_fetch
    call strcmp
    je .fetch_cmd
    
    mov di, cmd_author
    call strcmp
    je .author_cmd
    
    mov di, cmd_32bit
    call strcmp
    je .32bit_cmd
    
    mov di, cmd_help
    call strcmp
    je .help_cmd
    
.unknown_cmd:
    mov si, unknown_cmd_msg
    call print_string
    ret

.cmd_only:
    ; No arguments, just command
    mov byte [command_args], 0
    jmp .save_args

.ver_cmd:
    mov si, welcome_msg
    call print_string
    ret

.cube_cmd:
    call draw_cube
    ret

.reboot_cmd:
    jmp 0xFFFF:0x0000

.time_cmd:
    ; Check if arguments contain "update"
    mov si, command_args
    mov di, time_update_arg
    call strcmp
    je .time_update_cmd
    
    ; Normal time display
    call show_time
    ret

.time_update_cmd:
    call update_time_24h
    ret

.echo_cmd:
    mov si, command_args
    call print_string
    mov si, newline
    call print_string
    ret

.shutdown_cmd:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    jmp $

.browser_cmd:
    mov si, browser_msg
    call print_string
    ret

.minesweeper_cmd:
    call start_minesweeper
    ret

.kernel_cmd:
    mov si, kernel_info
    call print_string
    ret

.crash_cmd:
    mov si, panic_msg
    call print_string
    jmp $

.fetch_cmd:
    call show_system_info
    ret

.author_cmd:
    mov si, author_msg
    call print_string
    ret

.32bit_cmd:
    mov si, bit32_msg
    call print_string
    ret

.help_cmd:
    mov si, help_msg
    call print_string
    ret

; --- System Info Function (fetch) ---
show_system_info:
    ; OS Name
    mov si, fetch_os
    call print_string
    
    ; Memory
    mov si, fetch_ram
    call print_string
    call get_memory_mb
    call print_number
    mov si, mb_msg
    call print_string
    
    ; Time
    mov si, fetch_time
    call print_string
    call show_time_no_newline
    
    ret

; --- Get memory in MB ---
get_memory_mb:
    ; Use BIOS interrupt 0x15, AX=0xE801
    mov ax, 0xE801
    int 0x15
    jc .try_old_method
    
    ; Calculate total memory in KB
    mov cx, ax      ; Memory from 1-16MB (in KB)
    
    ; Convert BX (64K blocks) to KB
    mov ax, bx
    mov bx, 64
    mul bx
    add cx, ax      ; CX = total KB
    
    ; Convert KB to MB
    mov ax, cx
    mov bx, 1024
    xor dx, dx
    div bx          ; AX = MB
    ret
    
.try_old_method:
    ; Alternative: Try AH=0x88
    mov ah, 0x88
    int 0x15
    jc .unknown_mem
    
    ; AX = extended memory size in KB
    mov cx, ax
    mov ax, cx
    mov bx, 1024
    xor dx, dx
    div bx
    ret
    
.unknown_mem:
    mov ax, 0
    ret

; --- Show time without newline ---
show_time_no_newline:
    mov ah, 0x02
    int 0x1A
    mov al, ch
    call bcd_to_ascii
    mov [time_str_temp], ah
    mov [time_str_temp+1], al
    mov al, cl
    call bcd_to_ascii  
    mov [time_str_temp+3], ah
    mov [time_str_temp+4], al
    mov al, dh
    call bcd_to_ascii
    mov [time_str_temp+6], ah
    mov [time_str_temp+7], al
    mov si, time_str_temp
    call print_string
    ret

; --- Print number in AX as decimal ---
print_number:
    mov cx, 0
    mov bx, 10
.push_digits:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .push_digits
.pop_digits:
    pop ax
    mov ah, 0x0E
    int 0x10
    loop .pop_digits
    ret

; --- String copy function ---
strcpy:
.loop:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    test al, al
    jnz .loop
    ret

; --- Time functions ---
show_time:
    call show_time_no_newline
    mov si, newline
    call print_string
    ret

update_time_24h:
    mov si, time_update_msg
    call print_string
    mov di, time_input
    call read_string_safe
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

; --- Drawing functions ---
draw_cube:
    mov ax, 0x13
    int 0x10
    mov cx, 64
    mov dx, 64
    mov al, 0x0F
.draw_loop:
    mov ah, 0x0C
    int 0x10
    inc cx
    cmp cx, 192
    jne .draw_loop
    mov cx, 64
    inc dx
    cmp dx, 192
    jne .draw_loop
.wait_key:
    mov ah, 0x00
    int 0x16
    cmp al, 'q'
    jne .wait_key
    mov ax, 0x03
    int 0x10
    ret

; --- Minesweeper game ---
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
    mov word [cursor_x], 50
    mov word [cursor_y], 50
.draw_cursor:
    mov cx, [cursor_x]
    mov dx, [cursor_y]
    mov al, 0x0E
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
    mov ax, 0x03
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

; --- Utility functions ---
print_string:
    mov ah, 0x0E
.print_loop:
    lodsb
    test al, al
    jz .print_done
    int 0x10
    jmp .print_loop
.print_done:
    ret

strcmp:
.compare_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .compare_loop
.not_equal:
    clc
    ret
.equal:
    stc
    ret

bcd_to_ascii:
    mov ah, al
    shr al, 4
    add al, '0'
    and ah, 0x0F
    add ah, '0'
    ret

; --- Data section ---
welcome_msg db 'Uturu OS Beta 6', 0x0D, 0x0A, 0
prompt db '> ', 0
newline db 0x0D, 0x0A, 0

; Command strings
cmd_ver db 'ver', 0
cmd_cube db 'cube', 0
cmd_reboot db 'reboot', 0
cmd_time db 'time', 0
cmd_shutdown db 'shutdown', 0
cmd_browser db 'browser', 0
cmd_minesweeper db 'minesweeper', 0
cmd_kernel db 'kernel', 0
cmd_crash db 'crash', 0
cmd_fetch db 'fetch', 0
cmd_echo db 'echo', 0
cmd_author db 'author', 0
cmd_32bit db '32-bit', 0
cmd_help db 'help', 0

; Arguments
time_update_arg db 'update', 0

; Messages
unknown_cmd_msg db 'Unknown command', 0x0D, 0x0A, 0
browser_msg db 'Browser not implemented yet', 0x0D, 0x0A, 0
kernel_info db 'Kernel: Uturu OS Beta 6', 0x0D, 0x0A, 0
panic_msg db 'KERNEL PANIC', 0x0D, 0x0A, 0
mb_msg db ' MB', 0x0D, 0x0A, 0
author_msg db 'Author: Semyon5700', 0x0D, 0x0A, 'License: GPL 3.0', 0x0D, 0x0A, 0
bit32_msg db '32-bit mode is planned but not implemented yet.', 0x0D, 0x0A, 'You can fork and add it yourself!', 0x0D, 0x0A, 0
help_msg db 'Commands: ver, cube, reboot, time [update], shutdown, browser, minesweeper, kernel, crash, fetch, echo, author, help', 0x0D, 0x0A, 0

; Fetch info
fetch_os db 'OS: Uturu OS Beta 6', 0x0D, 0x0A, 0
fetch_ram db 'RAM: ', 0
fetch_time db 'Time: ', 0

; Time data
time_str db '00:00:00', 0x0D, 0x0A, 0
time_str_temp db '00:00:00', 0
time_update_msg db 'Enter new time (HH:MM:SS): ', 0
time_updated_msg db 'Time updated', 0x0D, 0x0A, 0
time_error_msg db 'Invalid time format', 0x0D, 0x0A, 0
time_input times 9 db 0

; Minesweeper data
cursor_x dw 50
cursor_y dw 50
exit_text db 'EXIT (Q)', 0

; Buffers
input_buffer times 32 db 0
command_copy times 32 db 0
command_args times 32 db 0

times 20480-($-kernel_start) db 0
