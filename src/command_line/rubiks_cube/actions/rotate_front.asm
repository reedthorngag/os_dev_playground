
rotate_front:
    mov si,line
    mov di,example_line
    call copy_str
    call get_current
    mov ax,0x0001
    call read_write_line
    mov ax,0x0100
    call read_write_line
    mov ax,0x0002
    call read_write_line
    mov ax,0x0200
    call read_write_line
    mov ax,0x0001
    call read_write_line

    call pause

    ret

example_line: db 'YYY',0
