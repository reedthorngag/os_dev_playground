
#include "buffer/_buffer_shift_left.asm"
#include "console/_console_shift_left.asm"

shift_left:
    call _buffer_shift_left
    call _console_shift_left
    ret
