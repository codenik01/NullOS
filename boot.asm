[org 0x7C00]

bits 16

KERNEL_OFFSET equ 0x1000
KERNEL_SECTORS equ 50

start:

    cli

    mov [BOOT_DRIVE], dl

    xor ax, ax

    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7C00

    mov si, boot_msg
    call print_string

    mov bx, KERNEL_OFFSET
    mov dh, KERNEL_SECTORS

    call load_kernel

    jmp 0x0000:KERNEL_OFFSET

; =========================================
; LOAD KERNEL
; =========================================

load_kernel:

    pusha

    mov ax, 0x0000
    mov es, ax

    mov bx, KERNEL_OFFSET

    mov ah, 0x02
    mov al, KERNEL_SECTORS

    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00

    mov dl, [BOOT_DRIVE]

    int 0x13

    jc disk_error

    popa
    ret
; =========================================
; DISK ERROR
; =========================================

disk_error:

    mov si, error_msg
    call print_string

    jmp $

; =========================================
; PRINT STRING
; =========================================

print_string:

.next:

    lodsb

    or al, al
    jz .done

    mov ah, 0x0E
    int 0x10

    jmp .next

.done:
    ret

; =========================================
; DATA
; =========================================

BOOT_DRIVE db 0

boot_msg db 'Loading NullOS...',0
error_msg db 'Disk Read Error!',0

times 510-($-$$) db 0
dw 0xAA55
