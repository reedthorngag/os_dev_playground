; es:si should point to first byte of path
; bx should be how many folders deep we are
; zero flag set if equal (use je to jump if paths are equal)
; this also increments si to point at byte after null terminator (the file/folder offset)
compare_paths:
	mov cx,bx
	mov bx,[file_path_buffer_offset]
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
	cmp cl,1	; unset ZF as we know cl must be 0
	inc si
	ret
.equal:
	inc si
	xor ax,ax	; set ZF
	ret

.error:
	mov si,compare_paths_exception
	call exception