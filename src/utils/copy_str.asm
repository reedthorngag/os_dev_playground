; original string in di
; destination address in si
; preserves all registers except bx, which hs the length of the string in it
copy_str:
    push ax
    xor bx,bx
.copy_loop:
    mov al,[di+bx]
    mov byte [si+bx],al
    cmp al,0
    je .end
    inc bx
    jmp .copy_loop

.end:
    pop ax
    ret

