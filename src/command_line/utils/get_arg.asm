; put arg to get in bx, 0 is the command itself
; si will point to the arg which is a null terminated string on success
; bx points to null terminator of arg string
; ZF set on success, unset on failure (bx is too big)
get_arg:
    mov si,command_buffer
    dec si

    mov dh,bl
    add dh,3

    xor dl,dl   ; whether this is the command arg to parse

    mov bx,command_arg

.get_to_arg_loop:
    xor cx,cx   ; this is 1 while inside quotes
    mov al,1
    cmp dh,3
    jl .success
    jne .find_next_break
    mov dl,al

.find_next_break:
    inc si
    mov al,[si]

    cmp al,0x20     ; space
    je .potential_break

    cmp al,0
    je .found_end

    cmp al,0x22   ; "
    je .quotes

    jmp .not_a_break


.not_a_break:

    cmp dl,0
    je .find_next_break

    mov byte [bx],al
    inc bx

    jmp .find_next_break


.quotes:
    cmp cx,1
    je .end_quotes

    ; else start quotes
    mov cx,1
    jmp .find_next_break

.end_quotes:
    xor cx,cx
    jmp .find_next_break


.potential_break:
    cmp cx,1
    je .not_a_break

    dec dh
    jmp .get_to_arg_loop


.found_end:
    cmp dh,3
    je .success
    jmp .failed

.failed:
	mov ax,0
	cmp ax,1	; unset ZF
	ret

.success:
    mov byte [bx],0
    mov si,command_arg
	xor ax,ax	; set ZF
	ret

command_arg: times 0x300 db 0