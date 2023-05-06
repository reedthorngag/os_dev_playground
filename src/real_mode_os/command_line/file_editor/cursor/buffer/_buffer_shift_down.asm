
_buffer_shift_down:

    mov bl,[cursor_pos.x]

    dec byte [cursor_pos.y]

    ret