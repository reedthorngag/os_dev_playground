
_console_shift_right:

    mov bh,1
    mov ah,0x03
    int 0x10

    cmp dl,0x4f
    je .shift_down

    mov ah,0x08
    int 0x10
    cmp al,0x0a ; \n
    je .shift_down

    inc dl
    mov bh,1
    mov ah,0x02
    int 0x10

    jmp .end

.shift_down:
    cmp dh,0x18
    jmp .end
    
    call _console_shift_down

    mov bh,1
    mov ah,0x03
    int 0x10
    xor dl,dl
    mov ah,0x02
    int 0x10

.end:
    ret