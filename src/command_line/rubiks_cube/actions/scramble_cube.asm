
scramble_cube:

    mov cx,0x0200
    jmp .gen
.loop:
    dec cx
    jz .end
.gen:
    call get_random
    shr ax,12   ; 4 bits of data, 16 values
    cmp ax,8
    jg .gen

    push ax
    shl ax,1

    mov bx,move_func_map
    add bx,ax
    mov si,[bx]
    add si,0x7c00

    push cx
    call si
    pop cx

    pop dx
    test dx,1   ; rotations are even numbered, and dont require further actions
    jne .loop

    mov word [pos],ax

    jmp .loop

.end:
    mov word [pos],0x0101
    ret


move_func_map:
    dw rotate_bottom
    dw get_top
    dw rotate_front
    dw get_left
    dw rotate_left
    dw get_right
    dw rotate_right
    dw get_bottom
    dw rotate_top
