; prints a "tab" (actually just 3 spaces)
; preserves all registers
tab:
    push ax
    mov ax,0x0e20
    int 0x10
    int 0x10
    int 0x10
    pop ax
    ret