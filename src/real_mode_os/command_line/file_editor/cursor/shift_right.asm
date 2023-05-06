
shift_right:
    call _buffer_shift_right
    jnz .end
    call _console_shift_right
.end:
    ret
