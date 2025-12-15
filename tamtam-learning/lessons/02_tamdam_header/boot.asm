; AFROWAVE / TamTam Learning - Bootsector + TamTam header hexdump
; NASM: nasm -f bin boot.asm -o boot.img
; QEMU: qemu-system-i386 -drive format=raw,file=boot.img

[org 0x7C00]
[bits 16]

%define ATTR 0x07         ; light gray on black

start:
    ; 1) Set up the stack
    cli
    mov ax, 0x7000
    mov ss, ax
    mov sp, 0xFFFF
    sti

    ; 2) Set DS/ES = 0 so labels work with ORG 0x7C00
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; 3) Print banner
    mov si, message
    call print_string

    ; 4) Print TamTam header as hex
    mov si, tamtam_header
    mov cx, 4
    call hexdump

hang:
    hlt
    jmp hang

; -------------------------
; BIOS TTY output helpers
; -------------------------
putc:
    ; input: AL = character
    push ax
    push bx
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, ATTR
    int 0x10
    pop bx
    pop ax
    ret

print_string:
    ; input: DS:SI points to 0-terminated string
    push ax
    push si
.next:
    lodsb
    test al, al
    jz .done
    call putc
    jmp .next
.done:
    pop si
    pop ax
    ret

newline:
    push ax
    mov al, 13
    call putc
    mov al, 10
    call putc
    pop ax
    ret

; -------------------------
; Hex printing (NO BL DATA!)
; -------------------------
print_hex_nibble:
    ; input: AL = 0..15
    cmp al, 9
    jbe .digit
    add al, 7
.digit:
    add al, '0'
    call putc
    ret

print_hex_byte:
    ; input: AL = byte
    ; uses DL as stable storage so BL can stay for attributes
    push ax
    push dx

    mov dl, al

    ; high nibble
    mov al, dl
    shr al, 4
    call print_hex_nibble

    ; low nibble
    mov al, dl
    and al, 0x0F
    call print_hex_nibble

    pop dx
    pop ax
    ret

hexdump:
    ; input: DS:SI = start, CX = length
    push ax
    push cx
    push si
.next:
    lodsb
    call print_hex_byte

    mov al, ' '
    call putc

    loop .next

    call newline
    pop si
    pop cx
    pop ax
    ret

; -------------------------
; Data
; -------------------------
message db "AFROWAVE Community OS 0.1 booting done ", 13,10,"#>",0

; TamTam demo header (4 bytes):
; [0]=lane, [1]=flags, [2..3]=payload_len (LE)
tamtam_header:
    db 01h         ; lane
    db 20h         ; flags
    dw 0034h       ; payload_len = 0x0034 = 52

times 510-($-$$) db 0
dw 0xAA55
