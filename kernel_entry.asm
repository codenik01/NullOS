bits 16

global start
extern kernel_main

CODE_SEG equ 0x08
DATA_SEG equ 0x10

start:

    cli

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:protected_mode

; =========================================
; GDT
; =========================================

gdt_start:

    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:

    dw gdt_end - gdt_start - 1
    dd gdt_start

; =========================================
; PROTECTED MODE
; =========================================

bits 32

protected_mode:

    mov ax, DATA_SEG

    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    call kernel_main

halt:

    hlt
    jmp halt
