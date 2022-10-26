	BITS 16
start:

	xor bx,bx
	mov bl,dl

	cli
	mov ax, 0x06c0		; set up 4k stack space below the bootloader (0x7c00 - 0x6c00 = 0x1000 = 4096)
	mov ss, ax
	mov sp, 4096		; point stack pointer to top of stack space
	sti

	mov es,[file_system_start]

write_file_sys_to_mem:
	mov bx,0
	mov ax,0x07c0
	mov fs,ax
ifs_loop:
	mov al,[file_system_start_data+bx]
	mov [es:bx],al
	cmp al,0xff
	jz end_ifs_loop
	add bx,1
	jmp ifs_loop
end_ifs_loop:

	call find_file

	cli
	hlt

file_path_buffer dw 0x08a0	; max length 512 bytes

file_system_start dw 0x08c0

file_system_start_data:
	db 0x02			; "2" is the number of subfolders/files (only supports up to 255 for now that means)
	db 0x02			; length of file/folder name, max 255
	db 'C:'			; "C:" is the name of the folder
	db 0x01			; declares it as a folder type
	db 0x06
	db 'system'
	db 0x0000, 0x0000	; segment:offset
	db 0x01
	db 0x04
	db 'user'
	db 0x0000, 0x0000
	db 0x00				; declares a file type
	db 0x12
	db 'testfile.txt'
	db 0x0000, 0x0000 	; where the file/folder declerations continue in memory
	db 0xff

find_file:
	mov es,[file_path_buffer]
	mov si,0
	push 0x0000
.find_len_of_next_sub_path:
	xor bx,bx
.loop_0:
	mov al,[es:si+bx]
	inc bx
	cmp al,0x2f			; "/"
	je .found_end_of_sub_path
	cmp al,0
	je .found_end_of_path
	jmp .loop_0

.found_end_of_sub_path:
	mov cx,bx
	pop bx
	push cx
	sub cx,bx

.cmp_to_files_and_folders:
	mov bx,[file_system_start]
	add bx,1
	add bl,[bx]
	



	add si,cx
	jmp .cmp_to_files_and_folders

.found_sub_folder:

.found_end_of_path:	

.found_file:	


hex_characters db '0123456789abcdef'

; doesnt use cx
print_hex:
	mov ax,bx
	xor dx,dx
	mov bx,0x1000

.hex_print_loop:
	div bx		; divide ax by bx, quotent in ax, remainder in dx
	push bx
	mov bx,hex_characters
	add bx,ax
	mov al,[0x7c00+bx]
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

	mov ax,0x0e20
	int 0x10

	ret

; ------------------------- end ---------------------------------------

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature
	dw 0xffff

	times 510 db 0x22

	dw 0x4444

