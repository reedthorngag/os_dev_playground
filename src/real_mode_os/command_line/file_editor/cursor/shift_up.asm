
shift_up:
    call _buffer_shift_up
    jnz .end
    call _console_shift_up
.end:
    ret
