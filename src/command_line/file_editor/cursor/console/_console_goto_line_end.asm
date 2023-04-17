; set bl to max line position, or 0xff if no max
_console_goto_line_end:

    mov ax,0x4f
    cmp bl,0xff
    cmove bx,ax

    mov bh,1
    mov ah,0x03
    int 0x10

    xor dl,dl
.find_end_loop:
    cmp dl,bl
    je .end

    mov ah,0x08
    int 0x10
    cmp al,0x0a ; \n
    je .end

    inc dl
    mov ah,0x02
    int 0x10

    jmp .find_end_loop

.end:
    ret