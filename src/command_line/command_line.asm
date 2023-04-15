; this runs the entire command line, and runs forever (will hang on crash/error)
command_line:

.main_loop:

    mov si,prompt_string
    call print_str

    call wait_for_input
    call endl
    jnz .main_loop



    jmp .main_loop


#include "wait_for_input.asm"
#include "input_actions/backspace.asm"
#include "input_actions/endl.asm"

prompt_string: db '> ',0

command_buffer: times 0x300 db 0x00
