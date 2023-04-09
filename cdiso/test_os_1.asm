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


	jmp .skip_for_now
	mov byte [disk], dl
	mov dl,0x80
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

	mov al,0x01
	mov bh,ah
	cmovc bx, ax
	call print_hex
.skip_for_now:

	mov si, file_to_find
	call write_to_file_buffer


	call get_file
	jne .sad

	mov ax,0x0e61	; it worked!
	int 0x10
	jmp .end

.sad:
	mov ax,0x0e62
	int 0x10

.end:

	call hang


write_to_file_buffer:
	xor bx,bx
	mov di,[file_path_buffer_offset]
.loop:
	mov al,[si+bx]
	cmp al,0
	je .end
	mov [di+bx], al
	inc bx
	jmp .loop
.end:
	ret


hang:
	cli	; disable interrupts
	hlt	; halt the processor


; return segment:offset in es:si
; ZF set on success, unset on path not found
get_file:
	mov es,[file_system_start]
	xor si,si
.enter_folder_loop:
	mov ax,[es:si]
	cmp ax,0xf11f
	jne .error
	add si,2
	xor bx,bx
.folder_search_loop:
	mov dl,[es:si]
	inc si
	push bx
	call compare_paths
	pop bx
	jne .next

	inc bx
	cmp dl,1
	je .enter_folder

	cmp dl,2
	jne .error

	mov si,[es:si]
	mov ax,[es:si]
	cmp ax,0x1ff1
	je .found
	jmp .error2

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

.enter_folder:
	inc si
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

.error2
	mov bx,0xff11
	call print_hex

.error:
	mov si,corrupt_file_sys
	call exception


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

disk db 0x00

file_to_find db "testfile.txt",0

file_path_buffer_offset dw 0x0200	; max length 512 bytes (up to 0x0800)

file_system_start dw 0x0800			; segment the file system starts at


corrupt_file_sys: db 'ERR: file system corrupted!',0

compare_paths_exception: db 'ERR: compare paths exception! (malformed path probably)',0

exception:
	lodsb
	cmp al,0
	je .end
	mov ah,0x0e
	int 0x10
	jmp exception
.end:
	call hang

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

	mov ax,0x0e20
	int 0x10
	ret

printstr:
	lodsb
	cmp al,0x00
	je .end
	mov ah,0x0e
	int 0x10
	jmp printstr
.end:
	ret

; ------------------------- end ---------------------------------------

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature

	times 1024-($-$$) db 0

file_system:
	dw 0xf11f			; magic number to indicate fs table

	;db 0x01			; declares next path as a folder type		
	;db 'system',0
	;dw 0x0000			; segment

	db 0x02				; declares a file type
	db 'testfile.txt',0
	dw 0x0200			; offset? maybe do this differently?

	db 0xff				; unset lowest bit if this isnt the end of the table (0xfe)
	dw 0x0000			; segment where the file/folder declerations continue in memory



	times 1536-($-$$) db 0

	dw 0x1ff1			; magic number to indicate a file
	db 'testfile.txt',0	; file name
	dw 0x0800			; segment of parent folder
	dw 0x1000			; size of file

