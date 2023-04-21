; ls command
ls:
    mov bx,3
    call get_arg
    jne .failed
    call print_str
    jmp .end

.failed:
    mov si,ls_failed
    call print_str

.end:
    call endl
    xor ax,ax
    ret

ls_failed: db 'ls command failed!',0
