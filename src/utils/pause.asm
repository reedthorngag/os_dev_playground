
; pauses until a key is pressed
; preserves all registers
pause:
    push ax
.wait_for_key_loop:
    hlt

    mov ah,0x01
    int 0x16
    jz .wait_for_key_loop

    pop ax
    ret