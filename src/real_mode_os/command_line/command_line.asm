; this runs the entire command line, and runs forever (will hang on crash/error)
global command_line:

.main_loop:

    call clear_buffer

    mov si,prompt_string
    call print_str

    call wait_for_input

    call endl

    mov di,commands_array
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
    jnz .print_error

    jmp .main_loop


.print_error:
    cmp si,0
    je .main_loop
    
    call print_str
    call endl
    jmp .main_loop

.command_not_found:
    mov si,command_not_found
    call print_str
    call endl
    call endl
    jmp .main_loop


#include "wait_for_input.asm"

#include "utils/utils.asm"

#include "file_editor/file_editor.asm"
#include "tictactoe/tictactoe.asm"
#include "rubiks_cube/rubiks_cube.asm"

#include "commands/clear.asm"
#include "commands/echo.asm"
#include "commands/help.asm"
#include "commands/ls.asm"
#include "commands/tictactoe.asm"
#include "commands/rubiks_cube.asm"

#include "commands/file_editor/edit.asm"
#include "commands/file_editor/pull.asm"
#include "commands/file_editor/push.asm"


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

empty_function:
    xor ax,ax
    ret

prompt_string: db '> ',0

command_not_found: db 'ERR: command not found!',0

command_buffer: times 0x300 db 0


commands_array:
    dw commands.empty_command

    dw commands.clear
    dw commands.cls
    dw commands.echo
    dw commands.edit
    dw commands.help
    dw commands.ls
    dw commands.pull
    dw commands.push
    dw commands.tictactoe
    dw commands.rubiks_cube

    dw 0xffff


commands:

.empty_command:
        db 0
        dw empty_function
        db 0
        db 0

.clear: db 'clear',0
        dw clear
        db 0
        db 'clears the screen',0

.cls:   db 'cls',0
        dw clear
        db 0
        db 'alias for clear',0

.echo:  db 'echo',0
        dw echo
        db 0
        db 'prints everything after "echo " to the screen',0

.edit:  db 'edit',0
        dw edit
        db 0
        db 'opens a simple text editor with the currently pulled file',0

.help:  db 'help',0
        dw help
        db 0
        db 'outputs all commands and their descriptions',0

.ls:    db 'ls',0
        dw ls
        db '[path]',0
        db 'shows files in the folder specified by [path] or current folder if unspecified',0

.pull:  db 'pull',0
        dw pull
        db '[path]',0
        db 'pulls a file, overwriting any previous file that hasnt been pushed',0

.push:  db 'push',0
        dw push
        db 0
        db 'pushes (saves) the current file',0

.tictactoe:
        db 'tictactoe',0
        dw tictactoe
        db 0
        db 'a simple tic tac toe game (definitely not just showing off)',0

.rubiks_cube:
        db 'rubiks_cube',0
        dw rubiks_cube
        db 0
        db 'think you are good enough to solve a rubiks cube?',0

