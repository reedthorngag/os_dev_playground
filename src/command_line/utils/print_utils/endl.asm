; ends the current line and goes to the next line
; if bh is 1, it assumes it is page 2
endl:
    push ax
    push cx
    push dx
    push bx

    mov bh,[print_page]

    mov ah,0x03
    int 0x10
    cmp dh,0x17
    je .scroll_down

    inc dh
    xor dl,dl
    mov ah,0x02
    int 0x10

    jmp .end

.scroll_down:
    xor cx,cx
    mov dx,0x184f   ; row 24, col 79
    mov bh,0x07     ; white on black character attribute
    mov ax,0x0601   ; scroll 1 line
    int 0x10

    mov bh,[print_page]
    mov dx,0x1700
    mov ah,0x02
    int 0x10

.end:
    pop bx
    pop dx
    pop cx
    pop ax
    ret
