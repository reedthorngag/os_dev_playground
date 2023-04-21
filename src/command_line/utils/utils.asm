
#include "compare_command_name.asm"
#include "get_arg.asm"

#include "print_utils/backspace.asm"
#include "print_utils/endl.asm"
#include "print_utils/tab.asm"
#include "print_utils/pad_line.asm"

; wipes page and moves cursor to start
; page number in bh
reset_page:
    push bx
    xor cx,cx
    mov bh,0x07     ; white on black
    mov dx,0x184f
    mov ax,0x0700   ; wipe page
    int 0x10

    pop bx
    xor dx,dx
    mov ah,0x02     ; move cursor to start
    int 0x10
    ret

