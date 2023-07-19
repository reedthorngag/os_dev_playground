
#include "process_rubiks_cube_input.asm"

start_rubiks_cube:

    mov ax,0x0501   ; switch to second page
    int 0x10
    mov byte [print_page],1

    mov bh,[print_page]
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10


    call check_complete
    jne .skip_scramble
    mov word [error_string_address],0
    ;call scramble_cube
    jmp .done_scramble_stuff

.skip_scramble:
    mov word [error_string_address],saved_old_state_message_string

.done_scramble_stuff:

    mov word [wait_for_input.left_arrow_handler],handlers.left_key
    mov word [wait_for_input.right_arrow_handler],handlers.right_key
    mov word [wait_for_input.up_arrow_handler],handlers.up_key
    mov word [wait_for_input.down_arrow_handler],handlers.down_key

.cube_loop:

    call clear_buffer

    call check_complete

    call rubiks_cube_redraw

    call wait_for_input

    call process_rubiks_cube_input

    jmp .cube_loop


.end:
    call wait_for_input.reset
    call reset_page

    mov ax,0x0500   ; switch back to first page
    int 0x10
    mov byte [print_page],1

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

    mov al,0x0b
    call pad_line
    call get_top
    call print_side_char
    call endl

    call draw_cube

    call endl
    mov al,0x0b
    call pad_line
    call get_bottom
    call print_side_char
    call endl
    call endl


.print_message_if_any:
    cmp word [error_string_address],0
    je .print_prompt
    mov si,[error_string_address]
    call print_str
    call endl
    mov word [error_string_address],0

.print_prompt:
    mov si,rubiks_cube_prompt_string
    call print_str

    ret

draw_cube:
    call endl
    call get_current
    inc si
    xor dx,dx
.draw_cube_loop:
    cmp dx,3
    jne .normal_padding

    push si
    call tab
    call get_left
    call print_side_char
    mov al,0x20
    call print_char
    call print_char
    pop si

.normal_padding:
    mov al,6
    call pad_line

.done_padding:
    call draw_cube_line

    cmp dx,6
    jne .next_line

    push si
    mov al,0x20
    call print_char
    call print_char
    call get_right
    call print_side_char
    pop si

.next_line:
    call endl
    cmp dx,9
    je .end

    mov al,6
    call pad_line
    mov bh,[print_page]
    mov ax,0x0e2d
    xor cx,cx
.print_spacer_loop:
    int 0x10
    int 0x10
    int 0x10
    inc cx
    cmp cx,3
    je .end_spacer_loop
    mov al,0x2b ; "+"
    int 0x10
    mov al,0x2d ; "-"
    jmp .print_spacer_loop
.end_spacer_loop:
    call endl

    jmp .draw_cube_loop

.end:
    ret


draw_cube_line:
    xor cx,cx
.loop:
    mov al,0x20
    call print_char

    mov al,[si]
    call print_colored_char

    mov al,0x20
    call print_char

    inc cx
    inc dx
    inc si
    cmp cx,3
    je .end

    mov al,'|'
    call print_char

    jmp .loop

.end:
    ret



; char to print in al
; doesnt modify any registers
print_colored_char:
    push ax
    call get_color
    mov ah,1
    call set_color
    pop ax
    call print_char
    ret


print_side_char:
    mov cl,[si]
    mov al,cl
    call get_color
    mov ah,1
    call set_color
    mov al,cl
    call print_char
    ret


rubiks_cube_instruction_string:
    db ' instructions:',0
    db '   type exit to give up (will save the cube if not completed)',0
    db '   use arrow keys to change faces',0
    db '   use standard rubiks cube notation to manipulate the cube',0
    db '   type scramble to scramble the cube',0
    db 0xff

rubiks_cube_win_string: db  ' Rubiks cube is complete! well done!',0

saved_old_state_message_string: db ' Restored previous cube state.',0

rubiks_cube_prompt_string: db ' enter command or move: ',0
