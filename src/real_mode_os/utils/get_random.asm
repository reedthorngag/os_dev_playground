; gets (pesudo) a random number
; returns result in ax
; preserves all registers except al
get_random:
    push bx
    push cx
    push dx

    mov ax,[state]
    cmp ax,0
    jne .gen_number
    call set_seed

.gen_number:
    mov bx,ax
    mul bx
    shr ax,8
    mov ah,dl
    mov word [state],ax

    pop dx
    pop cx
    pop bx
    ret

set_seed:
    mov ah,0x00
    int 0x1a
    mov ax,dx
    mov word [state],ax
    ret

state: dw 0x0000

