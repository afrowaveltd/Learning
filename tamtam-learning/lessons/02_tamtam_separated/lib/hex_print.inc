; Hex printing helpers
; Exposes: print_hex_nibble, print_hex_byte
; Rule: BL is reserved for BIOS attribute only (inside putc)

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
    ; uses DL as stable storage (so BL can be used by BIOS printing)
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
