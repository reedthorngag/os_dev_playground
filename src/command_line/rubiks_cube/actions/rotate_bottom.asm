
rotate_bottom:
    push word [pos]
    call get_bottom
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret