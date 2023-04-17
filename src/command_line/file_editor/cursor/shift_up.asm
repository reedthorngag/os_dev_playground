
#include "buffer/_buffer_shift_up.asm"
#include "console/_console_shift_up.asm"

shift_up:
    call _buffer_shift_up
    call _console_shift_up
    ret
