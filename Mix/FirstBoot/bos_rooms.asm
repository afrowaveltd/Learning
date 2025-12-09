org 100h              ; .COM start offset

;------------------------------
; ROOF: vstupní bod
;------------------------------
start:
    mov ax, cs
    mov ds, ax        ; DS = CS, ať nám sedí adresy dat

main_menu:
    ; GATE: vypiš menu
    mov si, msg_menu
    call gate_print_string

    ; GATE: přečti klávesu
    call gate_read_key

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
; ROOMS
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
; ROOF: ukončení programu
;------------------------------
exit_program:
    ret    ; návrat zpět do DOSu


;------------------------------
; GATE vrstvy – služby pro ROOF
;------------------------------

; gate_print_string
; Vstup: DS:SI ukazuje na řetězec ukončený 0
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
    int 16h                 ; HAL: BIOS klávesnice
    ; BIOS vrací v AL znak
    ret


;------------------------------
; HAL – nejnižší vrstva (BIOS)
;------------------------------

; hal_putchar
; Vstup: AL = znak k vypsání
hal_putchar:
    mov ah, 0x0E            ; BIOS teletype
    int 10h                 ; výpis znaku
    ret


;------------------------------
; Data (ROOF / ROOMS texty)
;------------------------------
msg_menu db 13,10, 'BOS Rooms demo',13,10
         db '1 = CS Room',13,10
         db '2 = EN Room',13,10
         db 'Q = Quit',13,10
         db 'Choice: ',0

msg_room_cs db 13,10,'[CS ROOM] Tady by mohly byt ceske texty, fonty, lokalizace...',13,10,0
msg_room_en db 13,10,'[EN ROOM] Here could live English texts, fonts, localization...',13,10,0

msg_unknown db 13,10,'Unknown choice, try again.',13,10,0
