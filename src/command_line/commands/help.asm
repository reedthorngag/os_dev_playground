; help command
help:
    mov si,lines_to_output
.output_loop:
    cmp byte [si],0xff
    je .end
    call print_str
    call endl
    jmp .output_loop
.end:
    ret


lines_to_output:
    db 'help command used!',0
    db 'test line lol',0
    db 'some random helpful info',0
    db 0
    db 'made by Brody :)',0 
    db 0xff

