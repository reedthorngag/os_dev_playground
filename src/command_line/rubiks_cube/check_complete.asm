
check_complete:
    call print_hex

    mov si,sides
    dec si
    mov dh,7

.side_check:
    dec dh
    cmp dh,0
    je .complete

    inc si
    mov al,[si]
    inc si
    mov dl,9
.compare:
    cmp byte [si],al
    jne .not_complete
    inc si
    dec dl
    cmp dl,0
    je .side_check
    jmp .compare

.complete:
    mov word [error_string_address],complete
    call print_hex
    xor ax,ax
    ret

.not_complete:
    mov word [error_string_address],0
    xor ax,ax
    cmp ax,1
    ret

complete: db ' Rubiks cube completed!!!',0
