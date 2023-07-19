	BITS 16
start:
	cli
	xor ax, ax
	mov es, ax
	mov ss, ax	; intialize stack to 0x0000:0x7C00
			    ; (directly below bootloader)
	sti
	mov ax, 0x07c0
	mov ds, ax		; this should already be set, but better safe than sorry
	
	call command_line
	; nothing after this should run
	mov si,how_tf
	call exception
; load exception error message into ds:si
exception:
	lodsb
	cmp al,0
	je .end
	mov ah,0x0e
	int 0x10
	jmp exception
.end:
	call hang
hang:
	cli	; disable interrupts
	hlt	; halt the processor

; returns folder segment:offset in es:si
; ZF set on sucess, unset on failure (invalid path)
create_folder:
	xor bx,bx
.free_memory_lookup_loop:
	inc bx			; this can be done here because we know at least the first one will exist already
	cmp bx,0x20 	; 0x0800 * 0x20 = 0x10000 (out of bounds)
	je .out_of_space
	mov al,[memory_usage_table+bx]
	cmp al,1
	je .free_memory_lookup_loop
	mov byte [memory_usage_table+bx],0x01
	mov ax,0x0800
	inc bx
	mul bx		; multiply ax by bx, result in dx:ax
	mov cx,ax	; remember not to modify cx!!!
	mov dl,1
	mov dh,1
	mov bx,file_path_buffer
.get_folder_depth_loop:
	inc bx
	mov al,[bx]
	cmp al,0
	je .main_loop
	cmp al,0x2f
	jne .get_folder_depth_loop
	inc dl
	inc dh
	jmp .get_folder_depth_loop
.main_loop:
	push cx
	xor bx,bx	; bx is used by compare_paths, dont delete!
	mov ax,ds	; these next few lines are so that [es:si] points to the data in file_system_start mem location
	mov es,ax
	mov si,file_system_start
	dec si
	jmp .enter_folder
.enter_folder_loop:
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
	mov al,[es:si]
	cmp al,0xff
	je .failed
	cmp al,0xfe
	je .goto_extended_1
	
.folder_search_loop:
	mov al,[es:si]
	inc si
	call compare_paths
	jne .next
	inc bx
	cmp al,1
	je .enter_folder
	cmp al,2
	je .error_file_name
	jmp .error
.next:
	add si,2
	mov al,[es:si]
	cmp al,1
	je .folder_search_loop
	cmp al,2
	je .folder_search_loop
	cmp al,0xff
	je .failed
	cmp al,0xfe
	jne .error
.goto_extended_1:
	mov es,[es:si]
	jmp .enter_folder_loop
.enter_folder:
	dec dl
	inc si
	mov es,[es:si]
	xor si,si
	cmp dl,0
	je .create_folder_here
	jmp .enter_folder_loop
.create_folder_here:
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
	mov al,[es:si]
	cmp al,0xff
	je .end
	cmp al,0xfe
	je .goto_extended_2
.check_already_exists:
.check_already_exists_loop:
	inc si
	call compare_paths
	je .error_file_name
	add si,2
	mov al,[es:si]
	cmp al,0xff
	je .end
	cmp al,0xfe
	jne .check_already_exists_loop
.goto_extended_2:
	inc si
	mov es,[es:si]
	xor si,si
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
	jmp .check_already_exists_loop
.end:
	pop cx
.write_folder:
	mov bx,file_path_buffer
	cmp dh,1
	je .write_data
.get_to_folder_name:
	inc bx
	mov al,[bx]
	cmp al,0x2f
	jne .get_to_folder_name
	dec dh
	cmp dh,0
	jne .get_to_folder_name
.write_data:
	mov byte [es:si], 0x01
	inc si
.loop:
	mov	al,[bx]
	cmp al,0
	je .end_loop
	mov byte [es:si],al
	inc bx
	inc si
	jmp .loop
.end_loop:
	inc si
	mov word [es:si],cx
	add si,2
	mov byte [es:si],0xff
	mov es,cx
	xor si,si
	mov word [es:si],0xf11f
	add si,2
	mov byte [es:si],0xff
	mov si,0x180
	mov word [es:si],0x0101
	jmp .created
.failed:
	xor ax,ax
	cmp ax,1	; unset ZF
	ret
.created:
	xor ax,ax	; set ZF
	ret
.error2:
	mov ax,0x0e63
	int 0x10
	call hang
.error:
	mov si,corrupt_file_sys
	call exception
.out_of_space:
	mov si,out_of_space_error
	call exception
.error_file_name:
	mov si,file_name_error
	call exception

; returns file segment:offset in es:si
; ZF set on success, unset if path not found
get_file:
	mov es,[file_system_start]
	xor si,si
	xor bx,bx
.enter_folder_loop:
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
.folder_search_loop:
	mov al,[es:si]
	inc si
	call compare_paths
	jne .next	; paths not equal
	; paths are equal
	inc bx
	cmp al,1
	je .enter_folder
	cmp al,2
	jne .error
	mov si,[es:si]
	mov ax,[es:si]
	cmp ax,0x1ff1
	je .found
	jmp .error
.next:
	add si,2
	mov al,[es:si]
	cmp al,1
	je .folder_search_loop
	cmp al,2
	je .folder_search_loop
	cmp al,0xff
	je .not_found
	cmp al,0xfe
	jne .error
	mov es,[es:si]
	jmp .enter_folder_loop
.enter_folder:
	mov es,[es:si]
	xor si,si
	jmp .enter_folder_loop
.not_found:
	mov ax,0
	cmp ax,1	; unset ZF
	ret
.found:
	xor ax,ax	; set ZF
	ret
.error2:
	mov ax,0x0e70
	int 0x10
	call hang
.error:
	mov si,corrupt_file_sys
	call exception
disk: db 0x00
	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature


hex_characters: db '0123456789abcdef'
; number to print in bx
; preserves all registers
print_hex:
	push ax
	push bx
	push dx
	mov ax,bx
	mov bx,0x1000
	xor dx,dx	; this is necessery for some reason (div instruction dies without it)
.hex_print_loop:
	div bx		; divide ax by bx, quotent in ax, remainder in dx
	push bx
	mov bx,ax
	mov al,[hex_characters+bx]
	mov bh,[print_page]
	mov ah,0x0e
	int 0x10
	pop ax
	push dx
	xor dx,dx
	mov bx,0x10
	div bx
	mov bx,ax
	pop ax
	cmp bx,0x00
	jne .hex_print_loop
.end:
	mov bh,[print_page]
	mov ax,0x0e20
	int 0x10		; add a space at the end for nice output
	pop dx
	pop bx
	pop ax
	ret
; prints string in si until a null terminator
; if max_len is set it will end early and set the OF if it hits it
; warning: this could have problems with text without spaces if max_len set
print_str:
	push ax
	push bx
	push cx
	xor bx,bx
	mov cx,[.max_len]
.loop:
	lodsb
	cmp al,0x00
	je .sucess
	push bx
	mov bh,[print_page]
	mov ah,0x0e
	int 0x10
	pop bx
	inc bx
	cmp bx,cx
	je .overflow
	jmp .loop
.overflow:
.find_last_space_loop:
	call backspace
	dec bx
	cmp bx,0
	je .end
	dec si
	cmp byte [si],0x20
	jne .find_last_space_loop
	mov word [.max_len], 0xffff
	mov al,0x7f		; largest positive integer
	inc al			; set OF
	jmp .end
.sucess:
	mov word [.max_len], 0xffff
	test ax,ax	; unset OF
.end:
	pop cx
	pop bx
	pop ax
	ret
.max_len: dw 0xffff	; if this overflows you have a problem lol
; prints string in es:si until a null terminator
print_es_str:
	push ax
	push bx
.loop:
	mov al,[es:si]
	inc si
	cmp al,0x00
	je .end
	mov bh,[print_page]
	mov ah,0x0e
	int 0x10
	jmp .loop
.end:
	pop bx
	pop ax
	ret
; number to print in bx
; preserves all registers
print_decimal:
	push ax
	push bx
	push dx
	push cx
	xor cx,cx
	mov ax,bx
	mov bx,0x2710
	xor dx,dx	; this is necessery for some reason (div instruction dies without it)
.print_loop:
	div bx		; divide ax by bx, quotent in ax, remainder in dx
	push bx
	add al,0x30
	mov ah,0x0e
	; dont print if its a zero and not a placeholder
	pop bx
	push bx
	cmp bx,0x01
	je .print_anyway
	cmp al,0x30
	jne .inc_cx
	cmp cx,0
	je .skip_output
.inc_cx:
	inc cx
.print_anyway:
	mov bh,[print_page]
	int 0x10
.skip_output:
	pop ax	; was bx
	push dx
	xor dx,dx
	mov bx,0x0a
	div bx
	mov bx,ax
	pop ax	; was dx (remainder from main div)
	cmp bx,0x00
	jne .print_loop
.end:
	mov bh,[print_page]
	mov ax,0x0e20
	int 0x10		; add a space at the end for nice output
	pop cx
	pop dx
	pop bx
	pop ax
	ret
; prints character in al
; preserves all registers
print_char:
	push ax
    push bx
    mov bh,[print_page]
    mov ah,0x0e
    int 0x10
    pop bx
    pop ax
	ret
; color in al
; number of characters to apply it to in ah
; preserves all registers except ah, which it sets to 0x0e
set_color:
	push ax
	push bx
	push cx
	xor cx,cx
	mov cl,ah
	mov bl,al
	mov bh,[print_page]
	mov ax,0x0900
	int 0x10
	pop cx
	pop bx
	pop ax
	mov ah,0x0e	; being helpful, as most likely you are printing something after this, and ah is now useless
	ret
print_page: db 0


; gets (pesudo) a random number
; returns result in ax
; preserves all registers except al
get_random:
    push bx
    push cx
    push dx
    mov ax,[state]
    cmp ax,0
    jne .gen_number
    call set_seed
.gen_number:
    mov bx,ax
    mul bx
    shr ax,8
    mov ah,dl
    mov word [state],ax
    pop dx
    pop cx
    pop bx
    ret
set_seed:
    mov ah,0x00
    int 0x1a
    mov ax,dx
    mov word [state],ax
    ret
state: dw 0x0000


; original string in di
; destination address in si
; preserves all registers except bx, which hs the length of the string in it
copy_str:
    push ax
    xor bx,bx
.copy_loop:
    mov al,[di+bx]
    mov byte [si+bx],al
    cmp al,0
    je .end
    inc bx
    jmp .copy_loop
.end:
    pop ax
    ret


; pauses until a key is pressed
; preserves all registers
pause:
    push ax
.wait_for_key_loop:
    hlt
    mov ah,0x01
    int 0x16
    jz .wait_for_key_loop
    pop ax
    ret

; string to check len of in si
; returns result in si
; preserves all other registers
str_len:
    push bx
    xor bx,bx
.find_end:
    cmp byte [si],0
    jz .end
    inc bx
    inc si
    jmp .find_end
.end:
    mov si,bx
    pop bx
    ret

; offset in si, preserves si
write_to_file_path_buffer:
	xor bx,bx
	mov di,file_path_buffer
.loop:
	mov al,[si+bx]
	cmp al,0
	je .clear_path
	mov byte [di+bx], al
	inc bx
	jmp .loop
.clear_path:
	mov al,[di+bx]
	cmp al,0
	je .end
	mov byte [di+bx],0
	inc bx
	cmp bx,0x200
	je .end
	jmp .clear_path
.end:
	ret


; this runs the entire command line, and runs forever (will hang on crash/error)
command_line:
.main_loop:
    call clear_buffer
    mov si,prompt_string
    call print_str
    call wait_for_input
    call endl
    mov di,commands_array
.find_command_loop:
    mov si,[di]
    add di,2
    cmp si,0xffff
    je .command_not_found
    call compare_command_name
    jne .find_command_loop
    mov si,[si]
    add si,0x7c00
    call si
    jnz .print_error
    jmp .main_loop
.print_error:
    cmp si,0
    je .main_loop
    
    call print_str
    call endl
    jmp .main_loop
.command_not_found:
    mov si,command_not_found
    call print_str
    call endl
    call endl
    jmp .main_loop

; this is blocking
; this preserves NO registers
; writes data to command_input
; sets ZF if successful on enter key input
; unsets ZF and returns immediately if max command_input (0x512 bytes) reached
wait_for_input:
    mov bx,command_buffer
    xor cx,cx   ; this keeps track of last byte written (bx-cx = command_buffer)
    xor dx,dx   ; this keeps track of relative cursor position
.get_key_loop:
    hlt
    mov ah,0x01
    int 0x16
    jz .get_key_loop
    mov ah,0x00
    int 0x16
.special_input:
    cmp ax,0x0e08
    je .backspace
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
.end_special_input:
    cmp al,0
	je .get_key_loop
    cmp cx,[.max_buffer_len]
    je .get_key_loop
    cmp cx,dx
    jne .shift_buffer
    call print_char
    mov byte [bx],al
    inc bx
    inc cx
    inc dx
    jmp .get_key_loop
.left_arrow:
    cmp cx,0
    jne .continue_left_arrow
    mov si,[.left_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop
.continue_left_arrow:
    cmp dx,0
    je .get_key_loop
    push bx
    push dx
    push cx
    mov bh,[print_page]
    mov ah,0x03
    int 0x10
    dec dl
    mov ah,0x02
    int 0x10
    pop cx
    pop dx
    pop bx
    dec dx
    jmp .get_key_loop
.right_arrow:
    cmp cx,0
    jne .continue_right_arrow
    mov si,[.right_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop
.continue_right_arrow:
    cmp dx,cx
    je .get_key_loop
    push bx
    push dx
    push cx
    mov bh,[print_page]
    mov ah,0x03
    int 0x10
    inc dl
    mov ah,0x02
    int 0x10
    pop cx
    pop dx
    pop bx
    inc dx
    jmp .get_key_loop
.up_arrow:
    cmp cx,0
    jne .continue_up_arrow
    mov si,[.up_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop
.continue_up_arrow:
    jmp .get_key_loop
.down_arrow:
    cmp cx,0
    jne .continue_down_arrow
    mov si,[.down_arrow_handler]
    cmp si,0
    je .get_key_loop
    add si,0x7c00
    call si
    jmp .get_key_loop
.continue_down_arrow:
    jmp .get_key_loop

.backspace:
    cmp dx,0
    je .get_key_loop
    dec cx
    dec dx
    dec bx
    push dx
    mov bx,command_buffer
    add bx,dx
    call backspace
.overwrite_loop:
    cmp dx,cx
    je .end_overwrite_loop
    inc bx
    mov al,[bx]
    dec bx
    mov byte [bx],al
    call print_char
    inc bx
    inc dx
    jmp .overwrite_loop
    
.end_overwrite_loop:
    mov byte [bx],0
    mov al,0x20
    call print_char
    call backspace
    pop dx
    push bx
    push cx
    push dx
    mov ax,cx
    sub ax,dx
    mov bh,[print_page]
    mov ah,0x03
    int 0x10
    sub dl,al
    mov bh,[print_page]
    mov ah,0x02
    int 0x10
    pop dx
    pop cx
    pop bx
.done_overwrite:
    jmp .get_key_loop

.shift_buffer:
    push ax
    push bx
    push cx
    push dx
    mov bx,command_buffer
    add bx,dx
.shift_loop:
    mov ah,[bx]
    mov byte [bx],al
    inc bx
    inc dx
    call print_char
    shr ax,8    ; mov al,ah
    cmp dx,cx
    je .end
    jmp .shift_loop
.end:
    call print_char
    mov byte [bx],al
    inc bx
    mov byte [bx],0
    pop bx
    mov ax,cx
    sub ax,bx   ; get the difference between the cursor and the end
    ;dec ax      ; add one because we are moving one place towards the end
    push bx
    mov bh,[print_page]
    mov ah,0x03
    int 0x10
    sub dl,al
    mov ah,0x02
    int 0x10
    pop dx
    pop cx
    pop bx
    pop ax
    inc bx
    inc cx
    inc dx
    jmp .get_key_loop

.enter:
    mov word [.max_buffer_len],0x0300
    xor ax,ax	; set ZF
    ret
.reset:
    mov word [.left_arrow_handler],0
    mov word [.right_arrow_handler],0
    mov word [.up_arrow_handler],0
    mov word [.down_arrow_handler],0
    ret
.max_buffer_len: dw 0x0300
.left_arrow_handler dw 0
.right_arrow_handler dw 0
.up_arrow_handler dw 0
.down_arrow_handler dw 0



; si should point to command name to test
; ZF set if equal names, unset if unequal
compare_command_name:
    mov bx,command_buffer
    xor cx,cx
.loop:
    mov al,[bx]
    cmp al,0x20
    cmove ax,cx
    cmp byte [si],al
    jne .not_equal
    cmp al,0
    je .equal
    inc si
    inc bx
    jmp .loop
.equal:
    inc si      ; so si points at byte after the end
    xor ax,ax   ; set ZF
    ret
.not_equal:
    cmp byte [si],0
    je .return
    inc si
    jmp .not_equal
.return:
    inc si      ; so si points to the byte after the end
    cmp si,1    ; unset ZF as we know si is 0
    ret


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

; moves cursor back one place and over writes with space
; if bx is 1, it assumes it is page 2
; preserves all registers
backspace:
    push ax
    push bx
    push cx
    push dx
    
    mov bh,[print_page]
    mov ah,0x03
    int 0x10
    cmp dl,0
    je .end
    dec dl
    mov bh,[print_page]
    mov ah,0x02
    int 0x10
    mov bh,[print_page]
    mov ax,0x0e20
    int 0x10
    mov bh,[print_page]
    mov ah,0x02
    int 0x10
.end:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ends the current line and goes to the next line
; if bh is 1, it assumes it is page 2
endl:
    push ax
    push cx
    push dx
    push bx
    mov bh,[print_page]
    mov ah,0x03
    int 0x10
    cmp dh,0x17
    je .scroll_down
    inc dh
    xor dl,dl
    mov bh,[print_page]
    mov ah,0x02
    int 0x10
    jmp .end
.scroll_down:
    xor cx,cx
    mov dx,0x184f   ; row 24, col 79
    mov bh,0x07     ; white on black character attribute
    mov ax,0x0601   ; scroll 1 line
    int 0x10
    mov bh,[print_page]
    mov dx,0x1700
    mov ah,0x02
    int 0x10
.end:
    pop bx
    pop dx
    pop cx
    pop ax
    ret


; prints a "tab" (actually just 3 spaces)
; preserves all registers
tab:
    push ax
    mov bh,[print_page]
    mov ax,0x0e20
    int 0x10
    int 0x10
    int 0x10
    pop ax
    ret

; pads current line to al characters, pads with spaces
; OF unset in successful, set if line is already longer than bx, or bx >= screen width
; preserves all registers
pad_line:
    push ax
    push bx
    push dx
    push cx
    cmp al,0x4f
    jge .failed
    mov bh,[print_page]
    mov ah,0x03
    int 0x10
    sub al,dl
    jo .failed
    jz .success
    mov dl,al
    
    mov ax,0x0e20
.pad_loop:
    int 0x10
    dec dl
    jz .success
    jmp .pad_loop
.failed:
	inc ax	    ; unset OF
	jmp .end
.success:
	xor ax,ax
    dec ax      ; set OF
.end:
    pop cx
    pop dx
    pop bx
    pop ax
    ret
; wipes page and moves cursor to start
reset_page:
    mov bh,[print_page]
    xor cx,cx
    mov bh,0x07     ; white on black
    mov dx,0x184f
    mov ax,0x0700   ; wipe page
    int 0x10
    mov bh,[print_page]
    xor dx,dx
    mov ah,0x02     ; move cursor to start
    int 0x10
    ret


; \n is 0x0a

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



; max len in bl, 0xff if uncapped
_buffer_goto_line_end:
    xor cx,cx
    mov cl,bl
    mov ax,cursor_pos.y
    mov bx,line_width
    mul bx
    mov bx,file_data
    add bx,ax
.loop:
    inc ch
    cmp ch,cl
    je .end
    cmp byte [bx],0x0a ; \n
    je .end
    inc bx
    jmp .loop
.end:
    mov byte [cursor_pos.x],ch
    ret


_buffer_shift_left:
    mov al,[cursor_pos.x]
    cmp al,0
    je .shift_up
    dec byte [cursor_pos.x]
    jmp .end
.shift_up:
    call _buffer_shift_up
    call _buffer_goto_line_end
.end:
    ret


_buffer_shift_right:
    ret

_buffer_shift_up:
    ret

_buffer_shift_down:
    mov bl,[cursor_pos.x]
    dec byte [cursor_pos.y]
    ret
update_cursor_offset:
    xor ax,ax
    mov al,[cursor_pos.y]
    mov bx,0x0080
    mul bx
    xor bx,bx
    mov bl,[cursor_pos.x]
    add ax,bx
    mov word [cursor_offset],ax
    ret
update_cursor_pos:
    ret
cursor_pos: 
    .x: db 0x00 
    .y: db 0x00 ; column, row, if read into register, x is in al, y in ah
num_lines: db 0x18
line_width: db 0x4f
cursor_offset: dw 0x0000    ; cursor_pos.y * 0x80 + cursor_pos.x



; set bl to max line position, or 0xff if no max
_console_goto_line_end:
    mov ax,0x4f
    cmp bl,0xff
    cmove bx,ax
    mov bh,1
    mov ah,0x03
    int 0x10
    xor dl,dl
.find_end_loop:
    cmp dl,bl
    je .end
    mov ah,0x08
    int 0x10
    cmp al,0x0a ; \n
    je .end
    inc dl
    mov ah,0x02
    int 0x10
    jmp .find_end_loop
.end:
    ret

_console_shift_left:
    mov bh,1
    mov ah,0x03
    int 0x10
    cmp dl,0
    je .shift_up
    dec dl
    mov ah,0x02
    int 0x10
    jmp .end
.shift_up:
    cmp dh,0
    je .end
    call _console_shift_up
    mov bl,0xff
    call _console_goto_line_end
.end:
    ret

_console_shift_right:
    mov bh,1
    mov ah,0x03
    int 0x10
    cmp dl,0x4f
    je .shift_down
    mov ah,0x08
    int 0x10
    cmp al,0x0a ; \n
    je .shift_down
    inc dl
    mov bh,1
    mov ah,0x02
    int 0x10
    jmp .end
.shift_down:
    cmp dh,0x18
    jmp .end
    
    call _console_shift_down
    mov bh,1
    mov ah,0x03
    int 0x10
    xor dl,dl
    mov ah,0x02
    int 0x10
.end:
    ret

_console_shift_up:
    mov bh,1
    mov ah,0x03
    int 0x10
    cmp dh,0
    je .end
    dec dh
    mov ah,0x02
    int 0x10
    mov bl,dl
    call _console_goto_line_end
.end:
    ret

_console_shift_down:
    mov bh,1
    mov ah,0x03
    int 0x10
    cmp dh,0x18
    je .end
    inc dh
    mov ah,0x02
    int 0x10
    mov bl,dl
    call _console_goto_line_end
.end:
    ret


shift_left:
    call _buffer_shift_left
    jnz .end
    call _console_shift_left
.end:
    ret


shift_right:
    call _buffer_shift_right
    jnz .end
    call _console_shift_right
.end:
    ret


shift_up:
    call _buffer_shift_up
    jnz .end
    call _console_shift_up
.end:
    ret


shift_down:
    call _buffer_shift_down
    jnz .end
    call _console_shift_down
.end:
    ret




_buffer_insert:
    ret

_console_insert:
    ret
; inserts whatever is in al into the buffer and console at respective cursor positions and increments positions
insert:
    push ax
    call _buffer_insert
    pop ax
    call _console_insert
    call shift_right
    ret


_buffer_delete:
    ret

_console_delete:
    ret
; aka backspace
delete:
    call _buffer_delete
    call _console_delete
    ret


_buffer_enter:
    ret

_console_enter:
    ret
enter:
    call _buffer_enter
    call _console_enter
    ret

folder_segment: dw 0
file_offset: dw 0
file_path:  times 0x300 db 0
file_data:  times 0x18*0x4f db 0
first_showen_line: db 0x0





make_move:
    mov bx,board
    xor ah,ah
    sub al,0x31
    add bx,ax
    mov al,[bx]
    cmp al,'X'
    je .failed
    cmp al,'O'
    je .failed
    xor ax,ax
    mov al,[turn]
    mov si,symbol_map
    add si,ax
    mov al,[si]
    mov byte [bx],al
    jmp .success
.failed:
    cmp al,0    ; unsef ZF as al muct be 'X' or 'O'
    ret
.success:
    xor ax,ax
    ret

check_for_win:
    xor cx,cx
    mov cl,[turn]
    mov bx,symbol_map
    add bx,cx
    mov byte [.locked],1    ; set locked to true
    xor dx,dx   ; base_mod data
    xor cx,cx   ; mod data in cl
    mov ch,[bx] ; symbol to check for
    xor bx,bx
.base_mod_data_loop:
    xor ax,ax
    mov si,board
    push bx
    xor bh,bh
    mov al,[base_mod+bx]
    cmp al,0xff
    je .no_win
    add si,ax
    inc bx
    mov dx,[base_mod+bx]
    add bx,2
    mov ax,bx
    pop bx
    push ax
    mov ax,bx
    xor bx,bx
    mov bl,ah
    mov cl,[mod+bx]
    inc bx
    pop ax
    mov ah,bl
    mov bx,ax
.base_mod_loop:
    mov di,si
    push dx
    xor dx,dx
    xor ax,ax
    mov al,cl   ; move mod data to ax so can add to di
.mod_loop:
    cmp dh,3
    je .end_mod_loop
    inc dh
    cmp ch,[di]
    je .equal
    cmp byte [di],0x39
    jg .still_locked
    mov byte [.locked],0
.still_locked:
    add di,ax
    jmp .mod_loop
.equal:
    inc dl
    add di,ax
    jmp .mod_loop
.end_mod_loop:
    pop ax
    cmp dl,3
    je .win
    mov dx,ax
    dec dh
    cmp dh,0
    je .end_base_mod_loop
    xor ax,ax
    mov al,dl
    add si,ax
    jmp .base_mod_loop
.end_base_mod_loop:
    jmp .base_mod_data_loop
.win:
    xor ax,ax
    ret
.no_win:
    pop ax
    cmp byte [.locked],1
    je .draw
    xor ax,ax
    cmp ax,1    ; unsef ZF
    ret
.draw:
    pop ax
    pop ax
    jmp start_tictactoe.draw
.locked: db 1
base_mod:
    db 0    ; start modifier
    db 1    ; modifier
    db 3    ; iterations
    db 0
    db 3
    db 3
    db 0
    db 0
    db 1
    db 2
    db 0
    db 1
    db 0xff
mod:
    db 3
    db 1
    db 4
    db 2

process_tictactoe_input:
    mov di,tictactoe_commands_array
.find_command_loop:
    mov si,[di]
    add di,2
    cmp si,0xffff
    je .not_a_command
    call compare_command_name
    jne .find_command_loop
    mov si,[si]
    add si,0x7c00   ; because cs is 0x0000, but si is relative to ds
    call si
    jmp .end
.not_a_command:
    mov al,[command_buffer+1]
    cmp al,0
    jne .invalid_input
    mov al,[command_buffer]
    cmp al,0x39
    jg .invalid_input
    cmp al,0x31
    jl .invalid_input
    call make_move
    jnz .invalid_move
    call check_for_win
    jnz .no_win
    xor ax,ax
    mov al,[turn]
    mov bl,al
    add al,bl
    mov si,score_map
    add si,ax
    mov di,[si]
    inc word [di]
    pop ax
    jmp start_tictactoe.win
.no_win:
    not byte [turn]
    and byte [turn],1
    xor ax,ax
    jmp .end
.invalid_input:
    xor ax,ax
    mov word [error_string_address],tictactoe_invalid_input
    ret
.invalid_move:
    xor ax,ax
    mov word [error_string_address],tictactoe_invalid_move
.end:
    ret

tictactoe_exit:
    mov ax,0
	cmp ax,1	; unset ZF
    ret

tictactoe_reset:
    pop ax
    jmp start_tictactoe.reset_score


tictactoe_restart:
    pop ax
    jmp start_tictactoe.new_game
tictactoe_empty_input:
    xor ax,ax
    ret
tictactoe_commands_array:
    dw tictactoe_commands.empty_input
    dw tictactoe_commands.exit
    dw tictactoe_commands.reset
    dw tictactoe_commands.restart
    dw 0xffff
tictactoe_commands:
.empty_input:
            db 0
            dw tictactoe_empty_input
.exit:      db 'exit',0
            dw tictactoe_exit
.reset:     db 'reset',0
            dw tictactoe_reset
.restart:   db 'restart',0
            dw tictactoe_restart
tictactoe_invalid_input: db 'Invalid input!',0
tictactoe_invalid_move: db 'Invalid move!',0

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

player1_name: times 0x20 db 0
player2_name: times 0x20 db 0
player1_score: dw 0
player2_score: dw 0
board: 
    times 0x1b db 0
empty_board: 
    db 0x31, 0x32, 0x33
    db 0x34, 0x35, 0x36
    db 0x37, 0x38, 0x39
    db 0
turn: db 0






rotate_bottom:
    push word [pos]
    call get_bottom
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret

rotate_front:
    mov di,sides.back
    inc di
    mov si,new_face
    call copy_str
    call get_current
    mov di,new_face
    add di,4
    mov dl,[si]
    mov [di],dl
    xor di,di
    mov ax,0x0001
    call read_line
    mov ax,0x0100
    call write_line
    call read_line
    mov ax,0x0002
    call write_line
    call read_line
    mov ax,0x0200
    call write_line
    call read_line
    mov ax,0x0001
    call write_line
    inc si
    mov di,new_face
    call copy_str
    call get_left
    ;mov ax,0x0002
    call calc_horizontal
    call read_line
    call get_top
    mov di,si
    ;mov ax,0x0200
    call calc_vertical
    call read_line_2
    call write_line
    call mov_read_line
    call get_right
    mov di,si
    ;mov ax,0x0001
    call calc_horizontal
    call read_line_2
    call write_line
    call mov_read_line
    call get_bottom
    mov di,si
    ;mov ax,0x0100
    call calc_vertical
    call read_line_2
    call write_line
    call mov_read_line
    call get_left
    mov di,si
    ;mov ax,0x0002
    call calc_horizontal
    call write_line
    ret
calc_vertical:
    push si
    mov cx,ax
    call get_current
    cmp al,1
    jne .alternate
    mov bh,ah
    mov bl,ch
    cmp bx,0x0003
    je .bottom
    cmp bx,0x0300
    je .top
    cmp ah,ch
    jg .bottom
.top:
    mov ax,0x0200
    jmp .end
.bottom:
    mov ax,0x0100
    jmp .end
.alternate:
    cmp al,1
    jl .even
.odd:
    mov ax,0x0002
    jmp .end
.even:
    mov ax,0x0001
    jmp .end
.end:
    pop si
    ret
calc_horizontal:
    push si
    mov cl,al
    call get_current
    cmp al,1
    jne .alternate
    mov al,cl
    inc ah
    mov ch,ah
    test ah,1
    jnz .odd
    shr ax,9
    jmp .end
.alternate:
    cmp al,1
    jl .alternate_even
    mov ax,0x0002
    jmp .end
.alternate_even:
    mov ax,0x0001
    jmp .end
    
.finish_alt:
    cmp al,1
    jle .end
    xor ax,3
    jmp .end
.odd:
    shr ah,1
    jnz .carry_on
    mov ah,2
.carry_on:
    xor al,al
.end:
    test ch,1
    jnz .end2
    cmp cl,1
    jl .invert
    jmp .end2
.invert:
    cmp al,0
    je .ah_xor
    xor al,0x03
    jmp .end2
.ah_xor:
    xor ah,0x03
.end2:
    pop si
    ret


rotate_left:
    push word [pos]
    call get_left
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret


rotate_right:
    push word [pos]
    call get_right
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret

rotate_top:
    push word [pos]
    call get_top
    mov word [pos],ax
    call rotate_front
    pop word [pos]
    ret
mov_read_line:
    mov di,line_2
    mov si,line
    call copy_str
    ret
; face in si
; x/y pos of line in al/ah
read_line:
    mov bx,line
    jmp read_line_2.start
read_line_2:
    mov bx,line_2
.start:
    push ax
    push si
    inc si
    xor dx,dx
    cmp ah,0
    je .x_line
    mov dh,1
    dec ah
    shr ax,5
    mov cx,ax
    shr cx,2
    sub ax,cx
    add si,ax
    mov cx,1
    jmp .get_data
.x_line:
    ;mov dh,1
    dec al
    shl ax,1
    mov cx,3
    add si,ax
.get_data:
    cmp dh,1
    je .get_data_loop
    add bx,2
.get_data_loop:
    mov al,[si]
    mov [bx],al
    inc dl
    cmp dl,3
    je .end
    add si,cx
    cmp dh,1
    je .inc
    dec bx
    jmp .get_data_loop
.inc:
    inc bx
    jmp .get_data_loop
.end:
    pop si
    pop ax
    ret
write_line:
    push ax
    push si
    cmp di,0
    je .set_si
    mov si,di
    inc si
    jmp .set_face
.set_si:
    mov si,new_face
.set_face:
    xor dx,dx
    cmp ah,0
    je .x_line
    mov dh,1
    dec ah
    shr ax,5
    mov cx,ax
    shr cx,2
    sub ax,cx
    add si,ax
    mov cx,1
    jmp .get_data
.x_line:
    mov dh,1
    dec al
    shl ax,1
    mov cx,3
    add si,ax
.get_data:
    mov bx,line
    cmp dh,1
    je .get_data_loop
    add bx,2
.get_data_loop:
    mov al,[bx]
    mov [si],al
    inc dl
    cmp dl,3
    je .end
    add si,cx
    cmp dh,1
    je .inc
    dec bx
    jmp .get_data_loop
.inc:
    inc bx
    jmp .get_data_loop
.end:
    pop si
    pop ax
    ret
line: times 4 db 0
line_2: times 4 db 0
new_face: times 10 db 0

process_rubiks_cube_input:
    mov di,rubiks_cube_commands_array
.find_command_loop:
    mov si,[di]
    add di,2
    cmp si,0xffff
    je .not_a_command
    call compare_command_name
    jne .find_command_loop
    mov si,[si]
    add si,0x7c00   ; because cs is 0x0000, but si is relative to ds
    call si
    jmp .end
.not_a_command:
    mov al,[command_buffer]
    xor ah,ah
    mov cx,ax
    sub cx,0x20
    cmp al,0x59
    cmovg ax,cx
    cmp al,'B'
    je .rotate_bottom
    cmp al,'F'
    je .rotate_front
    cmp al,'T'
    je .rotate_top
    cmp al,'L'
    je .rotate_left
    cmp al,'R'
    je .rotate_right
    jmp .invalid_input
.invalid_input:
    mov word [error_string_address],rubiks_cube_invalid_input
.end:
    ret
.rotate_bottom:
    mov si,rotate_bottom
    call rotate
    jmp .end
.rotate_front:
    mov si,rotate_front
    call rotate
    call print_hex
    jmp .end
.rotate_top:
    mov si,rotate_top
    call rotate
    jmp .end
.rotate_left:
    mov si,rotate_left
    call rotate
    jmp .end
.rotate_right:
    mov si,rotate_right
    call rotate
    jmp .end
rotate:
    mov cx,1
    mov bx,3
    cmp byte [command_buffer+1],"'"
    cmove cx,bx
    add si,0x7c00
.loop:
    push si
    push cx
    call si
    pop cx
    pop si
    dec cx
    jz .end
    jmp .loop
.end:
    ret

scramble_cube:
    mov cx,0x0200
    jmp .gen
.loop:
    dec cx
    jz .end
.gen:
    call get_random
    shr ax,12   ; 4 bits of data, 16 values
    cmp ax,8
    jg .gen
    push ax
    shl ax,1
    mov bx,move_func_map
    add bx,ax
    mov si,[bx]
    add si,0x7c00
    push cx
    call si
    pop cx
    pop dx
    test dx,1   ; rotations are even numbered, and dont require further actions
    jne .loop
    mov word [pos],ax
    jmp .loop
.end:
    mov word [pos],0x0101
    ret
move_func_map:
    dw rotate_bottom
    dw get_top
    dw rotate_front
    dw get_left
    dw rotate_left
    dw get_right
    dw rotate_right
    dw get_bottom
    dw rotate_top

rubiks_cube_exit:
    pop ax
    pop ax
    jmp start_rubiks_cube.end
rubiks_cube_commands_array:
    dw rubiks_cube_commands.exit
    dw 0xffff
rubiks_cube_commands:
.exit:  db 'exit',0
        dw rubiks_cube_exit
.scramble:
        db 'scramble',0
        dw scramble_cube
rubiks_cube_invalid_input: db 'Invalid input!',0

start_rubiks_cube:
    mov ax,0x0501   ; switch to second page
    int 0x10
    mov byte [print_page],1
    mov bh,[print_page]
    xor dx,dx
    mov ah,0x02     ; move cursor to start of page/file
    int 0x10
    call check_complete
    jne .skip_scramble
    mov word [error_string_address],0
    ;call scramble_cube
    jmp .done_scramble_stuff
.skip_scramble:
    mov word [error_string_address],saved_old_state_message_string
.done_scramble_stuff:
    mov word [wait_for_input.left_arrow_handler],handlers.left_key
    mov word [wait_for_input.right_arrow_handler],handlers.right_key
    mov word [wait_for_input.up_arrow_handler],handlers.up_key
    mov word [wait_for_input.down_arrow_handler],handlers.down_key
.cube_loop:
    call clear_buffer
    call check_complete
    call rubiks_cube_redraw
    call wait_for_input
    call process_rubiks_cube_input
    jmp .cube_loop
.end:
    call wait_for_input.reset
    call reset_page
    mov ax,0x0500   ; switch back to first page
    int 0x10
    mov byte [print_page],1
    ret
rubiks_cube_redraw:
    call reset_page
    mov si,rubiks_cube_instruction_string
.print_instructions_loop:
    cmp byte [si],0xff
    je .end_print_instructions_loop
    call print_str
    call endl
    jmp .print_instructions_loop
.end_print_instructions_loop:
    call endl
    mov al,0x0b
    call pad_line
    call get_top
    call print_side_char
    call endl
    call draw_cube
    call endl
    mov al,0x0b
    call pad_line
    call get_bottom
    call print_side_char
    call endl
    call endl
.print_message_if_any:
    cmp word [error_string_address],0
    je .print_prompt
    mov si,[error_string_address]
    call print_str
    call endl
    mov word [error_string_address],0
.print_prompt:
    mov si,rubiks_cube_prompt_string
    call print_str
    ret
draw_cube:
    call endl
    call get_current
    inc si
    xor dx,dx
.draw_cube_loop:
    cmp dx,3
    jne .normal_padding
    push si
    call tab
    call get_left
    call print_side_char
    mov al,0x20
    call print_char
    call print_char
    pop si
.normal_padding:
    mov al,6
    call pad_line
.done_padding:
    call draw_cube_line
    cmp dx,6
    jne .next_line
    push si
    mov al,0x20
    call print_char
    call print_char
    call get_right
    call print_side_char
    pop si
.next_line:
    call endl
    cmp dx,9
    je .end
    mov al,6
    call pad_line
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
    jmp .draw_cube_loop
.end:
    ret
draw_cube_line:
    xor cx,cx
.loop:
    mov al,0x20
    call print_char
    mov al,[si]
    call print_colored_char
    mov al,0x20
    call print_char
    inc cx
    inc dx
    inc si
    cmp cx,3
    je .end
    mov al,'|'
    call print_char
    jmp .loop
.end:
    ret
; char to print in al
; doesnt modify any registers
print_colored_char:
    push ax
    call get_color
    mov ah,1
    call set_color
    pop ax
    call print_char
    ret
print_side_char:
    mov cl,[si]
    mov al,cl
    call get_color
    mov ah,1
    call set_color
    mov al,cl
    call print_char
    ret
rubiks_cube_instruction_string:
    db ' instructions:',0
    db '   type exit to give up (will save the cube if not completed)',0
    db '   use arrow keys to change faces',0
    db '   use standard rubiks cube notation to manipulate the cube',0
    db '   type scramble to scramble the cube',0
    db 0xff
rubiks_cube_win_string: db  ' Rubiks cube is complete! well done!',0
saved_old_state_message_string: db ' Restored previous cube state.',0
rubiks_cube_prompt_string: db ' enter command or move: ',0


check_complete:
    call print_hex
    mov si,sides
    dec si
    mov dh,7
.side_check:
    dec dh
    cmp dh,0
    je .complete
    inc si
    mov al,[si]
    inc si
    mov dl,9
.compare:
    cmp byte [si],al
    jne .not_complete
    inc si
    dec dl
    cmp dl,0
    je .side_check
    jmp .compare
.complete:
    mov word [error_string_address],complete
    call print_hex
    xor ax,ax
    ret
.not_complete:
    mov word [error_string_address],0
    xor ax,ax
    cmp ax,1
    ret
complete: db ' Rubiks cube completed!!!',0

axis:
.y:
    dw sides.bottom
    dw sides.front
    dw sides.top
    dw sides.back
.x:
    dw sides.left
    dw 0x0000
    dw sides.right
pos:
.x db 1
.y db 1
get_top:
    xor ax,ax
    mov al,[pos.y]
    inc al
    cmp al,4
    jne .skip_wraparound
    xor al,al
.skip_wraparound:
    jmp get_bottom.skip_wraparound
get_bottom:
    xor ax,ax
    mov al,[pos.y]
    dec al
    cmp al,0xff
    jne .skip_wraparound
    mov al,3
.skip_wraparound:
    shl ax,1    ; * 2
    mov si,axis.y
    add si,ax
    mov si,[si]
    shl ax,7
    mov al,1
    ret
get_current:
    push bx
    mov al,[pos.y]
    xor ah,ah
    shl ax,1
    mov si,axis.y
    add si,ax
    mov al,[pos.x]
    xor ah,ah
    shl ax,1
    mov bx,axis.x
    add bx,ax
    cmp byte [pos.x],1
    cmovne si,bx
    mov si,[si]
    mov ax,[pos]
    pop bx
    ret
get_left:
    push dx
    xor ax,ax
    mov al,[pos.x]
    mov ah,1
    dec al
    cmp al,0xff
    jne get_right.skip_wraparound
    jmp get_right.wraparound
get_right:
    push dx
    xor ax,ax
    mov al,[pos.x]
    mov ah,1
    inc al
    cmp al,3
    jne .skip_wraparound
.wraparound:
    mov ah,3
    mov al,1
.skip_wraparound:
    cmp al,1
    je .y_axis
.x_axis:
    mov si,axis.x
    xor ah,ah
    mov dl,al
    xor cx,cx
    jmp .get_side
.y_axis:
    cmp ah,3
    je .do_y_axis
    mov ah,1
.do_y_axis:
    mov si,axis.y
    shr ax,8
    mov dl,al
    mov cx,1
.get_side:
    shl ax,1
    add si,ax
    mov si,[si]
    shr ax,1
    cmp cx,1
    je .y_axis_end
.x_axis_end:
    mov ah,1
    jmp .end
.y_axis_end:
    mov ah,dl
    mov al,1
    
.end:
    pop dx
    ret
handlers:
.left_key:
    call get_left
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop
.right_key:
    call get_right
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop
.up_key:
    call get_top
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop
.down_key:
    call get_bottom
    mov word [pos],ax
    pop ax
    pop ax
    jmp start_rubiks_cube.cube_loop
get_color:
    push si
    mov si,color_map
.loop:
    cmp byte [si],al
    je .found
    cmp byte [si],0xff
    je .not_found
    add si,2
    jmp .loop
.found:
    inc si
    mov al,[si]
    pop si
    ret
.not_found:
    mov al,0x07
    pop si
    ret
color_map:
    db 'B'
    db 0x03
    db 'W'
    db 0x0f
    db 'G'
    db 0x02
    db 'Y'
    db 0x0e
    db 'R'
    db 0x04
    db 'O'
    db 0x06
    db 0xff
sides:
.bottom:
    times 10 db 'B'
    db 0
.front:
    times 10 db 'W'
    db 0
.top:
    times 10 db 'G'
    db 0
.back:
    times 10 db 'Y'
    db 0
.left:
    times 10 db 'R'
    db 0
.right:
    times 10 db 'O'
    db 0


; clears screen
clear:
    xor bx,bx
    call reset_page
    xor ax,ax
    ret
    


; echo command
echo:
    mov bx,0
    call get_arg
    sub bx,si
    mov si,command_buffer
    add si,bx
    inc si
    call print_str
    call endl
    xor ax,ax
    ret


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


; ls command
ls:
    mov bx,3
    call get_arg
    jne .failed
    call print_str
    jmp .end
.failed:
    mov si,ls_failed
    call print_str
.end:
    call endl
    xor ax,ax
    ret
ls_failed: db 'ls command failed!',0


tictactoe:
    mov word [error_string_address],0
    call start_tictactoe
    ret


rubiks_cube:
    call start_rubiks_cube
    ret

; opens a simple text editor with the current file open
edit:
    call start_editor
    xor ax,ax
    ret

; "pulls" a file, ready to be edited
; file path should be in arg 1
pull:
    xor ax,ax
    ret

; pushes (saves) the current file
push:
    xor ax,ax
    ret
clear_buffer:
    mov si,command_buffer
.loop:
    cmp byte [si],0
    je .end
    mov byte [si],0
    inc si
    jmp .loop
.end:
    ret
empty_function:
    xor ax,ax
    ret
prompt_string: db '> ',0
command_not_found: db 'ERR: command not found!',0
command_buffer: times 0x300 db 0
commands_array:
    dw commands.empty_command
    dw commands.clear
    dw commands.cls
    dw commands.echo
    dw commands.edit
    dw commands.help
    dw commands.ls
    dw commands.pull
    dw commands.push
    dw commands.tictactoe
    dw commands.rubiks_cube
    dw 0xffff
commands:
.empty_command:
        db 0
        dw empty_function
        db 0
        db 0
.clear: db 'clear',0
        dw clear
        db 0
        db 'clears the screen',0
.cls:   db 'cls',0
        dw clear
        db 0
        db 'alias for clear',0
.echo:  db 'echo',0
        dw echo
        db 0
        db 'prints everything after "echo " to the screen',0
.edit:  db 'edit',0
        dw edit
        db 0
        db 'opens a simple text editor with the currently pulled file',0
.help:  db 'help',0
        dw help
        db 0
        db 'outputs all commands and their descriptions',0
.ls:    db 'ls',0
        dw ls
        db '[path]',0
        db 'shows files in the folder specified by [path] or current folder if unspecified',0
.pull:  db 'pull',0
        dw pull
        db '[path]',0
        db 'pulls a file, overwriting any previous file that hasnt been pushed',0
.push:  db 'push',0
        dw push
        db 0
        db 'pushes (saves) the current file',0
.tictactoe:
        db 'tictactoe',0
        dw tictactoe
        db 0
        db 'a simple tic tac toe game (definitely not just showing off)',0
.rubiks_cube:
        db 'rubiks_cube',0
        dw rubiks_cube
        db 0
        db 'think you are good enough to solve a rubiks cube?',0


; returns file segment:offset in es:si
; ZF set on success, unset on failure (invalid path)
create_file:
	mov dl,1
	mov dh,1
	mov bx,file_path_buffer
.get_folder_depth_loop:
	inc bx
	mov al,[bx]
	cmp al,0
	je .main_loop
	cmp al,0x2f
	jne .get_folder_depth_loop
	inc dl
	inc dh
	jmp .get_folder_depth_loop
.main_loop:
	xor bx,bx	; bx is used by compare_paths, dont delete!
    push ax     ; random data, will be replaced with folder segment when enter_folder_loop starts
	mov ax,ds	; these next few lines are so that [es:si] points to the data in file_system_start mem location
	mov es,ax
	mov si,file_system_start
	jmp .enter_folder
.enter_folder_loop:
    pop ax          ; get rid of last folder segment
    push es         ; push current folder segment to stack
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
	mov al,[es:si]
	cmp al,0xff
	je .end
	cmp al,0xfe
	je .goto_extended_1
.folder_search_loop:
	mov al,[es:si]
	inc si
	call compare_paths
	jne .next
	inc bx
	cmp al,1
	je .enter_folder
	cmp al,2
	je .error_file_name
	jmp .error
.next:
	add si,2
	mov al,[es:si]
	cmp al,1
	je .folder_search_loop
	cmp al,2
	je .folder_search_loop
	cmp al,0xff
	je .failed
	cmp al,0xfe
	jne .error
.goto_extended_1:
	mov es,[es:si]
	jmp .enter_folder_loop
.enter_folder:
	dec dl
	mov es,[es:si]
	xor si,si
	cmp dl,0
	je .create_file_here
	jmp .enter_folder_loop
.create_file_here:
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
    add si,2
	
	mov al,[es:si]
	cmp al,0xff
	je .end
	cmp al,0xfe
	je .goto_extended
.check_already_exists:
.check_already_exists_loop:
	inc si
	call compare_paths
	je .error_file_name
	add si,2
	mov al,[es:si]
	cmp al,0xff
	je .end
	cmp al,0xfe
	jne .check_already_exists_loop
.goto_extended:
	inc si
	mov es,[es:si]
	xor si,si
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
	jmp .check_already_exists_loop
.end:
.find_free_space:
    mov ax,es
    add ax,0x18
    mov es,ax
    xor bx,bx
.find_free_space_loop:
    inc bx
    cmp bx,0x20
    je .out_of_space
    mov al,[es:bx]
    cmp al,1
    je .find_free_space_loop
    push bx
	push dx
    mov ax,0x0100
    mul bx
    mov cx,ax
	pop dx
	mov ax,es
	sub ax,0x18
	mov es,ax
.write_folder_data:
	mov bx,file_path_buffer
	cmp dh,1
	je .write_data
.get_to_file_name_loop:
	inc bx
	mov al,[bx]
	cmp al,0x2f
	jne .get_to_file_name_loop
	dec dh
	cmp dh,1
	jne .get_to_file_name_loop
.write_data:
	mov byte [es:si], 0x02	; indicates a file
	push bx
.write_file_name_to_folder_loop:
	inc bx
	inc si
	mov	al,[bx]
	mov byte [es:si],al
	cmp al,0
	jne .write_file_name_to_folder_loop
.continue_1:
	inc si
	mov word [es:si],cx
	add si,2
	mov byte [es:si],0xff
	
	mov si,cx		; move file offset into si
	mov word [es:si],0x1ff1
	inc si
	pop bx
.write_file_name_to_file_loop:
    inc bx
    inc si
    mov al,[bx]
    mov byte [es:si],al
    cmp al,0
    jne .write_file_name_to_file_loop
.continue_2:
    inc si
	pop bx	; number of 0x100 byte segments file takes up
    pop ax	; parent folder segment
    mov word [es:si],ax
    add si,2
    mov byte [es:si],bl
    inc si
    mov byte [es:si],0xff
	mov si,cx			; so [es:si] points to the start of the file
	jmp .created
.failed:
	xor ax,ax
	cmp ax,1	; unset ZF
	ret
.created:
	xor ax,ax	; set ZF
	ret
.error:
	mov si,corrupt_file_sys
	call exception
.out_of_space:
	mov si,out_of_space_error
	call exception
.error_file_name:
	mov si,file_name_error
	call exception


; es:si should point to first byte of path
; bx should be how many folders deep we are
; zero flag set if equal (use je to jump if paths are equal)
; this also increments si to point at byte after null terminator (the file/folder offset)
; also this preserves ax, bx and dx
compare_paths:
	push bx
	push ax
	mov cx,bx
	mov bx,file_path_buffer
.init_loop:
	cmp cx,0
	je .done_init
.find_slash_loop:
	mov al,[bx]
	cmp al,0x2f
	je .found_slash
	cmp al,0
	je .error
	inc bx
	jmp .find_slash_loop
.found_slash:
	inc bx
	dec cx
	jmp .init_loop
.done_init:
.loop:
	mov al,[bx]
	xor cx,cx
	cmp al,0x2f
	cmove ax,cx
	mov cl,[es:si]
	;push bx
	;mov bh,al
	;mov bl,cl
	;call print_hex
	;pop bx
	cmp al,cl
	jne .not_equal
	cmp al,0
	je .equal
	inc bx
	inc si
	jmp .loop
.not_equal:
	cmp cl,0
	je .end_not_equal_loop
	inc si
	mov cl,[es:si]
	jmp .not_equal
.end_not_equal_loop:
	inc si
	cmp cl,1	; unset ZF as we know cl must be 0
	pop ax
	pop bx
	ret
.equal:
	inc si
	xor ax,ax	; set ZF
	pop ax
	pop bx
	ret
.error:
	mov si,compare_paths_exception
	call exception

file_system_start: dw 0x1000		; segment the file system starts at
compare_paths_exception: db 'ERR: compare paths exception! (malformed path probably)',0
corrupt_file_sys: db 'ERR: file system corrupted!',0
file_name_error: db 'ERR: a file or folder with that name already exists!',0
out_of_space_error: db 'ERR: out of memory pages!',0
how_tf: db 'ERR: how tf u manage this?',0
file_path_buffer: times 0x200 db 0x00
memory_usage_table:
	db 0x01					; first bit set if segment taken, calculate segment by offset from start of table * 0x0800
	db 0x01
	times 0x8000+0x400-($-$$) db 0
file_system:
	dw 0xf11f			; magic number to indicate fs table
	;db 0x01			; declares next path as a folder type		
	;db 'system',0
	;dw 0x0000			; segment
	db 0x02				; declares a file type
	db 'testfile.txt',0
	dw 0x0200			; file offset from folder in 0x100 byte chunks (max 0x7f00 as 0x8000 is the next folder)
	db 0xff				; unset lowest bit if this isnt the end of the table (0xfe)
	dw 0x0000			; segment where the file/folder declerations continue in memory
	times 0x8180+0x400-($-$$) db 0
	db 0x01
	db 0x01
	db 0x01
	times 0x8200+0x400-($-$$) db 0
	dw 0x1ff1			; magic number to indicate a file
	db 'testfile.txt',0	; file name (obviously)
	dw 0x1000			; segment of parent folder
	dw 0x01				; number of 0x100 byte chunks file takes up
	db 0xff				; if the file is extended or not, 0xfe if it is
	dw 0x0000			; parent folder file offset of where it continues if it does
