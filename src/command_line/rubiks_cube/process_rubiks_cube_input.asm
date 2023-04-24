
#include "actions/rotations.asm"

process_rubiks_cube_input:
    mov di,rubiks_cube_commands_array
.find_command_loop:
    mov si,[di]
    add di,2
    cmp si,0xffff
    je .not_a_command

    call compare_command_name
    jne .find_command_loop

    mov si,[si]
    add si,0x7c00   ; because cs is 0x0000, but si is relative to ds

    call si
    jmp .end

.not_a_command:

    mov al,[command_buffer]
    xor ah,ah

    mov cx,ax
    sub cx,0x20

    cmp al,0x59
    cmovg ax,cx


    cmp al,0x42
    je .rotate_bottom

    cmp al,0x57
    je .rotate_front

    cmp al,0x47
    je .rotate_top

    cmp al,0x52
    je .rotate_left

    cmp al,0x4F
    je .rotate_right


    jmp .invalid_input


.invalid_input:
    mov word [error_string_address],rubiks_cube_invalid_input

.end:
    ret


.rotate_bottom:
    mov si,rotate_bottom
    call rotate
    jmp .end

.rotate_front:
    mov si,rotate_front
    call rotate
    jmp .end

.rotate_top:
    mov si,rotate_top
    call rotate
    jmp .end

.rotate_left:
    mov si,rotate_left
    call rotate
    jmp .end

.rotate_right:
    mov si,rotate_right
    call rotate
    jmp .end


rotate:
    mov ax,1
    mov bx,3
    cmp byte [command_buffer+1],"'"
    cmove ax,bx

    add si,0x7c00
.loop:
    call si
    dec ax
    jz .end
    jmp .loop
.end:
    ret


rubiks_cube_exit:
    pop ax
    pop ax
    jmp start_rubiks_cube.end

rubiks_cube_commands_array:

    dw rubiks_cube_commands.exit

    dw 0xffff

rubiks_cube_commands:

.exit:  db 'exit',0
        dw rubiks_cube_exit


rubiks_cube_invalid_input: db 'Invalid input!',0

