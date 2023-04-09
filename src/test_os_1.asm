	BITS 16
start:

	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax	; intialize stack to 0x0000:0x7C00
			    ; (directly below bootloader)
	sti

	;mov es,[file_system_start]

	mov bx, 0xfffa
	call print_hex

	call hang

	jmp .end_ifs_loop

.write_file_sys_to_mem:
	mov bx,0
	mov ax,0x07c0
	mov fs,ax
.ifs_loop:
	mov al,[file_system_start_data+bx]
	mov [es:bx],al
	or al,0x80
	cmp al,0xff
	jz .end_ifs_loop
	inc bx
	jmp .ifs_loop
.end_ifs_loop:

	mov [disk], dl	

	mov ax, 0x0201		; ah = 0x02 (read sector function of int 0x13), al = 1 (read 1 sectors)
						; sector count could theoretically be 255, but 65 is the max that can be read
						; without crossing a segment boundary
						; 65 sectors is roughly 33k of disk space, so make sure you have disk drivers
						; up and running before your kernel binary grows beyond this size, else
						; some data will not be loaded
	mov bx, 0x8000		; es:bx = memory location to copy data into, es already zeroed
	mov cx, 0x0002		; ch = 0x00 (track idx), cl = 0x02 (sector idx to start reading from)
	xor dh, dh		; dh = 0x00 (head idx), dl = drive number (implicitly placed in dl by BIOS on startup)
	int 0x13		; copy data



	mov al,[file_to_find]
	mov ah,0x0e
	;int 10h

	xor bx,bx
	db 0xff
	mov es,[file_path_buffer]
	db 0xff
	mov ah,0x0e
.loop_3:
	mov al,[file_to_find+bx]
	push ax
	push bx
	mov bl,al
	call print_hex
	pop bx
	pop ax
	cmp al,0
	je .end_0
	mov [es:bx],al
	add bx,1
	jmp .loop_3

.end_0:
	mov ah,0x0e
	mov al,[fs:2]
	int 0x10

	call hang

	call find_file

hang:
	cli
	hlt


disk db 0x00

file_to_find db "system/hi",0

file_path_buffer dw 0x07e0	; max length 512 bytes (up to 0x0800)

file_system_start dw 0x0800

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
	jne .loop_0
	jmp .calc_file_folder_name_len	; cos al is already 0, we dont need to change it

.found_end_of_sub_path:
	mov al,1

.calc_file_folder_name_len:
	dec bx
	mov cx,bx
	pop bx
	push cx
	sub cx,bx

.cmp_to_files_and_folders:
	mov fs,[file_system_start]
	mov bx,1
	add bl,[fs:bx]
.loop_1:
	mov dl,[fs:bx]
	cmp dl,al
	je .compare

	inc bx
	xor dx,dx
	mov dl,[fs:bx]
	add bx,dx
	jmp .loop_1

.compare:	; same type determined (file or folder), now compare length, and if the same, compare the characters
	inc bx
	movzx word dx,[fs:bx]
	cmp cx,dx
	jne .loop_1
.loop_2:
	inc bx
	inc si
	mov al,[es:si]
	cmp al,0x2f			; "/"
	je .found_path		; checks if its at the end of the path, and if so, that means they were equal
	cmp ax,[fs:bx]
	jne .loop_1

.found_path:
	mov ax,0x0e61
	int 10h
	; found the path! (in theory)



	jmp .cmp_to_files_and_folders

.found_sub_folder:

.found_file:	


hex_characters db '0123456789abcdef'

; doesnt use cx
; number to print in bx
print_hex:
	mov ax,bx
	xor dx,dx
	mov bx,0x1000

.hex_print_loop:
	div bx		; divide ax by bx, quotent in ax, remainder in dx
	push bx
	mov bx,ax
	mov al,[hex_characters+bx]
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

	mov ax,0x0e61
	int 0x10

	mov ax,0x0e62
	int 0x10

	ret

; ------------------------- end ---------------------------------------

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature

file_system_start_data:
	db 0xf11f		; magic number to indicate fs table
	db 0x02			; "2" is the number of subfolders/files (only supports up to 255 for now that means)
	db 0x02			; length of file/folder name
	db 'C:'			; "C:" is the name of this folder (always first)

	db 0x01			; declares next path as a folder type
	db 0x06			
	db 'system'
	db 0x0000, 0x0000	; segment:offset

	db 0x02				; declares a file type
	db 0x12
	db 'testfile.txt'
	db 0x0000			; offset, max 65535

	db 0xff				; unset lowest bit if this isnt the end of the table (0xfe)
	db 0x0000, 0x0000	; where the file/folder declerations continue in memory

