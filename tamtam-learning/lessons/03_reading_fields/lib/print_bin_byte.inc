;-------------------------------------------
; Print a single byte in binary format
; Input: AL = byte to print
; Output: prints 8 characters '0' or '1'
; Preserves: AX, CX
;-------------------------------------------

print_bin_byte: 
    push ax
    push cx

    mov cx, 8          ; 8 bits to print
    mov bl, al       ; copy byte to BL for shifting

.bin_loop:
    test bl, 10000000b ; test highest bit
    jz .print_zero
    mov al, '1'
    jmp .print_bit

.print_zero:
    mov al, '0'
    
.print_bit:
    mov ah, 0Eh      ; BIOS teletype function
    int 10h          ; print character in AL
    
    shl bl, 1        ; shift left to get next bit
    loop .bin_loop

    pop cx
    pop ax
    ret