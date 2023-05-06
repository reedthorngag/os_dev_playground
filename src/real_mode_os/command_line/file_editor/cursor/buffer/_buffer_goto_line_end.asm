
; max len in bl, 0xff if uncapped
_buffer_goto_line_end:

    xor cx,cx
    mov cl,bl

    mov ax,cursor_pos.y
    mov bx,line_width
    mul bx

    mov bx,file_data
    add bx,ax

.loop:
    inc ch
    cmp ch,cl
    je .end
    cmp byte [bx],0x0a ; \n
    je .end
    inc bx
    jmp .loop

.end:
    mov byte [cursor_pos.x],ch

    ret
