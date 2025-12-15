[org 0x7C00]
[bits 16]

start:
    ; 🟦 1) Set up the stack
    cli
    mov ax, 0x7000
    mov ss, ax
    mov sp, 0xFFFF
    sti

    ; 🟦 2) Set DS to our code segment (0x0000)
    xor ax, ax
    mov ds, ax

    ; 🟦 3) Call our print_string routine
    mov si, message        ; DS:SI -> our text
    call print_string      ; call the routine

hang:
    jmp hang               ; infinite loop (for now)

; -----------------------------------
; Procedure: print_string
; Input: DS:SI points to a 0-terminated string
; Output: none (prints to the screen)
; Preserves: SI, AX (restored to original values)
; -----------------------------------
print_string:
    push ax                ; save AX so caller keeps its value
    push si                ; save SI because we'll modify it

.print_loop:
    lodsb                  ; AL = [DS:SI], SI++
    or al, al              ; test AL==0 (faster than cmp al, 0)
    jz .done               ; if 0 -> end of string

    mov ah, 0x0E           ; BIOS teletype
    int 0x10               ; print AL
    jmp .print_loop

.done:
    pop si                 ; restore original SI
    pop ax                 ; restore original AX
    ret                    ; return - pops return address from stack

; -----------------------------------
; Data
; -----------------------------------
message db "AFROWAVE Community OS 0.1 booting done ", 13,10,"#>",0

times 510-($-$$) db 0
dw 0xAA55
