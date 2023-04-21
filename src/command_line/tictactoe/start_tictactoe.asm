
#include "process_tictactoe_input.asm"

start_tictactoe:

    mov ax,0x0501   ; switch to second page
    int 0x10
    mov byte [print_page],1

    mov bh,1
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10

    xor cx,cx
    xor dx,dx
    mov cl,0x31
.get_name_loop:
    call clear_buffer

    mov si,player_name_prompt_string1
    call print_str
    mov ah,0x0e
    mov al,cl
    int 0x10
    mov si,player_name_prompt_string2
    call print_str

    push cx
    push dx
    call wait_for_input     ; doesnt preserve any registers
    mov word [error_string_address],si
    jnz .end_with_error
    pop dx
    pop cx

    cmp byte [command_buffer],0
    jne .write_name
    call endl
    jmp .get_name_loop

.write_name:
    mov di,name_map
    add di,dx
    mov si,[di]
    mov di,command_buffer
    call copy_str

    cmp dx,2
    je .reset_point
    
    add dx,2
    inc cl
    call endl
    jmp .get_name_loop


.reset_point:
    mov di,empty_board
    mov si,board
    call copy_str

    call get_random ; randomize who starts
    and al,1
    mov byte [turn],al

    mov word [error_string_address],0
.tictactoe_loop:

    call clear_buffer

    call tictactoe_redraw

    call wait_for_input
    mov word [error_string_address],si
    jnz .end_with_error

    mov word [error_string_address],0

    call process_tictactoe_input
    mov dx,0
    jnz .end

    jmp .tictactoe_loop


.end_with_error:
    mov dx,1

.end:
    call reset_page

    mov bh,1
    mov ax,0x0500   ; switch back to first page
    int 0x10
    mov byte [print_page],0

    mov si,[error_string_address]
    cmp dx,0    ; set ZF if equal, or unset if not equal
    ret


tictactoe_redraw:
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
    mov bh,1
    mov ax,0x0e2d   ; I didnt bother with a loop because too lazy, maybe fix sometime (would only save a few lines tho)
    int 0x10
    mov al,0x2b ; "+"
    int 0x10
    mov al,0x2d ; "-"
    int 0x10
    mov al,0x2b
    int 0x10
    mov al,0x2d
    int 0x10
    call endl

    jmp .draw_board_loop

.end_loop:

    call endl

    xor cx,cx

    mov dh,[turn]

    mov dl,2
    cmp dh,1
    mov dh,0
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

    mov bh,1
    mov ax,0x0e3a
    int 0x10
    call tab

    mov di,score_map
    add di,cx
    mov si,[di]
    mov bx,[si]
    call print_decimal

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

    mov ax,0x0e20
    int 0x10
    mov al,0x28   ; "("
    int 0x10

    mov si,symbol_map
    xor cx,cx
    mov cl,[turn]
    add si,cx
    mov al,[si]
    int 0x10

    mov al,0x29 ; ")"
    int 0x10

    call endl
    call endl

    cmp word [error_string_address],0
    je .print_prompt

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

    mov al,0x7c ; "|"
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

symbol_map: db 'X','O'

error_string_address: dw 0

player_name_prompt_string1: db 'enter player ',0
player_name_prompt_string2: db ' name: ',0
