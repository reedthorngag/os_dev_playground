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