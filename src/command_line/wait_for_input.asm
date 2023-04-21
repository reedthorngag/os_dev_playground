; this is blocking
; this preserves all registers
; writes data to command_input
; sets ZF if successful on enter key input
; unsets ZF and returns immediately if max command_input (0x512 bytes) reached
wait_for_input:
    mov bx,command_buffer
    xor cx,cx   ; this keeps track of last byte written (bx-cx = command_buffer)
    xor dx,dx   ; this keeps track of relative cursor position

.get_key_loop:
    hlt

    mov ah,0x01
    int 0x16
    jz .get_key_loop

    mov ah,0x00
    int 0x16

.special_input:

    cmp ax,0x0e08
    je .backspace

    cmp ax,0x1c0d
    je .enter

    cmp ax,0x4b00
    je .left_arrow

    cmp ax,0x4d00
    je .right_arrow

.end_special_input:

    cmp al,0
	je .get_key_loop

    cmp cx,0x300
    je .buffer_full_error

    cmp cx,dx
    jne .shift_buffer

    mov ah,0x0e
    int 0x10

    mov byte [bx],al
    inc bx
    inc cx
    inc dx

    jmp .get_key_loop

    

.left_arrow:
    cmp dx,0
    je .get_key_loop

    push bx
    push dx
    push cx
    xor bx,bx
    mov ah,0x03
    int 0x10
    dec dl

    mov ah,0x02
    int 0x10

    pop cx
    pop dx
    pop bx
    dec dx
    jmp .get_key_loop

.right_arrow:
    cmp dx,cx
    je .get_key_loop

    push bx
    push dx
    push cx
    xor bx,bx
    mov ah,0x03
    int 0x10
    inc dl

    mov ah,0x02
    int 0x10

    pop cx
    pop dx
    pop bx
    inc dx
    jmp .get_key_loop


#include "wait_for_input.backspace.asm"
#include "wait_for_input.shift_buffer.asm"

.enter:
    xor ax,ax	; set ZF
	ret

.buffer_full_error:
    call endl
    mov si,buffer_full_error
    mov ax,0
	cmp ax,1	; unset ZF
	ret

buffer_full_error: db 'ERR: buffer full! max input length 0x300 (384) characters',0