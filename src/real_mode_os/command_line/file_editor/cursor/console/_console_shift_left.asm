
_console_shift_left:

    mov bh,1
    mov ah,0x03
    int 0x10

    cmp dl,0
    je .shift_up

    dec dl
    mov ah,0x02
    int 0x10

    jmp .end

.shift_up:
    cmp dh,0
    je .end
    call _console_shift_up
    mov bl,0xff
    call _console_goto_line_end

.end:
    ret