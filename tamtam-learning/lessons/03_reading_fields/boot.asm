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
%include "lib/print_bin_byte.inc"

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
   ; SI -> start hlavičky
   mov si, tamtam_header

; --- lane ---
lodsb
mov bl, al
push si
mov si, msg_lane
call print_string
pop si
mov al, bl
call print_hex_byte

mov al, ' '
mov ah, 0Eh
int 10h
mov al, ' '
int 10h

mov al, bl
call print_bin_byte
call newline

; --- flags ---
lodsb
mov bl, al
push si
mov si, msg_flags
call print_string
pop si
mov al, bl
call print_hex_byte
mov al, ' '
mov ah, 0Eh
int 10h
mov al, ' '
int 10h
mov al, bl
call print_bin_byte
call newline

; --- length (16 bit little-endian) ---
lodsb
mov dl, al
lodsb
mov dh, al

push si
mov si, msg_length
call print_string
pop si

mov al, dh
call print_hex_byte
mov al, dl
call print_hex_byte

mov al, ' '
mov ah, 0Eh
int 10h
mov al, ' '
int 10h

mov al, dh
call print_bin_byte
mov al, ' '
mov ah, 0Eh
int 10h
mov al, dl
call print_bin_byte

call newline


hang:
    hlt
    jmp hang

; -------------------------
; Data
; -------------------------
message db "AFROWAVE Community OS 0.1 booting done ", 13, 10, 0

msg_lane   db "lane:   0x", 0
msg_flags  db "flags:  0x", 0
msg_length db "length: 0x", 0

; TamTam demo header (4 bytes):
; [0]=lane, [1]=flags, [2..3]=payload_len (little-endian)
tamtam_header:
    db 01h         ; lane
    db 0A0h        ; flags
    dw 0034h       ; payload_len = 0x0034 = 52

; Boot sector padding + signature
times 510-($-$$) db 0
dw 0xAA55