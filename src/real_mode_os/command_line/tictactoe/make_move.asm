
make_move:
    mov bx,board
    xor ah,ah
    sub al,0x31
    add bx,ax
    mov al,[bx]
    cmp al,'X'
    je .failed
    cmp al,'O'
    je .failed

    xor ax,ax
    mov al,[turn]
    mov si,symbol_map
    add si,ax
    mov al,[si]

    mov byte [bx],al
    jmp .success

.failed:
    cmp al,0    ; unsef ZF as al muct be 'X' or 'O'
    ret

.success:
    xor ax,ax
    ret