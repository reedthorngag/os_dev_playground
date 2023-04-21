
shift_down:
    call _buffer_shift_down
    jnz .end
    call _console_shift_down
.end:
    ret
