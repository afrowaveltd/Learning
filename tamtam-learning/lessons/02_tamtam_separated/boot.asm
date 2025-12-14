; Boot sector (512B) - entry + lesson logic
; Build: nasm -f bin src/boot.asm -o boot.img

[org 0x7C00]
[bits 16]

jmp start
nop

%define ATTR 0x07         ; light gray on black

; Include reusable helpers (textual include)
%include "lib/bios_print.inc"
%include "lib/hex_print.inc"
%include "lib/hexdump.inc"

start:
    ; 1) Setup stack (must be done before CALL/PUSH/POP are safe)
    cli
    mov ax, 0x7000
    mov ss, ax
    mov sp, 0xFFFF
    sti

    ; 2) Setup segments for our data (ORG 0x7C00 expects DS=0 here)
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; 3) Print banner
    mov si, message
    call print_string

    ; 4) Dump TamTam header bytes
    mov si, tamtam_header
    mov cx, 4
    call hexdump

hang:
    hlt
    jmp hang

; -------------------------
; Data
; -------------------------
message db "AFROWAVE Community OS 0.1 booting done ", 13, 10, "#> ", 0

; TamTam demo header (4 bytes):
; [0]=lane, [1]=flags, [2..3]=payload_len (little-endian)
tamtam_header:
    db 01h         ; lane
    db 20h         ; flags
    dw 0034h       ; payload_len = 0x0034 = 52

; Boot sector padding + signature
times 510-($-$$) db 0
dw 0xAA55
