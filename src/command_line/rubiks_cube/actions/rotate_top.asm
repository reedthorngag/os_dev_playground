
rotate_top:
    push word [pos]
    call get_top
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret