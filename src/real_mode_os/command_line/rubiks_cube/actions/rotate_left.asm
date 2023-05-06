
rotate_left:
    push word [pos]
    call get_left
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret
