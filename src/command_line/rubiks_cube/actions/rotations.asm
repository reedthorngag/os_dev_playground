
#include "rotate_bottom.asm"
#include "rotate_front.asm"
#include "rotate_left.asm"
#include "rotate_right.asm"
#include "rotate_top.asm"

; face in si
; x/y pos of line in al/ah
read_line:
    push ax
    push si

    inc si

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

    mov cx,1

    jmp .get_data

.x_line:
    ;mov dh,1

    dec al
    shl ax,1
    mov cx,3
    add si,ax

.get_data:

    mov bx,line
    cmp dh,1
    je .get_data_loop
    add bx,2
.get_data_loop:
    mov al,[si]
    mov [bx],al

    push bx
    mov bx,si
    shl bx,8
    mov bl,al
    call print_hex
    pop bx

    inc dl
    cmp dl,3
    je .end

    add si,cx

    cmp dh,1
    je .inc

    dec bx
    jmp .get_data_loop

.inc:
    inc bx
    jmp .get_data_loop

.end:

    mov al,0x20
    call print_char
    mov si,line
    call print_str
    mov al,0x20
    call print_char
    pop si
    pop ax
    ret


write_line:
    push ax
    push si

    mov si,new_face

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

    mov cx,1

    jmp .get_data

.x_line:
    mov dh,1

    dec al
    shl ax,1
    mov cx,3
    add si,ax

.get_data:

    mov bx,line
    cmp dh,1
    je .get_data_loop
    add bx,2
.get_data_loop:
    mov al,[bx]
    mov [si],al

    inc dl
    cmp dl,3
    je .end

    add si,cx

    cmp dh,1
    je .inc

    dec bx
    jmp .get_data_loop

.inc:
    inc bx
    jmp .get_data_loop

.end:

    mov si,new_face
    call print_str
    pop si
    pop ax
    ret


line: times 4 db 0

new_face: times 10 db 0
