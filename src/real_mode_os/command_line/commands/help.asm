; help command
help:
    mov di,commands_array

.output_loop:
    cmp word [di],0xffff
    je .end

    mov si,[di]
    call print_command

    add di,2
    jmp .output_loop

.end:
    call endl
    xor ax,ax
    ret

print_command:
    call tab

    call print_str  ; print command name

    mov bh,[print_page]
    mov ax,0x0e20
    int 0x10

    add si,2
    call print_str  ; print command parameters


    mov al,0x18     ; pad to 24 characters
    call pad_line
    jno .print_description
    call endl       ; if name + parameters goes over the 32 character limit go to next line and print description there
    call pad_line

.print_description:
    mov word [print_str.max_len],0x002f     ; 0x4f - 0x20
    call print_str
    jno .end

.print_extended_description:
    call endl
    mov al,0x1a     ; pad to 24+2 characters
    call pad_line
    mov word [print_str.max_len],0x002b     ; 0x4f - 0x24
    call print_str
    jo .print_extended_description

.end:
    call endl
    ret




