
#include "buffer_actions/_buffer_enter.asm"
#include "console_actions/_console_enter.asm"

enter:
    call _buffer_enter
    call _console_enter
    ret
