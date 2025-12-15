; lesson1.asm
; HAL / GATE / ROOF / ROOMS v jednom boot sektoru
;  - HAL:   hal_putchar, BIOS volání
;  - GATE:  gate_print_string, gate_read_key
;  - ROOF:  hlavní menu
;  - ROOMS: CS/EN „místnosti“

org 0x7C00
bits 16

start:
    ; 🟦 HAL init – stack
    cli
    mov ax, 0x7000
    mov ss, ax
    mov sp, 0xFFFF
    sti

    ; 🟦 HAL init – datový segment (0)
    xor ax, ax
    mov ds, ax

    ; 🟧 GATE: vytiskni boot zprávu
    mov si, boot_message
    call gate_print_string

    ; volitelně prázdný řádek
    mov si, msg_menu_intro
    call gate_print_string

    ; 🔺 ROOF: skoč do hlavního menu
    jmp main_menu


;------------------------------
; ROOF: hlavní menu
;------------------------------
main_menu:
    ; vypiš menu
    mov si, msg_menu
    call gate_print_string

    ; přečti klávesu
    call gate_read_key        ; AL = znak

    cmp al, '1'
    je room_cs

    cmp al, '2'
    je room_en

    cmp al, 'q'
    je exit_program
    cmp al, 'Q'
    je exit_program

    ; neznámá volba
    mov si, msg_unknown
    call gate_print_string
    jmp main_menu


;------------------------------
; ROOMS – jednotlivé „místnosti“
;------------------------------
room_cs:
    mov si, msg_room_cs
    call gate_print_string
    jmp main_menu

room_en:
    mov si, msg_room_en
    call gate_print_string
    jmp main_menu


;------------------------------
; ROOF: ukončení – tichý „halt“
; (v boot sektoru není kam se vrátit, takže smyčka)
;------------------------------
exit_program:
    cli
.hang:
    hlt
    jmp .hang


;------------------------------
; GATE – služby pro ROOF
;------------------------------

; gate_print_string
; Vstup: DS:SI ukazuje na 0-ukončený řetězec
gate_print_string:
.next_char:
    lodsb               ; AL = [DS:SI], SI++
    cmp al, 0
    je .done
    call hal_putchar
    jmp .next_char
.done:
    ret


; gate_read_key
; Výstup: AL = stisknutý znak (ASCII)
gate_read_key:
    mov ah, 0
    int 16h             ; HAL: BIOS klávesnice
    ; BIOS vrací v AL znak
    ret


;------------------------------
; HAL – nejnižší vrstva (BIOS)
;------------------------------

; hal_putchar
; Vstup: AL = znak k vypsání
hal_putchar:
    mov ah, 0x0E        ; BIOS teletype
    int 0x10            ; výpis znaku
    ret


;------------------------------
; Data (ROOF / ROOMS / boot)
;------------------------------

boot_message db "AFROWAVE Community OS 0.1 booting done #",13,10,0

msg_menu_intro db 13,10,0

msg_menu db 'BOS Rooms demo (lesson 1)',13,10
          db '1 = CS Room',13,10
          db '2 = EN Room',13,10
          db 'Q = Halt',13,10
          db 'Choice: ',0

msg_room_cs db 13,10,'[CS ROOM] Tady by mohly byt ceske texty, fonty, lokalizace...',13,10,0
msg_room_en db 13,10,'[EN ROOM] Here could live English texts, fonts, localization...',13,10,0

msg_unknown db 13,10,'Unknown choice, try again.',13,10,0


;------------------------------
; Boot podpis
;------------------------------
times 510-($-$$) db 0
dw 0xAA55
