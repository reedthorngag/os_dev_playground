; moves cursor back one place and over writes with space
; if bx is 1, it assumes it is page 2
; preserves all registers
backspace:
    push ax
    push bx
    push cx
    push dx
    
    mov bh,[print_page]

    mov ah,0x03
    int 0x10
    cmp dl,0
    je .end
    dec dl

    mov ah,0x02
    int 0x10

    mov ax,0x0e20
    int 0x10

    mov ah,0x02
    int 0x10

.end:
    pop dx
    pop cx
    pop bx
    pop ax
    ret