
#include "_buffer_goto_line_end.asm"
#include "_buffer_shift_left.asm"
#include "_buffer_shift_right.asm"
#include "_buffer_shift_up.asm"
#include "_buffer_shift_down.asm"

cursor_pos: 
    .x: db 0x00 
    .y: db 0x00 ; column, row, if read into register, column is in al, row in ah
