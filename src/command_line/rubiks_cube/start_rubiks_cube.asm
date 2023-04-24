
#include "process_rubiks_cube_input.asm"

start_rubiks_cube:

    mov ax,0x0501   ; switch to second page
    int 0x10
    mov byte [print_page],1

    mov bh,[print_page]
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10

    mov word [wait_for_input.left_arrow_handler],handlers.left_key
    mov word [wait_for_input.right_arrow_handler],handlers.right_key
    mov word [wait_for_input.up_arrow_handler],handlers.up_key
    mov word [wait_for_input.down_arrow_handler],handlers.down_key

.cube_loop:

    call rubiks_cube_redraw

    call wait_for_input

    call process_rubiks_cube_input

    jmp .cube_loop


.end:
    call wait_for_input.reset
    ret



rubiks_cube_redraw:
    call reset_page

    mov si,rubiks_cube_instruction_string
.print_instructions_loop:
    cmp byte [si],0xff
    je .end_print_instructions_loop
    call print_str
    call endl
    jmp .print_instructions_loop

.end_print_instructions_loop:
    call endl

    ret


instruction_string:
    db ' instructions:',0
    db '   use the exit command to exit the game',0
    db '   use arrow keys to change faces',0
    db '   use standard rubiks cube notation to manipulate the cube',0
    db 0xff


