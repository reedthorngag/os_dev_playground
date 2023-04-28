
#include "start_rubiks_cube.asm"
#include "check_complete.asm"

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
.x db 1
.y db 1


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


get_current:
    push bx
    mov al,[pos.y]
    xor ah,ah
    shl ax,1
    mov si,axis.y
    add si,ax

    mov al,[pos.x]
    xor ah,ah
    shl ax,1
    mov bx,axis.x
    add bx,ax

    cmp byte [pos.x],1
    cmovne si,bx
    mov si,[si]
    mov ax,[pos]
    pop bx
    ret

get_left:
    push dx
    xor ax,ax
    mov al,[pos.x]
    mov ah,1
    dec al
    cmp al,0xff
    jne get_right.skip_wraparound
    jmp get_right.wraparound


get_right:
    push dx
    xor ax,ax
    mov al,[pos.x]
    mov ah,1
    inc al
    cmp al,3
    jne .skip_wraparound

.wraparound:
    mov ah,3
    mov al,1
.skip_wraparound:
    cmp al,1
    je .y_axis

.x_axis:
    mov si,axis.x
    xor ah,ah
    mov dl,al
    xor cx,cx
    jmp .get_side

.y_axis:
    cmp ah,3
    je .do_y_axis
    mov ah,1
.do_y_axis:
    mov si,axis.y
    shr ax,8
    mov dl,al
    mov cx,1

.get_side:
    shl ax,1
    add si,ax
    mov si,[si]


    shr ax,1
    cmp cx,1
    je .y_axis_end

.x_axis_end:
    mov ah,1
    jmp .end

.y_axis_end:
    mov ah,dl
    mov al,1
    
.end:
    pop dx
    ret


handlers:

.left_key:
    call get_left
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop

.right_key:
    call get_right
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop

.up_key:
    call get_top
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop

.down_key:
    call get_bottom
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop


get_color:
    push si
    mov si,color_map
.loop:
    cmp byte [si],al
    je .found
    cmp byte [si],0xff
    je .not_found
    add si,2
    jmp .loop
.found:
    inc si
    mov al,[si]
    pop si
    ret

.not_found:
    mov al,0x07
    pop si
    ret


color_map:
    db 'B'
    db 0x03
    db 'W'
    db 0x0f
    db 'G'
    db 0x02
    db 'Y'
    db 0x0e
    db 'R'
    db 0x04
    db 'O'
    db 0x06
    db 0xff

sides:

.bottom:
    times 10 db 'B'
    db 0

.front:
    times 3 db 'WGW'
    db 'W',0

.top:
    times 10 db 'G'
    db 0

.back:
    times 10 db 'Y'
    db 0

.left:
    times 10 db 'R'
    db 0

.right:
    times 10 db 'O'
    db 0





