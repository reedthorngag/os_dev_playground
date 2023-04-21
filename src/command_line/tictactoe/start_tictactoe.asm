
start_tictactoe:

    mov ax,0x0501   ; switch to second page
    int 0x10

    mov bh,1
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10

    ret


tictactoe_redraw:
    ret

; 
draw_tictactoe_line:
    ret
