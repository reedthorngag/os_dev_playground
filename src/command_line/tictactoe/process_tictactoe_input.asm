
process_tictactoe_input:
    mov di,tictactoe_commands_array
.find_command_loop:
    mov si,[di]
    add di,2
    cmp si,0xffff
    je .not_a_command

    call compare_command_name
    jne .find_command_loop

    mov si,[si]
    add si,0x7c00

    call si
    jmp .end

.not_a_command:
    mov al,[command_buffer+1]
    cmp al,0
    jne .invalid_input

    mov al,[command_buffer]
    sub al,0x30
    cmp al,0x9
    jg .invalid_input
    cmp al,0
    je .invalid_input

    ; process move

.invalid_input:


.end:
    ret


#include "tictactoe_exit.asm"

tictactoe_commands_array:

    dw tictactoe_commands.exit

    dw 0xffff

tictactoe_commands:

.exit:  db 'exit',0
        dw tictactoe_exit


