
rotate_right:
    push word [pos]
    call get_right
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret