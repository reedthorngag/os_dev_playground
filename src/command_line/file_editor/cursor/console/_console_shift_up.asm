
_console_shift_up:

    mov bh,1
    mov ah,0x03
    int 0x10

    cmp dh,0
    je .end

    dec dh
    mov ah,0x02
    int 0x10

    mov bl,dl
    call _console_goto_line_end

.end:
    ret