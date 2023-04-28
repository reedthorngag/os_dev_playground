
#include "rotate_bottom.asm"
#include "rotate_front.asm"
#include "rotate_left.asm"
#include "rotate_right.asm"
#include "rotate_top.asm"


mov_read_line:
    mov di,line_2
    mov si,line
    call copy_str
    ret

; face in si
; x/y pos of line in al/ah
read_line:
    mov bx,line
    jmp read_line_2.start

read_line_2:
    mov bx,line_2

.start:
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

    cmp dh,1
    je .get_data_loop
    add bx,2
.get_data_loop:
    mov al,[si]
    mov [bx],al

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

    pop si
    pop ax
    ret


write_line:
    push ax
    push si

    cmp di,0
    je .set_si
    mov si,di
    inc si
    jmp .set_face

.set_si:
    mov si,new_face

.set_face:

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
    pop si
    pop ax
    ret


line: times 4 db 0

line_2: times 4 db 0

new_face: times 10 db 0
