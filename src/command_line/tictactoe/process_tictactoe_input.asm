
#include "make_move.asm"
#include "check_for_win.asm"

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
    add si,0x7c00   ; because cs is 0x0000, but si is relative to ds

    call si
    jmp .end

.not_a_command:
    mov al,[command_buffer+1]
    cmp al,0
    jne .invalid_input

    mov al,[command_buffer]
    cmp al,0x39
    jg .invalid_input
    cmp al,0x31
    jl .invalid_input

    call make_move
    jnz .invalid_move

    call check_for_win
    jnz .no_win


    xor ax,ax
    mov al,[turn]
    mov bl,al
    add al,bl
    mov si,score_map
    add si,ax
    mov di,[si]
    inc word [di]
    pop ax
    jmp start_tictactoe.win

.no_win:
    not byte [turn]
    and byte [turn],1

    xor ax,ax
    jmp .end

.invalid_input:
    xor ax,ax
    mov word [error_string_address],tictactoe_invalid_input
    ret

.invalid_move:
    xor ax,ax
    mov word [error_string_address],tictactoe_invalid_move

.end:
    ret


#include "tictactoe_exit.asm"


tictactoe_empty_input:
    xor ax,ax
    ret

tictactoe_commands_array:

    dw tictactoe_commands.empty_input
    dw tictactoe_commands.exit

    dw 0xffff

tictactoe_commands:

.empty_input:
        db 0
        dw tictactoe_empty_input

.exit:  db 'exit',0
        dw tictactoe_exit


tictactoe_invalid_input: db 'Invalid input!',0

tictactoe_invalid_move: db 'Invalid move!',0

