
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

    xor di,di

    mov ax,0x0001
    call read_line
    mov ax,0x0100
    call write_line
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


    call get_left
    ;mov ax,0x0002
    call calc_horizontal
    call read_line

    call get_top
    mov di,si
    ;mov ax,0x0200
    call calc_vertical
    call read_line_2
    call write_line
    call mov_read_line

    call get_right
    mov di,si
    ;mov ax,0x0001
    call calc_horizontal
    call read_line_2
    call write_line
    call mov_read_line

    call get_bottom
    mov di,si
    ;mov ax,0x0100
    call calc_vertical
    call read_line_2
    call write_line
    call mov_read_line

    call get_left
    mov di,si
    ;mov ax,0x0002
    call calc_horizontal
    call write_line

    ret


calc_vertical:
    push si
    mov cx,ax
    call get_current
    cmp al,1
    jne .alternate

    mov bh,ah
    mov bl,ch

    cmp bx,0x0003
    je .bottom
    cmp bx,0x0300
    je .top

    cmp ah,ch
    jg .bottom

.top:
    mov ax,0x0200
    jmp .end

.bottom:
    mov ax,0x0100
    jmp .end

.alternate:
    cmp al,1
    jl .even

.odd:
    mov ax,0x0002
    jmp .end

.even:
    mov ax,0x0001
    jmp .end

.end:
    pop si
    ret



calc_horizontal:
    push si
    mov cl,al
    call get_current
    cmp al,1
    jne .alternate

    mov al,cl
    inc ah
    mov ch,ah
    test ah,1
    jnz .odd

    shr ax,9
    jmp .end


.alternate:
    cmp al,1
    jl .alternate_even

    mov ax,0x0002
    jmp .end

.alternate_even:
    mov ax,0x0001
    jmp .end
    
.finish_alt:
    cmp al,1
    jle .end
    xor ax,3
    jmp .end

.odd:
    shr ah,1
    jnz .carry_on
    mov ah,2
.carry_on:
    xor al,al

.end:
    test ch,1
    jnz .end2
    cmp cl,1
    jl .invert
    jmp .end2

.invert:
    cmp al,0
    je .ah_xor
    xor al,0x03
    jmp .end2
.ah_xor:
    xor ah,0x03

.end2:
    pop si
    ret

