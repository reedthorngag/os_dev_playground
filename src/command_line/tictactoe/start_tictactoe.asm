
#include "process_tictactoe_input.asm"

start_tictactoe:

    mov ax,0x0501   ; switch to second page
    int 0x10
    mov byte [print_page],1

    mov bh,[print_page]
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10

    cmp byte [player1_name],0
    je .new_game

.check_continue_game:
    mov si,continue_game_prompt_string
    call print_str
    call wait_for_input
    mov al,[command_buffer]
    cmp al,'y'
    je .continue_game
    cmp al,'Y'
    je .continue_game
    jmp .new_game

.continue_game:
    jmp .reset

.new_game:

.get_names:
    call reset_page

    cmp word [error_string_address],0
    je .no_error_message
    mov si,[error_string_address]
    call print_str
    call endl
    call endl
    mov word [error_string_address],0

.no_error_message:

    xor cx,cx
    xor dx,dx
    mov cl,0x31
.get_name_loop:
    call clear_buffer

    mov si,player_name_prompt.start
    call print_str
    mov ah,0x08     ; length of 'player 1'
    mov al,cl
    sub al,0x26 ; 0x31 - 0x0b (cyan, red is 0x0c)
    call set_color
    mov si,player_name_prompt.middle
    call print_str
    mov ah,0x0e
    mov al,cl
    int 0x10
    mov si,player_name_prompt.end
    call print_str

    mov ah,0x20
    mov al,cl
    sub al,0x26
    call set_color

    push cx
    push dx
    mov word [wait_for_input.max_buffer_len],0x0020
    call wait_for_input     ; doesnt preserve any registers
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
    je .compare_names
    
    add dx,2
    inc cl
    call endl
    jmp .get_name_loop

.compare_names:
    mov si,player1_name
    mov di,player2_name
    xor bx,bx
    mov cl,1

.compare_names_loop:
    mov al,[si]
    mov dl,[di]
    
    cmp al,0
    je .skip_si_inc
    inc si
.skip_si_inc:

    cmp dl,0
    je .skip_di_inc
    inc di
.skip_di_inc:

    inc bl

    mov ch,al
    or ch,dl
    jz .found_end

    cmp al,dl
    je .compare_names_loop
    xor cx,cx
    jmp .compare_names_loop

.found_end:
    cmp cl,1
    jne .not_equal_names
    mov word [error_string_address],same_name_error
    jmp .get_names

.not_equal_names:
    add bl,5
    mov byte [name_padding_len],bl
    jmp .reset_score

.win:
    xor ax,ax
    mov al,[turn]
    shl al,1
    mov si,name_map
    add si,ax

    mov di,[si]
    mov si,win_string
    mov byte [si],0x20
    inc si
    call copy_str

    add si,bx
    mov di,win_string.end
    call copy_str

    mov word [error_string_address],win_string

    jmp .reset

.draw:
    mov word [error_string_address],draw_string
    jmp .reset

.reset_score:
    mov word [player1_score],0
    mov word [player2_score],0

.reset:
    mov di,empty_board
    mov si,board
    call copy_str

    call get_random ; randomize who starts
    and al,1
    mov byte [turn],al


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

    mov bh,[print_page]
    mov ax,0x0500   ; switch back to first page
    int 0x10
    mov byte [print_page],0

    mov si,[error_string_address]
    cmp dx,0    ; set ZF if equal, or unset if not equal
    ret


tictactoe_redraw:
    call reset_page

    mov si,tictactoe_instruction_string
.print_instructions_loop:
    cmp byte [si],0xff
    je .end_print_instructions_loop
    call print_str
    call endl
    jmp .print_instructions_loop

.end_print_instructions_loop:
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
    call tab

    mov si,name_map
    add si,cx
    mov si,[si]
    mov di,si
    call str_len
    mov ax,si
    mov si,di

    shl ax,8
    mov al,cl
    shr al,1
    add al,0x0b
    call set_color

    call print_str

    mov bh,[print_page]
    mov ax,0x0e3a
    int 0x10

    mov al,[name_padding_len]
    call pad_line

    mov si,score_map
    add si,cx
    mov si,[si]
    mov bx,[si]
    call print_decimal

    call endl
    cmp cx,2
    je .printed_score
    mov cx,2
    jmp .print_score_loop

.printed_score:
    pop cx

    call endl

    mov si,turn_string
    call print_str


    ; get length of name
    mov si,name_map
    add si,cx
    mov si,[si]
    mov di,si
    call str_len

    mov ax,si
    shl ax,8    ; mov al into ah
    mov al,cl
    shr al,1
    add al,0x0b
    call set_color

    mov si,di
    call print_str

    mov al,0x20
    int 0x10
    mov al,0x28   ; "("
    int 0x10

    ; color symbol
    mov ah,1
    mov al,cl
    shr al,1
    add al,0x0b
    call set_color

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

    mov si,board
    xor dx,dx
.draw_board_loop:
    call tab
    call draw_tictactoe_line
    call endl
    cmp dl,9
    je .end_loop

    call tab
    mov bh,[print_page]
    mov ax,0x0e2d
    xor cx,cx
.print_spacer_loop:
    int 0x10
    int 0x10
    int 0x10
    inc cx
    cmp cx,3
    je .end_spacer_loop
    mov al,0x2b ; "+"
    int 0x10
    mov al,0x2d ; "-"
    jmp .print_spacer_loop
.end_spacer_loop:
    call endl

    jmp .draw_board_loop

.end_loop:

    call endl

    cmp word [error_string_address],0
    je .print_prompt

    mov al,0x20
    call print_char
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
    mov bh,[print_page]
    mov ah,0x0e
.draw_tictactoe_line_loop:
    mov al,0x20
    int 0x10

    mov al,[si]
    test al,0x40   ; 01_00_00_00b
    jz .no_color

    and al,1
    add al,0x0b
    mov ah,1    ; color 1 character
    call set_color

.no_color:
    mov al,[si]
    int 0x10

    cmp al,0x20
    je .skip_dl_inc
    inc dl

.skip_dl_inc:
    inc si
    inc dh
    cmp dh,3
    je .end

    mov al,0x20
    int 0x10

    mov al,0x7c ; "|"
    int 0x10
    jmp .draw_tictactoe_line_loop

.end:
    ret


tictactoe_instruction_string:
    db ' commands:',0
    db '   exit       quits the game',0
    db '   reset      resets the scores',0
    db '   restart    restarts the game',0
    db 0xff

turn_string: db ' turn: ',0
score_string: db ' scores:',0

tictactoe_prompt_string: db ' enter number to place token at: ',0

continue_game_prompt_string: db 'continue previous game? (y/n): ',0

name_padding_len: db 0

name_map: dw player1_name, player2_name
score_map: dw player1_score, player2_score

symbol_map: db 'X','O'

error_string_address: dw 0

player_name_prompt: 
.start:     db 'enter ',0
.middle:    db 'player ',0
.end:       db ' name: ',0

win_string: 
    times 0x100 db 0
.end: db ' won!!!',0

draw_string: db ' draw!!!',0

same_name_error: db "Players can't have the same name!",0
