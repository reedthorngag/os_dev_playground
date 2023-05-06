
#include "buffer_actions/_buffer_delete.asm"
#include "console_actions/_console_delete.asm"

; aka backspace
delete:
    call _buffer_delete
    call _console_delete
    ret