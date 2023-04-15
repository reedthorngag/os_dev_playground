; ends the current line and goes to the next line
endl:
    push ax
    push bx
    push cx
    push dx

    xor bx,bx
    mov ah,0x03
    int 0x10
    cmp dh,0x13
    je .scroll_reset

    inc dh
    xor dl,dl
    mov ah,0x02
    int 0x10

    mov cx,dx
    inc ch      ; one line on from cursors current line
    mov dx,0x184f
    mov bh,0x07
    mov ax,0x0701
    int 0x10

    jmp .end

.scroll_reset:
    xor cx,cx
    mov dx,0x184f   ; row 24, col 79
    mov bh,0x07     ; white on black character attribute
    mov ax,0x0705   ; scroll 3 lines
    int 0x10

    xor bx,bx
    mov dx,0
    mov ah,0x02
    int 0x10

.end:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
