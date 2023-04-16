; clears screen
clear:
    xor cx,cx
    mov bh,0x07     ; white text on black
    mov dx,0x184f
    mov ax,0x0700
    int 0x10

    xor bx,bx
    xor dx,dx
    mov ah,0x02
    int 0x10

    ret
    
