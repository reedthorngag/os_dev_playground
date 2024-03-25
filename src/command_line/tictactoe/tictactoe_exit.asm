
tictactoe_exit:

    mov ax,0x0500   ; switch back to first page
    int 0x10
    mov byte [print_page],0

    mov ax,0
	cmp ax,1	; unset ZF
    ret