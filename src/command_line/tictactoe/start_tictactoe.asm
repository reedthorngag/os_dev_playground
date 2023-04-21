
start_tictactoe:

    mov ax,0x0501   ; switch to second page
    int 0x10

    mov bh,1
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10

.tictactoe_loop:

    call clear_buffer

    call tictactoe_redraw

    call wait_for_input
    jnz .end

    call process_tictactoe_input

    jmp 

.end:
    mov bh,1
    xor dx,dx
    mov cx,0x184f
    mov ax,0x0700   ; cleanup page before exiting by clearing it
    int 0x10

    mov ax,0x0500   ; switch back to first page
    int 0x10

    ret


tictactoe_redraw:
    mov bh,1
    xor dx,dx
    mov cx,0x184f
    mov ax,0x0700   ; wipe page
    int 0x10
    mov ah,0x02     ; move 
    int 0x10


    ret

; dx stores which square is next
draw_tictactoe_line:
    xor bx,bx
    mov ah,0x0e
    mov si,board
.draw_tictactoe_line_loop:
    mov al,[si+bx]
    int 0x10

    inc bx
    inc dx
    cmp bx,3
    je .end

    mov al,0x7c // "|"
    int 0x10

    jmp .draw_tictactoe_line_loop

.end:
    ret
