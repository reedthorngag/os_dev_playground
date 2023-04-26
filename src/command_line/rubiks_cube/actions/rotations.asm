
#include "rotate_bottom.asm"
#include "rotate_front.asm"
#include "rotate_left.asm"
#include "rotate_right.asm"
#include "rotate_top.asm"

; face in si
; x/y pos of line in al/ah
read_write_line:
    push si

    mov di,line
    mov si,old_line
    call copy_str
    pop si
    push si
    inc si

    mov di,new_face

    xor dx,dx

    cmp ah,0
    je .x_line

    mov dh,1

    dec ah
    shr ax,5
    mov cx,ax
    shr cx,2
    sub ax,cx
    add si,ax
    add di,ax

    mov cx,1

    jmp .get_data

.x_line:
    dec al
    shl ax,1
    mov cx,3
    add si,ax
    add di,ax

.get_data:
    push si
    mov al,0x20
    call print_char
    mov si,old_line
    ;call print_str
    pop si

    mov bx,line
    cmp dh,1
    je .get_data_loop
    add bx,2
.get_data_loop:
    mov al,[si]
    mov [bx],al
    mov al,[bx+4]
    mov [di],al

    inc dl
    cmp dl,3
    je .end

    add si,cx
    add di,ax

    cmp dh,1
    jne .dec

    inc bx
    jmp .get_data_loop

.dec:
    dec bx
    jmp .get_data_loop

.end:
    pop si
    push si
    inc si
    mov di,new_face
    call copy_str

    mov al,0x20
    call print_char
    mov si,line
    call print_str
    pop si
    ret

line: times 4 db 0
old_line: times 4 db 0

new_face: times 10 db 0
