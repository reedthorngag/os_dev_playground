
check_for_win:

    xor cx,cx
    mov cl,[turn]
    mov bx,symbol_map
    add bx,cx

    mov byte [.locked],1    ; set locked to true

    xor dx,dx   ; base_mod data
    xor cx,cx   ; mod data in cl
    mov ch,[bx] ; symbol to check for
    xor bx,bx

.base_mod_data_loop:
    xor ax,ax
    mov si,board

    push bx
    xor bh,bh

    mov al,[base_mod+bx]
    cmp al,0xff
    je .no_win
    add si,ax

    inc bx

    mov dx,[base_mod+bx]
    add bx,2

    mov ax,bx
    pop bx
    push ax
    mov ax,bx
    xor bx,bx
    mov bl,ah

    mov cl,[mod+bx]
    inc bx

    pop ax
    mov ah,bl
    mov bx,ax

.base_mod_loop:
    mov di,si
    push dx
    xor dx,dx
    xor ax,ax
    mov al,cl   ; move mod data to ax so can add to di

.mod_loop:
    cmp dh,3
    je .end_mod_loop
    inc dh

    cmp ch,[di]
    je .equal

    cmp byte [di],0x39
    jg .still_locked

    mov byte [.locked],0

.still_locked:
    add di,ax
    jmp .mod_loop

.equal:
    inc dl
    add di,ax
    jmp .mod_loop

.end_mod_loop:
    pop ax
    cmp dl,3
    je .win
    mov dx,ax

    dec dh
    cmp dh,0
    je .end_base_mod_loop

    xor ax,ax
    mov al,dl
    add si,ax

    jmp .base_mod_loop

.end_base_mod_loop:
    jmp .base_mod_data_loop


.win:
    xor ax,ax
    ret

.no_win:
    pop ax
    cmp byte [.locked],1
    je .draw
    xor ax,ax
    cmp ax,1    ; unsef ZF
    ret

.draw:
    pop ax
    pop ax
    jmp start_tictactoe.draw


.locked: db 1

base_mod:
    db 0    ; start modifier
    db 1    ; modifier
    db 3    ; iterations

    db 0
    db 3
    db 3

    db 0
    db 0
    db 1

    db 2
    db 0
    db 1

    db 0xff

mod:
    db 3

    db 1

    db 4

    db 2
