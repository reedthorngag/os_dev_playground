; this runs the entire command line, and runs forever (will hang on crash/error)
command_line:

.main_loop:

    call clear_buffer

    mov si,prompt_string
    call print_str

    call wait_for_input
    jnz .main_loop

    call endl

    mov di,command_array
    sub di,2
.find_command_loop:
    add di,2
    mov si,[di]
    cmp si,0xffff
    je .command_not_found

    call compare_command_name
    jne .find_command_loop

    mov si,[si]
    add si,0x7c00

    call si

    call endl
    jmp .main_loop

.command_not_found:
    mov si,command_not_found
    call print_str
    call endl
    call endl
    jmp .main_loop


#include "wait_for_input.asm"
#include "input_actions/backspace.asm"
#include "input_actions/endl.asm"
#include "compare_command_name.asm"

#include "commands/help.asm"

clear_buffer:
    mov si,command_buffer
.loop:
    cmp byte [si],0
    je .end
    mov byte [si],0
    inc si
    jmp .loop
.end:
    ret


prompt_string: db '> ',0

command_not_found: db 'ERR: command not found!',0

command_buffer: times 0x300 db 0


command_array:
    dw commands.help
    dw 0xffff


commands:

.help:  db 'help',0
        dw help


