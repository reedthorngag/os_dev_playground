.backspace:
    cmp dx,0
    je .get_key_loop

    dec cx
    dec dx
    dec bx
    push dx
    mov bx,command_buffer
    add bx,dx
    call backspace
.overwrite_loop:
    cmp dx,cx
    je .end_overwrite_loop
    inc bx
    mov al,[bx]
    dec bx
    mov byte [bx], al
    mov ah,0x0e
    int 0x10
    inc bx
    inc dx
    jmp .overwrite_loop
    
.end_overwrite_loop:
    mov byte [bx],0
    mov ax,0x0e20
    int 0x10
    call backspace

    pop dx
    push bx
    push cx
    push dx
    mov ax,cx
    sub ax,dx
    xor bx,bx
    mov ah,0x03
    int 0x10
    sub dl,al

    xor bx,bx
    mov ah,0x02
    int 0x10

    pop dx
    pop cx
    pop bx

.done_overwrite:
    jmp .get_key_loop