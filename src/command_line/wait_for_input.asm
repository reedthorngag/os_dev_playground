; this is blocking
; this preserves NO registers
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

    cmp ax,0x4800
    je .up_arrow

    cmp ax,0x5000
    je .down_arrow

.end_special_input:

    cmp al,0
	je .get_key_loop

    cmp cx,[.max_buffer_len]
    je .get_key_loop

    cmp cx,dx
    jne .shift_buffer

    call print_char

    mov byte [bx],al
    inc bx
    inc cx
    inc dx

    jmp .get_key_loop


.left_arrow:
    cmp cx,0
    jne .continue_left_arrow
    mov si,[.left_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop

.continue_left_arrow:
    cmp dx,0
    je .get_key_loop

    push bx
    push dx
    push cx
    mov bh,[print_page]
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
    cmp cx,0
    jne .continue_right_arrow
    mov si,[.right_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop

.continue_right_arrow:
    cmp dx,cx
    je .get_key_loop

    push bx
    push dx
    push cx
    mov bh,[print_page]
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

.up_arrow:
    cmp cx,0
    jne .continue_up_arrow
    mov si,[.up_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop

.continue_up_arrow:
    jmp .get_key_loop

.down_arrow:
    cmp cx,0
    jne .continue_down_arrow
    mov si,[.down_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop

.continue_down_arrow:
    jmp .get_key_loop


#include "wait_for_input.backspace.asm"
#include "wait_for_input.shift_buffer.asm"

.enter:
    mov word [.max_buffer_len],0x0300
    xor ax,ax	; set ZF
    ret

.reset:
    mov word [.left_arrow_handler],0
    mov word [.right_arrow_handler],0
    mov word [.up_arrow_handler],0
    mov word [.down_arrow_handler],0
    ret

.max_buffer_len: dw 0x0300

.left_arrow_handler dw 0
.right_arrow_handler dw 0
.up_arrow_handler dw 0
.down_arrow_handler dw 0

