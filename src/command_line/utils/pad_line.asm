; pads current line to al characters, pads with spaces
; OF unset in successful, set if line is already longer than bx, or bx >= screen width
; preserves all registers
pad_line:
    push ax
    push bx
    push dx
    push cx

    cmp al,0x4f
    jge .failed

    xor bx,bx
    mov ah,0x03
    int 0x10

    sub al,dl
    jo .failed
    jz .success

    mov dl,al

    mov ax,0x0e20
.pad_loop:
    int 0x10
    dec dl
    jz .success
    jmp .pad_loop


.failed:
	inc ax	    ; unset OF
	jmp .end

.success:
	xor ax,ax
    dec ax      ; set OF

.end:
    pop cx
    pop dx
    pop bx
    pop ax
    ret