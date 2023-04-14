; returns file segment:offset in es:si
; ZF set on success, unset on failure (invalid path)
create_file:
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
	mov bx,[file_path_buffer_offset]
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
	pop bx	; number of segments file takes up
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