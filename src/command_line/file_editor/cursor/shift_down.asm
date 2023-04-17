
#include "buffer/_buffer_shift_down.asm"
#include "console/_console_shift_down.asm"

shift_down:
    call _buffer_shift_down
    call _console_shift_down
    ret
