
start_editor:



.get_input_loop:

    mov ah,0x01
    int 0x16
    jz .get_input_loop

    mov ah,0x00
    int 0x16


.process_input:
    cmp ax,0x011b
    je .end


    jmp .get_input_loop

.end:
    ret