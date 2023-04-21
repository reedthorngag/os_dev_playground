
process_tictactoe_input:
    mov di,tictactoe_commands
.find_command_loop:
    mov si,[di]
    add di,2
    cmp si,0xffff
    je .command_not_found

    call compare_command_name
    jne .find_command_loop

    mov si,[si]
    add si,0x7c00

    call si
    ret
