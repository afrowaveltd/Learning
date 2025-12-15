; Hexdump helper
; Exposes: hexdump
; Requires: putc, newline, print_hex_byte

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
