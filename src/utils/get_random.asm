; gets (pesudo) a random number
; returns result in al
; preserves all registers except al
get_random:
    push cx
    push dx
    push ax
    mov ah,0x00
    int 0x1a
    pop ax
    mov al,dl
    pop dx
    pop cx
    ret


