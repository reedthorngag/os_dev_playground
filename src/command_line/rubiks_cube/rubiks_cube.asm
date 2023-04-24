
#include "start_rubiks_cube.asm"

axis:

.y:
    dw sides.bottom
    dw sides.front
    dw sides.top
    dw sides.back

.x:
    dw sides.left
    dw 0x0000
    dw sides.right


pos:
.x db 1    ; dw 0x0000
.y db 1    ; sides.front


get_top:
    xor ax,ax
    mov al,[pos.y]
    inc al
    cmp al,4
    jne .skip_wraparound
    xor al,al
.skip_wraparound:
    jmp get_bottom.skip_wraparound


get_bottom:
    xor ax,ax
    mov al,[pos.y]
    dec al
    cmp al,0xff
    jne .skip_wraparound
    mov al,3
.skip_wraparound:
    shl ax,1    ; * 2

    mov si,axis.y
    add si,ax
    mov si,[si]

    shl ax,7
    mov al,[pos.x]
    ret



get_left:
    xor ax,ax
    mov al,[pos.x]
    dec al
    cmp al,0xff
    jne get_right.skip_wraparound
    jmp get_right.wraparound


get_right:
    xor ax,ax
    mov al,[pos.x]
    inc al
    cmp al,3
    jne .skip_wraparound

.wraparound:
    call get_bottom
    mov [pos],ax
    call get_bottom
    mov [pos],ax
    mov ax,1
.skip_wraparound:
    cmp ax,1
    je .y_axis

.x_axis:
    mov si,axis.x
    jmp .get_side

.y_axis:
    mov si,axis.y

.get_side:
    shl ax,1
    add si,ax
    mov si,[si]

    shr ax,1
    mov ah,[pos.y]
    ret


handlers:

.left_key:
    call get_left
    mov word [pos],ax
    ret

.right_key:
    call get_right
    mov word [pos],ax
    ret

.up_key:
    call get_top
    mov word [pos],ax
    ret

.down_key:
    call get_bottom
    mov word [pos],ax
    ret


sides:

.bottom:
    db 0x01
    times 9 db 'B'

.front:
    db 0xff
    times 9 db 'W'

.top:
    db 0x02
    times 9 db 'G'

.back:
    db 0x0E
    times 9 db 'Y'

.left:
    db 0x04
    times 9 db 'R'

.right:
    db 0x06
    times 9 db 'O'





