
start_editor:

    mov ax,0x0501   ; switch to second page
    int 0x10
    mov byte [print_page],1

    mov bh,1
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10

    mov ax,0x0e0a   ; /n
    int 0x10

    mov ah,0x02
    int 0x10

    mov word [cursor_pos],0 ; move buffer cursor to start of buffer
    call update_cursor_offset

.get_input_loop:

    hlt

    mov ah,0x01
    int 0x16
    jz .get_input_loop

    mov ah,0x00
    int 0x16

.process_input:

    cmp ax,0x011b   ; esc
    je .esc

    cmp ax,0x0e08
    je .backspace

    cmp ax,0x5300
    je .del

    cmp ax,0x1c0d
    je .enter

    cmp ax,0x4b00
    je .left_arrow

    cmp ax,0x4d00
    je .right_arrow

    cmp ax,0x4800
    je .up_arrow

    cmp ax,0x5000
    je .down_arrow

.standard_input:

    call insert

    jmp .get_input_loop

.actions:

.backspace:
    call delete
    jmp .get_input_loop

.del:
    call shift_right
    jmp .backspace

.enter:
    call enter
    jmp .get_input_loop

.left_arrow:
    call shift_left
    jmp .get_input_loop

.right_arrow:
    call shift_right
    jmp .get_input_loop

.up_arrow:
    call shift_up
    jmp .get_input_loop

.down_arrow:
    call shift_down
    jmp .get_input_loop

.esc:
    mov bh,1
    call reset_page    

    mov ax,0x0500   ; switch back to fist page
    int 0x10
    mov byte [print_page],0

    ret