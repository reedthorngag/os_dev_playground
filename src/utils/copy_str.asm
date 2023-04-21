; original string in di
; destination address in si
; preserves all registers
copy_str:
    push bx
    push ax
    xor bx,bx
.copy_loop:
    mov al,[di+bx]
    cmp al,0
    je .end
    mov byte [si+bx],al
    inc bx
    jmp .copy_loop

.end:
    pop ax
    pop bx
    ret

