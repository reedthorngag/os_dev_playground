
#include "process_tictactoe_input.asm"

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
    mov word [error_string_address],si
    jnz .end_with_error

    call process_tictactoe_input
    mov dx,0
    jnz .end

    jmp .tictactoe_loop


.end_with_error:
    mov dx,1

.end:
    mov bh,1
    call reset_page

    mov ax,0x0500   ; switch back to first page
    int 0x10

    mov si,[error_string_address]
    cmp dx,0    ; set ZF if equal, or unset if not equal
    ret


tictactoe_redraw:
    mov bh,1
    call reset_page

    mov si,instruction_string
    call print_str
    call endl
    call endl

    mov si,board
    xor dx,dx
.draw_board_loop:
    call tab
    call draw_tictactoe_line
    cmp dl,9
    je .end_loop

    call tab
    mov ax,0x0e2d
    int 0x10
    int 0x10
    int 0x10
    int 0x10
    int 0x10
    call endl

    jmp .draw_board_loop

.end_loop:

    call endl

    xor cx,cx

    mov dl,[turn]

    mov dh,2
    cmp cl,1
    cmove cx,dx

    mov si,score_string
    call print_str
    call endl

    push cx
    xor cx,cx
.print_score_loop:
    mov di,name_map
    add di,cx
    mov si, [di]
    call print_str

    mov ax,0x0e3a
    int 0x10
    call tab

    mov di,score_map
    add di,cx
    mov si,[di]
    mov bx,[si]
    call print_decimal
    mov bh,1

    call endl
    cmp cx,2
    je .printed_score
    mov cx,2
    jmp .print_score_loop

.printed_score:
    pop cx

    mov si,turn_string
    call print_str

    mov di,name_map
    add di,cx
    mov si,[di]
    call print_str
    call endl

    cmp word [error_string_address],0
    je .print_prompt

    call endl
    mov si,[error_string_address]
    call print_str
    call endl
    mov word [error_string_address],0

.print_prompt:
    mov si,tictactoe_prompt_string
    call print_str

.end:
    ret


; dl stores which square is next
draw_tictactoe_line:
    xor dh,dh
    mov ah,0x0e
.draw_tictactoe_line_loop:
    mov al,[si]
    int 0x10

    inc si
    inc dl
    inc dh
    cmp dh,3
    je .end

    mov bx,ax
    call print_hex
    mov bh,1

    mov al,0x32 ; "|"
    int 0x10
    jmp .draw_tictactoe_line_loop

.end:
    call endl
    ret

instruction_string: db 'type exit to quit',0

turn_string: db 'turn: ',0
score_string: db 'scores:',0

tictactoe_prompt_string: db 'enter number to place token at: ',0

name_map: dw player1_name, player2_name
score_map: dw player1_score, player2_score

error_string_address: dw 0
