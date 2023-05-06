
#include "_buffer_goto_line_end.asm"
#include "_buffer_shift_left.asm"
#include "_buffer_shift_right.asm"
#include "_buffer_shift_up.asm"
#include "_buffer_shift_down.asm"

update_cursor_offset:
    xor ax,ax
    mov al,[cursor_pos.y]
    mov bx,0x0080
    mul bx
    xor bx,bx
    mov bl,[cursor_pos.x]
    add ax,bx
    mov word [cursor_offset],ax
    ret

update_cursor_pos:
    ret

cursor_pos: 
    .x: db 0x00 
    .y: db 0x00 ; column, row, if read into register, x is in al, y in ah

num_lines db 0x18
line_width db 0x4f

cursor_offset: dw 0x0000    ; cursor_pos.y * 0x80 + cursor_pos.x
