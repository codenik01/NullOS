[org 0x1000]

bits 16

CODE_SEG equ 0x08
DATA_SEG equ 0x10

start:

    cli

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:protected_mode

; ==================================================
; GDT
; ==================================================

gdt_start:

    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; ==================================================
; PROTECTED MODE
; ==================================================

bits 32

protected_mode:

    mov ax, DATA_SEG

    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    call clear_screen

    ; WELCOME COLOR = CYAN

    mov byte [current_color], 0x0B

    mov esi, welcome_msg
    call print_string

    ; PROMPT COLOR = GREEN

    mov byte [current_color], 0x0A

    mov esi, prompt
    call print_string

; ==================================================
; MAIN LOOP
; ==================================================

main_loop:

    call keyboard_read

    cmp al, 0
    je main_loop

    cmp al, 8
    je .backspace

    cmp al, 13
    je .enter

    ; NORMAL TEXT = WHITE

    mov byte [current_color], 0x0F

    ; PRINT CHARACTER

    call print_char

    ; STORE IN BUFFER

    mov ebx, [buffer_index]

    mov [command_buffer + ebx], al

    inc dword [buffer_index]

    jmp main_loop

.backspace:

    cmp dword [buffer_index], 0
    je main_loop

    dec dword [buffer_index]

    call do_backspace

    jmp main_loop

.enter:

    ; TERMINATE STRING

    mov ebx, [buffer_index]

    mov byte [command_buffer + ebx], 0

    call do_newline

    ; ==========================
    ; HELP
    ; ==========================

    mov esi, command_buffer
    mov edi, cmd_help
    call strcmp

    cmp eax, 1
    je .help

    ; ==========================
    ; CLEAR
    ; ==========================

    mov esi, command_buffer
    mov edi, cmd_clear
    call strcmp

    cmp eax, 1
    je .clear

    ; ==========================
    ; ABOUT
    ; ==========================

    mov esi, command_buffer
    mov edi, cmd_about
    call strcmp

    cmp eax, 1
    je .about

    ; ==========================
    ; UNKNOWN COMMAND
    ; ==========================

    mov byte [current_color], 0x0C

    mov esi, unknown_msg
    call print_string

    call do_newline

    jmp .reset

.help:

    mov byte [current_color], 0x0B

    mov esi, help_msg
    call print_string

    call do_newline

    jmp .reset

.clear:

    call clear_screen

    jmp .reset

.about:

    mov byte [current_color], 0x0E

    mov esi, about_msg
    call print_string

    call do_newline

.reset:

    ; CLEAR BUFFER

    mov dword [buffer_index], 0

    ; SHOW PROMPT

    mov byte [current_color], 0x0A

    mov esi, prompt
    call print_string

    jmp main_loop

; ==================================================
; PRINT CHARACTER
; ==================================================

print_char:

    push eax
    push ebx
    push edx
    push edi

    mov bl, al

    mov eax, [cursor_y]

    mov edx, 80

    mul edx

    add eax, [cursor_x]

    shl eax, 1

    mov edi, 0xB8000

    add edi, eax

    mov al, bl

    mov ah, [current_color]

    mov word [edi], ax

    inc dword [cursor_x]

    cmp dword [cursor_x], 80
    jl .done

    call do_newline

.done:

    pop edi
    pop edx
    pop ebx
    pop eax

    call update_cursor

    ret

; ==================================================
; PRINT STRING
; ==================================================

print_string:

.next:

    lodsb

    test al, al
    jz .done

    cmp al, 13
    je .skip

    cmp al, 10
    je .newline

    call print_char

    jmp .next

.newline:

    call do_newline

    jmp .next

.skip:

    jmp .next

.done:
    ret

; ==================================================
; STRING COMPARE
; ==================================================

strcmp:

.compare:

    mov al, [esi]
    mov bl, [edi]

    cmp al, bl
    jne .not_equal

    cmp al, 0
    je .equal

    inc esi
    inc edi

    jmp .compare

.equal:

    mov eax, 1
    ret

.not_equal:

    mov eax, 0
    ret

; ==================================================
; NEW LINE
; ==================================================

do_newline:

    mov dword [cursor_x], 0

    inc dword [cursor_y]

    cmp dword [cursor_y], 25
    jl .done

    call scroll_screen

    mov dword [cursor_y], 24

.done:

    call update_cursor

    ret

; ==================================================
; UPDATE CURSOR
; ==================================================

update_cursor:

    push eax
    push ebx
    push edx

    mov eax, [cursor_y]

    mov ebx, 80

    mul ebx

    add eax, [cursor_x]

    mov bx, ax

    ; LOW BYTE

    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al

    mov dx, 0x3D5
    mov al, bl
    out dx, al

    ; HIGH BYTE

    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al

    mov dx, 0x3D5
    mov al, bh
    out dx, al

    pop edx
    pop ebx
    pop eax

    ret

; ==================================================
; BACKSPACE
; ==================================================

do_backspace:

    cmp dword [cursor_x], 0
    je .done

    dec dword [cursor_x]

    mov eax, [cursor_y]

    mov edx, 80

    mul edx

    add eax, [cursor_x]

    shl eax, 1

    mov edi, 0xB8000

    add edi, eax

    mov ah, [current_color]
    mov al, ' '

    mov word [edi], ax

.done:

    call update_cursor

    ret

; ==================================================
; CLEAR SCREEN
; ==================================================

clear_screen:

    push eax
    push ecx
    push edi

    mov edi, 0xB8000

    mov ecx, 2000

.clear:

    mov word [edi], 0x0720

    add edi, 2

    loop .clear

    mov dword [cursor_x], 0
    mov dword [cursor_y], 0

    pop edi
    pop ecx
    pop eax

    call update_cursor

    ret

; ==================================================
; SCROLL SCREEN
; ==================================================

scroll_screen:

    push eax
    push ecx
    push esi
    push edi

    ; MOVE ALL ROWS UP

    mov esi, 0xB8000 + 160
    mov edi, 0xB8000

    mov ecx, 24 * 80

.copy:

    mov ax, [esi]

    mov [edi], ax

    add esi, 2
    add edi, 2

    loop .copy

    ; CLEAR LAST ROW

    mov ecx, 80

.clear_last:

    mov word [edi], 0x0720

    add edi, 2

    loop .clear_last

    pop edi
    pop esi
    pop ecx
    pop eax

    ret

; ==================================================
; KEYBOARD INPUT
; ==================================================

keyboard_read:

.wait:

    in al, 0x64

    test al, 1
    jz .wait

    in al, 0x60

    cmp al, 0x80
    jae .ignore

    movzx ebx, al

    mov al, [keyboard_map + ebx]

    ret

.ignore:

    mov al, 0
    ret

; ==================================================
; KEYBOARD MAP
; ==================================================

keyboard_map:

db 0
db 27
db '1','2','3','4','5','6','7','8','9','0'
db '-','='
db 8
db 9

db 'q','w','e','r','t','y','u','i','o','p'
db '[',']'
db 13
db 0

db 'a','s','d','f','g','h','j','k','l'
db ';',39,'`'
db 0
db '\'

db 'z','x','c','v','b','n','m'
db ',', '.', '/'
db 0
db '*'
db 0
db ' '

times 128-($-keyboard_map) db 0

; ==================================================
; DATA
; ==================================================

cursor_x dd 0
cursor_y dd 0

current_color db 0x0F

welcome_msg db 'Welcome to NullOS!',13,10
            db 'Protected Mode Active',13,10
            db 'Keyboard Ready...',13,10,0

prompt db 'NullOS> ',0

command_buffer times 128 db 0
buffer_index dd 0

cmd_help  db 'help',0
cmd_clear db 'clear',0
cmd_about db 'about',0

help_msg db 'Commands: help clear about',0

about_msg db 'NullOS Version 0.1',0

unknown_msg db 'Unknown Command',0
