; returns folder segment:offset in es:si
; ZF set on suces, unset on failure (invalid path)
create_folder:
	xor bx,bx
.free_memory_lookup_loop:
	inc bx	; this can be done here because we know at least the first one will exist already
	cmp bx,0x20 	; 0x0800 * 0x20 = 0x10000 (out of bounds)
	je .out_of_space
	mov al,[memory_usage_table+bx]
	cmp al,1
	je .free_memory_lookup_loop
	mov byte [memory_usage_table+bx],0x01
	mov ax,0x0800
	mul bx		; multiply ax by bx, result in dx:ax
	mov cx,ax	; remember not to modify cx!!!

	mov dl,1
	mov dh,1
	mov bx,[file_path_buffer_offset]
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
	mov ax,ds
	mov es,ax
	mov si,file_system_start
	dec si
	jmp .enter_folder

.enter_folder_loop:
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
	xor bx,bx
.folder_search_loop:
	mov al,[es:si]
	inc si
	push bx
	call compare_paths
	pop bx
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

	;mov bx,si
	;call print_hex

	cmp al,1
	je .folder_search_loop
	cmp al,2
	je .folder_search_loop


	cmp al,0xff
	je .failed

	cmp al,0xfe
	jne .error

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

.find_end:
	inc si
	mov al,[es:si]
	cmp al,0xff
	je .write_folder
	cmp al,0xfe
	je .goto_extended
	jmp .find_end

.goto_extended:
	mov es,[es:si]
	jmp .enter_folder_loop

.write_folder:
	mov bx,[file_path_buffer_offset]
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
.loop:
	inc bx
	inc si
	mov	al,[bx]
	cmp al,0
	je .end_loop
	mov byte [es:si],al
	jmp .loop
.end_loop:
	inc si
	mov word [es:si],cx
	add si,2
	mov byte [es:si],0xff
	jmp .created
	mov es,cx
	xor si,si
	mov word [es:si],0xf11f
	add si,2
	mov byte [es:si],0xff

.failed:
	mov ax,0
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