; original string in di
; destination address in si
; preserves all registers except bx, which hs the length of the string in it
copy_str:
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
    ret

