
#include "buffer_actions/_buffer_insert.asm"
#include "console_actions/_console_insert.asm"

; inserts whatever is in al into the buffer and console at respective cursor positions and increments positions
insert:
    push ax
    call _buffer_insert
    pop ax
    call _console_insert

    call shift_right
    ret