
#include "buffer/_buffer_shift_right.asm"
#include "console/_console_shift_right.asm"

shift_right:
    call _buffer_shift_right
    call _console_shift_right
    ret
