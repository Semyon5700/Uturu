; ============================================
; UTURU OS BETA 7 - KERNEL
; ============================================
org 0x7E00
bits 16

; --- Constants ---
MAX_FILES equ 16
MAX_FILESIZE equ 1024

kernel_start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear screen and set text mode
    mov ax, 0x0003
    int 0x10

    ; Initialize URamFS
    call init_uramfs

    ; Show welcome message
    mov si, welcome_msg
    call print_string

main_loop:
    ; Show prompt
    mov si, prompt
    call print_string

    ; Read input
    mov di, input_buffer
    call read_string_safe

    ; Parse and execute command
    mov si, input_buffer
    call parse_and_execute

    jmp main_loop

; ============================================
; STRING FUNCTIONS
; ============================================

print_string:
    push si
    mov ah, 0x0E
.print_loop:
    lodsb
    test al, al
    jz .print_done
    int 0x10
    jmp .print_loop
.print_done:
    pop si
    ret

strcmp:
    push si
    push di
    push ax
    push bx
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
.equal:
    pop bx
    pop ax
    pop di
    pop si
    stc
    ret
.not_equal:
    pop bx
    pop ax
    pop di
    pop si
    clc
    ret

strcpy:
    push ax
    push si
    push di
.loop:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    test al, al
    jnz .loop
    pop di
    pop si
    pop ax
    ret

bcd_to_ascii:
    mov ah, al
    shr al, 4
    add al, '0'
    and ah, 0x0F
    add ah, '0'
    ret

atoi:
    push bx
    push cx
    push dx
    push si
    
    xor ax, ax
    xor bx, bx
    mov cx, 10
    
.atoi_loop:
    mov bl, [si]
    test bl, bl
    jz .atoi_done
    
    cmp bl, '0'
    jb .atoi_error
    cmp bl, '9'
    ja .atoi_error
    
    sub bl, '0'
    push bx
    mul cx
    pop bx
    add ax, bx
    
    inc si
    jmp .atoi_loop
    
.atoi_done:
    clc
    pop si
    pop dx
    pop cx
    pop bx
    ret
    
.atoi_error:
    stc
    pop si
    pop dx
    pop cx
    pop bx
    ret

; ============================================
; INPUT FUNCTION
; ============================================

read_string_safe:
    push cx
    push di
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
    pop di
    pop cx
    ret

print_number:
    push ax
    push bx
    push cx
    push dx
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
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; COMMAND PARSER
; ============================================

parse_and_execute:
    mov di, command_copy
    mov si, input_buffer
    call strcpy

    mov si, command_copy
.find_cmd_end:
    lodsb
    test al, al
    jz .cmd_only
    cmp al, ' '
    jne .find_cmd_end

    dec si
    mov byte [si], 0
    inc si

.save_args:
    mov di, command_args
    call strcpy

    mov si, command_copy

    mov di, cmd_echo
    call strcmp
    jc .echo_cmd

    mov di, cmd_ver
    call strcmp
    jc .ver_cmd

    mov di, cmd_cube
    call strcmp
    jc .cube_cmd

    mov di, cmd_reboot
    call strcmp
    jc .reboot_cmd

    mov di, cmd_time
    call strcmp
    jc .time_cmd

    mov di, cmd_shutdown
    call strcmp
    jc .shutdown_cmd

    mov di, cmd_browser
    call strcmp
    jc .browser_cmd

    mov di, cmd_calc
    call strcmp
    jc .calc_cmd

    mov di, cmd_kernel
    call strcmp
    jc .kernel_cmd

    mov di, cmd_crash
    call strcmp
    jc .crash_cmd

    mov di, cmd_fetch
    call strcmp
    jc .fetch_cmd

    mov di, cmd_author
    call strcmp
    jc .author_cmd

    mov di, cmd_32bit
    call strcmp
    jc .32bit_cmd

    mov di, cmd_help
    call strcmp
    jc .help_cmd

    mov di, cmd_clear
    call strcmp
    jc .clear_cmd

    mov di, cmd_ls
    call strcmp
    jc .ls_cmd

    mov di, cmd_create
    call strcmp
    jc .create_cmd

    mov di, cmd_edit
    call strcmp
    jc .edit_cmd

    mov di, cmd_rm
    call strcmp
    jc .rm_cmd

.unknown_cmd:
    mov si, unknown_cmd_msg
    call print_string
    ret

.cmd_only:
    mov byte [command_args], 0
    jmp .save_args

; ============================================
; COMMAND HANDLERS
; ============================================

.ver_cmd:
    mov si, welcome_msg
    call print_string
    ret

.cube_cmd:
    call draw_cube
    ret

.reboot_cmd:
    mov al, 0xFE
    out 0x64, al
    jmp 0xFFFF:0x0000

.time_cmd:
    mov si, command_args
    mov di, time_update_arg
    call strcmp
    jc .time_update_cmd
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
    call shutdown_system
    ret

.browser_cmd:
    mov si, browser_msg
    call print_string
    ret

.calc_cmd:
    call calculator
    ret

.kernel_cmd:
    mov si, kernel_info
    call print_string
    ret

.crash_cmd:
    mov ax, 0x13
    int 0x10

    push 0xA000
    pop es
    mov al, 0x28
    xor di, di
    mov cx, 320*200
    rep stosb

    mov si, panic_title
    mov dh, 10
    mov dl, 12
    mov bl, 0x0F
    call draw_text_gfx

    mov si, panic_msg
    mov dh, 12
    mov dl, 12
    mov bl, 0x0F
    call draw_text_gfx

    mov si, panic_reboot
    mov dh, 14
    mov dl, 8
    mov bl, 0x0F
    call draw_text_gfx

    mov ah, 0x00
    int 0x16

    jmp 0xFFFF:0x0000

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

.clear_cmd:
    mov ax, 0x0003
    int 0x10
    ret

.ls_cmd:
    call fs_list
    ret

.create_cmd:
    call fs_create
    ret

.edit_cmd:
    call ueditor
    ret

.rm_cmd:
    call fs_remove
    ret

; ============================================
; SHUTDOWN SYSTEM
; ============================================

shutdown_system:
    mov si, shutdown_msg
    call print_string

    mov ax, 0x5301
    xor bx, bx
    int 0x15

    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x0102
    int 0x15

    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

    mov dx, 0x0CF9
    mov al, 0x06
    out dx, al

    mov dx, 0xB004
    mov ax, 0x2000
    out dx, ax

    mov dx, 0x0604
    mov ax, 0x2000
    out dx, ax

    mov dx, 0x4004
    mov ax, 0x3400
    out dx, ax

    mov dx, 0x0CF9
    mov al, 0x0E
    out dx, al

    mov al, 0xFE
    out 0x64, al

    mov si, shutdown_fail_msg
    call print_string
    cli
    hlt
    jmp $

; ============================================
; CALCULATOR
; ============================================

calculator:
    mov si, calc_banner
    call print_string

.calc_loop:
    mov si, calc_prompt
    call print_string
    mov di, calc_buffer
    call read_string_safe
    
    mov si, calc_buffer
    cmp byte [si], 'q'
    je .calc_quit
    cmp byte [si], 'Q'
    je .calc_quit
    
    mov si, calc_buffer
    call atoi
    jc .calc_error
    push ax

    mov si, calc_op_prompt
    call print_string
    mov ah, 0x00
    int 0x16
    mov byte [calc_op], al
    mov ah, 0x0E
    int 0x10
    
    mov si, newline
    call print_string

    cmp byte [calc_op], 'q'
    je .calc_pop_quit
    cmp byte [calc_op], 'Q'
    je .calc_pop_quit

    cmp byte [calc_op], '+'
    je .valid_op
    cmp byte [calc_op], '-'
    je .valid_op
    cmp byte [calc_op], '*'
    je .valid_op
    cmp byte [calc_op], '/'
    je .valid_op
    
    pop ax
    mov si, calc_op_error_msg
    call print_string
    jmp .calc_loop

.valid_op:
    mov si, calc_prompt
    call print_string
    mov di, calc_buffer
    call read_string_safe
    
    mov si, calc_buffer
    cmp byte [si], 'q'
    je .calc_pop_quit
    cmp byte [si], 'Q'
    je .calc_pop_quit
    
    mov si, calc_buffer
    call atoi
    jc .calc_pop_error
    
    mov bx, ax
    pop ax

    cmp byte [calc_op], '+'
    je .do_add
    cmp byte [calc_op], '-'
    je .do_sub
    cmp byte [calc_op], '*'
    je .do_mul
    cmp byte [calc_op], '/'
    je .do_div
    jmp .calc_loop

.do_add:
    add ax, bx
    jmp .show_result

.do_sub:
    sub ax, bx
    jmp .show_result

.do_mul:
    mul bx
    jmp .show_result

.do_div:
    cmp bx, 0
    je .div_zero
    xor dx, dx
    div bx
    jmp .show_result

.div_zero:
    mov si, calc_div_zero
    call print_string
    jmp .calc_loop

.show_result:
    push ax
    mov si, calc_result
    call print_string
    pop ax
    call print_number
    mov si, newline
    call print_string
    jmp .calc_loop

.calc_error:
    mov si, calc_error_msg
    call print_string
    jmp .calc_loop

.calc_pop_error:
    pop ax
    mov si, calc_error_msg
    call print_string
    jmp .calc_loop

.calc_pop_quit:
    pop ax

.calc_quit:
    mov si, calc_exit_msg
    call print_string
    ret

; ============================================
; GRAPHICS FUNCTIONS
; ============================================

draw_text_gfx:
    push ax
    push bx
    push cx
    push dx
    push si

.char_loop:
    lodsb
    test al, al
    jz .draw_done

    pusha
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    popa

    inc dl
    jmp .char_loop

.draw_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

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

; ============================================
; URamFS
; ============================================

init_uramfs:
    push ax
    push cx
    push di
    push es

    push ds
    pop es
    mov di, fs_table
    mov cx, MAX_FILES * 17
    xor al, al
    rep stosb

    mov di, fs_data
    mov cx, MAX_FILES * MAX_FILESIZE
    rep stosb

    pop es
    pop di
    pop cx
    pop ax
    ret

fs_list:
    push ax
    push cx
    push si
    push di

    mov si, fs_list_header
    call print_string

    xor cx, cx
    mov byte [files_found], 0

.list_loop:
    cmp cx, MAX_FILES
    jae .list_done

    push cx
    mov ax, cx
    mov bx, 17
    mul bx
    mov di, fs_table
    add di, ax

    cmp byte [di + 16], 1
    jne .next_file

    inc byte [files_found]

    mov si, di
    call print_string

    push di
    mov si, fs_size_prefix
    call print_string
    pop di

    mov ax, [di + 12]
    call print_number
    mov si, fs_bytes_msg
    call print_string

.next_file:
    pop cx
    inc cx
    jmp .list_loop

.list_done:
    cmp byte [files_found], 0
    jne .exit_list
    mov si, fs_empty
    call print_string

.exit_list:
    pop di
    pop si
    pop cx
    pop ax
    ret

fs_create:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    cmp byte [command_args], 0
    je .no_name

    xor cx, cx

.find_slot:
    cmp cx, MAX_FILES
    jae .fs_full

    push cx
    mov ax, cx
    mov bx, 17
    mul bx
    mov di, fs_table
    add di, ax
    cmp byte [di + 16], 0
    pop cx
    je .slot_found

    inc cx
    jmp .find_slot

.slot_found:
    push cx
    push di
    mov si, command_args
    call strcpy
    pop di
    pop cx

    mov word [di + 12], 0
    mov ax, cx
    mov bx, MAX_FILESIZE
    mul bx
    mov [di + 14], ax
    mov byte [di + 16], 1

    mov si, fs_create_msg
    call print_string
    mov si, command_args
    call print_string
    mov si, newline
    call print_string
    jmp .exit_create

.no_name:
    mov si, fs_no_name
    call print_string
    jmp .exit_create

.fs_full:
    mov si, fs_full_msg
    call print_string

.exit_create:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

fs_remove:
    push ax
    push cx
    push si
    push di

    cmp byte [command_args], 0
    je .rm_no_name

    xor cx, cx

.rm_find:
    cmp cx, MAX_FILES
    jae .rm_not_found

    push cx
    mov ax, cx
    mov bx, 17
    mul bx
    mov di, fs_table
    add di, ax
    cmp byte [di + 16], 1
    jne .rm_next

    mov si, command_args
    push di
    call strcmp
    pop di
    jc .rm_found

.rm_next:
    pop cx
    inc cx
    jmp .rm_find

.rm_found:
    pop cx
    mov byte [di + 16], 0
    mov word [di + 12], 0
    mov si, fs_removed_msg
    call print_string
    jmp .rm_exit

.rm_not_found:
    mov si, fs_not_found_msg
    call print_string
    jmp .rm_exit

.rm_no_name:
    mov si, fs_no_name
    call print_string

.rm_exit:
    pop di
    pop si
    pop cx
    pop ax
    ret

fs_find_file:
    push ax
    push bx
    push si

    xor cx, cx

.find_loop:
    cmp cx, MAX_FILES
    jae .not_found

    push cx
    mov ax, cx
    mov bx, 17
    mul bx
    mov di, fs_table
    add di, ax
    cmp byte [di + 16], 1
    jne .next_find

    push di
    call strcmp
    pop di
    jc .found

.next_find:
    pop cx
    inc cx
    jmp .find_loop

.found:
    pop cx
    stc
    jmp .exit_find

.not_found:
    clc

.exit_find:
    pop si
    pop bx
    pop ax
    ret

; ============================================
; UEDITOR
; ============================================

ueditor:
    mov si, editor_banner
    call print_string

    mov si, editor_prompt
    call print_string
    mov di, edit_filename
    call read_string_safe

    mov di, edit_buffer
    mov al, 0
    mov cx, 512
    rep stosb
    mov word [edit_pos], 0

    mov si, edit_filename
    call fs_find_file
    jnc .edit_loop

    push di
    mov si, [di + 14]
    add si, fs_data
    mov cx, [di + 12]
    mov di, edit_buffer
    rep movsb
    pop di
    mov ax, [di + 12]
    mov [edit_pos], ax

.edit_loop:
    mov ax, 0x0003
    int 0x10

    mov si, edit_buffer
    call print_string

    mov si, editor_status
    call print_string

    mov ah, 0x00
    int 0x16

    cmp al, 0x1B
    je .save_exit
    cmp al, 0x08
    je .edit_backspace
    cmp al, 0x0D
    je .edit_newline

    cmp al, ' '
    jb .edit_loop
    cmp al, '~'
    ja .edit_loop

    cmp word [edit_pos], 511
    jae .edit_loop

    mov bx, [edit_pos]
    mov [edit_buffer + bx], al
    inc word [edit_pos]
    mov byte [edit_buffer + bx + 1], 0
    jmp .edit_loop

.edit_backspace:
    cmp word [edit_pos], 0
    je .edit_loop
    dec word [edit_pos]
    mov bx, [edit_pos]
    mov byte [edit_buffer + bx], 0
    jmp .edit_loop

.edit_newline:
    cmp word [edit_pos], 510
    jae .edit_loop

    mov bx, [edit_pos]
    mov byte [edit_buffer + bx], 0x0D
    inc word [edit_pos]
    mov byte [edit_buffer + bx + 1], 0x0A
    inc word [edit_pos]
    mov byte [edit_buffer + bx + 2], 0
    jmp .edit_loop

.save_exit:
    mov si, edit_filename
    call fs_find_file
    jc .update_file

    mov si, edit_filename
    mov di, command_args
    call strcpy
    call fs_create

    mov si, edit_filename
    call fs_find_file
    jnc .save_error

.update_file:
    push di
    mov si, edit_buffer
    mov di, [di + 14]
    add di, fs_data
    mov cx, [edit_pos]
    rep movsb
    pop di

    mov ax, [edit_pos]
    mov [di + 12], ax

.save_error:
    mov ax, 0x0003
    int 0x10

    mov si, editor_saved
    call print_string
    ret

; ============================================
; SYSTEM INFO (FIXED FORMATTING)
; ============================================

show_system_info:
    ; OS Name
    mov si, fetch_os
    call print_string
    
    ; RAM
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
    mov si, newline
    call print_string
    
    ; URamFS
    mov si, fetch_fs
    call print_string
    call fs_count_used
    call print_number
    mov si, fetch_fs_total
    call print_string

    ret

fs_count_used:
    push cx
    push di

    mov cx, MAX_FILES
    xor ax, ax
    xor di, di

.count_loop:
    push di
    push ax
    mov ax, di
    mov bx, 17
    mul bx
    add ax, fs_table
    mov si, ax
    cmp byte [si + 16], 1
    pop ax
    jne .count_next
    inc ax
.count_next:
    pop di
    inc di
    loop .count_loop

    pop di
    pop cx
    ret

get_memory_mb:
    mov ax, 0xE801
    int 0x15
    jc .try_old_method

    mov cx, ax
    mov ax, bx
    mov bx, 64
    mul bx
    add cx, ax

    mov ax, cx
    mov bx, 1024
    xor dx, dx
    div bx
    ret

.try_old_method:
    mov ah, 0x88
    int 0x15
    jc .unknown_mem

    mov cx, ax
    mov ax, cx
    mov bx, 1024
    xor dx, dx
    div bx
    ret

.unknown_mem:
    mov ax, 0
    ret

; ============================================
; TIME FUNCTIONS
; ============================================

show_time:
    call show_time_no_newline
    mov si, newline
    call print_string
    ret

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

; ============================================
; DATA SECTION
; ============================================

welcome_msg db 'Uturu OS Beta 7', 0x0D, 0x0A, 0
prompt db '> ', 0
newline db 0x0D, 0x0A, 0

cmd_ver db 'ver', 0
cmd_cube db 'cube', 0
cmd_reboot db 'reboot', 0
cmd_time db 'time', 0
cmd_shutdown db 'shutdown', 0
cmd_browser db 'browser', 0
cmd_calc db 'calc', 0
cmd_kernel db 'kernel', 0
cmd_crash db 'crash', 0
cmd_fetch db 'fetch', 0
cmd_echo db 'echo', 0
cmd_author db 'author', 0
cmd_32bit db '32-bit', 0
cmd_help db 'help', 0
cmd_clear db 'clear', 0
cmd_ls db 'ls', 0
cmd_create db 'create', 0
cmd_edit db 'edit', 0
cmd_rm db 'rm', 0

time_update_arg db 'update', 0

unknown_cmd_msg db 'Unknown command. Type "help" for list.', 0x0D, 0x0A, 0
browser_msg db 'Browser not implemented yet', 0x0D, 0x0A, 0
kernel_info db 'Kernel: Uturu OS Beta 7 (build 2026)', 0x0D, 0x0A, 0

panic_title db '*** KERNEL PANIC ***', 0
panic_msg db 'System has been halted.', 0
panic_reboot db 'Press any key to reboot...', 0

mb_msg db ' MB', 0x0D, 0x0A, 0
author_msg db 'Author: Semyon5700', 0x0D, 0x0A, 'License: GPL 3.0', 0x0D, 0x0A, 0
bit32_msg db '32-bit mode is planned but not implemented yet.', 0x0D, 0x0A, 'You can fork and add it yourself!', 0x0D, 0x0A, 0
help_msg db 'Commands: ver, cube, reboot, time [update], shutdown, browser', 0x0D, 0x0A
         db '         calc, kernel, crash, fetch, echo, author', 0x0D, 0x0A
         db '         help, clear, ls, create, edit, rm', 0x0D, 0x0A, 0

fetch_os db 'OS: Uturu OS Beta 7', 0x0D, 0x0A, 0
fetch_ram db 'RAM: ', 0
fetch_time db 'Time: ', 0
fetch_fs db 'URamFS files: ', 0
fetch_fs_total db ' / 16', 0x0D, 0x0A, 0

time_str db '00:00:00', 0x0D, 0x0A, 0
time_str_temp db '00:00:00', 0
time_update_msg db 'Enter new time (HH:MM:SS): ', 0
time_updated_msg db 'Time updated', 0x0D, 0x0A, 0
time_error_msg db 'Invalid time format', 0x0D, 0x0A, 0

shutdown_msg db 'Shutting down...', 0x0D, 0x0A, 0
shutdown_fail_msg db 'Shutdown failed. System halted.', 0x0D, 0x0A, 0

calc_banner db 'Uturu Calculator v0.1', 0x0D, 0x0A
           db 'Operations: + - * /  (q to quit)', 0x0D, 0x0A, 0
calc_prompt db 'Enter number: ', 0
calc_op_prompt db 'Operator (+, -, *, /): ', 0
calc_result db 'Result: ', 0
calc_error_msg db 'Error: Invalid number', 0x0D, 0x0A, 0
calc_op_error_msg db 'Error: Invalid operator. Use +, -, *, or /', 0x0D, 0x0A, 0
calc_div_zero db 'Error: Division by zero!', 0x0D, 0x0A, 0
calc_exit_msg db 'Calculator exited.', 0x0D, 0x0A, 0

fs_list_header db 'Files in URamFS:', 0x0D, 0x0A, 0
fs_empty db '  (no files)', 0x0D, 0x0A, 0
fs_size_prefix db ' (', 0
fs_bytes_msg db ' bytes)', 0x0D, 0x0A, 0
fs_create_msg db 'Created file: ', 0
fs_full_msg db 'Error: File system full (max 16 files)', 0x0D, 0x0A, 0
fs_no_name db 'Usage: create <filename>', 0x0D, 0x0A, 0
fs_removed_msg db 'File removed.', 0x0D, 0x0A, 0
fs_not_found_msg db 'File not found.', 0x0D, 0x0A, 0

editor_banner db 'UEditor v0.1 - Simple Text Editor', 0x0D, 0x0A, 0
editor_prompt db 'Filename: ', 0
editor_saved db 'File saved successfully.', 0x0D, 0x0A, 0
editor_status db 0x0D, 0x0A, '--- ESC: Save & Exit | Backspace: Delete ---', 0x0D, 0x0A, 0

; ============================================
; VARIABLES
; ============================================

input_buffer times 32 db 0
command_copy times 32 db 0
command_args times 32 db 0
time_input times 9 db 0
calc_buffer times 32 db 0

edit_filename times 13 db 0
edit_buffer times 512 db 0
edit_pos dw 0

calc_op db 0
files_found db 0

; ============================================
; URamFS SEPARATE AREAS
; ============================================

fs_table times MAX_FILES * 17 db 0
fs_data times MAX_FILES * MAX_FILESIZE db 0

; ============================================
; ALIGNMENT TO 40KB
; ============================================
times 40960-($-$$) db 0
