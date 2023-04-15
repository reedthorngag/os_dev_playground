; si should point to command name to test
; ZF set if equal names, unset if unequal
compare_command_name:
    mov bx,command_buffer
    xor cx,cx
.loop:
    mov al,[bx]
    cmp al,0x20
    cmove ax,cx
    cmp al,[si]
    jne .not_equal
    cmp al,0
    je .equal
    inc si
    inc bx
    jmp .loop

.equal:
    inc si      ; so si points at byte after the end
    xor ax,ax   ; set ZF
    ret

.not_equal:
    cmp byte [si],0
    je .return
    inc si
    jmp .not_equal

.return:
    inc si      ; so si points to the byte after the end
    cmp si,1    ; unset ZF as we know si is 0
    ret

