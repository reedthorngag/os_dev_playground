
_buffer_shift_left:

    mov al,[cursor_pos.x]

    cmp al,0
    je .shift_up

    dec byte [cursor_pos.x]

    jmp .end

.shift_up:
    call _buffer_shift_up
    call _buffer_goto_line_end

.end:
    ret
