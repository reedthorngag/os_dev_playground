
; string to check len of in si
; returns result in si
; preserves all other registers
str_len:
    push bx
    xor bx,bx

.find_end:
    cmp byte [si],0
    jz .end
    inc bx
    inc si
    jmp .find_end

.end:
    mov si,bx
    pop bx
    ret
