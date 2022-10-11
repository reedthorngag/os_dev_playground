	BITS 16
start:

	xor bx,bx
	mov bl,dl

	cli
	mov ax, 0x06c0		; set up 4k stack space below the bootloader (0x7c00 - 0x6c00 = 0x1000 = 4096)
	mov ss, ax
	mov sp, 4096		; point stack pointer to top of stack space
	sti

initialize_file_system:
	mov bx,0
	mov si,[file_system_start]
ifs_loop:
	mov al,[0x07c0:file_system_start_data+bx]
	cmp al,0xff
	jz end_ifs_loop
	mov [si:bx],al
	add bx,1
	jmp ifs_loop
end_ifs_loop:

	call write_file

	cli
	hlt


file_path_buffer dw 0x8a00

file_system_start dw 0x8c0

file_system_start_data:
	db 0x02
	db 'C:',0,		; "2" is the number of subfolders/files (only supports up to 255 for now that means), "C:" is the name of the folder, "0" is the null termination
	db 0x01
	db '/system',0,
	db 0x01
	db '/user',0,
	db 0x00
	db 'testfile.txt',0
	; db 2,0x[offset] 		where the file/folder declerations continue in memory
	dw 0xffff


write_file:
	
	mov bx,[file_system_start+1]
	mov al,[bx]
	xor bx,bx
	mov bl,al
	call print_hex

	ret



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

