; BIOS text output helpers (INT 10h teletype)
; Exposes: putc, newline, print_string

%define ATTR 0x07     ; light gray on black

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

newline:
    push ax
    mov al, 13
    call putc
    mov al, 10
    call putc
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
