
.shift_buffer:
    push ax
    push bx
    push cx
    push dx

    mov bx,command_buffer
    add bx,dx

.shift_loop:
    mov ah,[bx]
    mov byte [bx],al
    inc bx
    inc dx

    push ax
    mov ah,0x0e
    int 0x10
    pop ax

    mov al,ah

    cmp dx,cx
    je .end

    jmp .shift_loop


.end:
    mov ah,0x0e
    int 0x10

    mov byte [bx],al
    inc bx
    mov byte [bx],0

    pop bx
    mov ax,cx
    sub ax,bx   ; get the difference between the cursor and the end
    ;dec ax      ; add one because we are moving one place towards the end
    push bx
    mov ah,0x03
    int 0x10
    sub dl,al

    mov ah,0x02
    int 0x10

    pop dx
    pop cx
    pop bx
    pop ax

    inc bx
    inc cx
    inc dx

    jmp .get_key_loop
