
rotate_front:

    mov di,sides.back
    inc di
    mov si,new_face
    call copy_str

    call get_current
    mov di,new_face
    add di,4
    mov dl,[si]
    mov [di],dl

    mov ax,0x0001
    call read_line
    mov ax,0x0100
    call write_line
    cmp si,sides.front
    jne .fuck
    call read_line
    mov ax,0x0002
    call write_line
    call read_line
    mov ax,0x0200
    call write_line
    call read_line
    mov ax,0x0001
    call write_line

    inc si
    mov di,new_face
    call copy_str

    call pause

    ret

.fuck:
    mov bx,0xffff
    call print_hex
    call hang

example_line: db 'YYY',0
