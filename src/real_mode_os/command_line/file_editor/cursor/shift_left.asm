
shift_left:
    call _buffer_shift_left
    jnz .end
    call _console_shift_left
.end:
    ret
