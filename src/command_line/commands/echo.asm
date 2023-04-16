; echo command
echo:
    mov bx,0
    call get_arg
    sub bx,si
    mov si,command_buffer
    add si,bx
    inc si
    call print_str

    call endl
    ret
