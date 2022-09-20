	BITS 16
start:

	xor bx,bx
	mov bl,dl

	sti
	mov ax, 0x06c0		; set up 4k stack space below the bootloader (0x7c00 - 0x6c00 = 0x1000 = 4096)
	mov ss, ax
	mov sp, 4096		; point stack pointer to top of stack space
	cli

	xor bx,bx
	mov bl,[0x7c00+disk_address_packet]
	mov bx,ds
	call print_hex

	; -------------------------- file read/write testing stuff ---------------------------------
	
	mov si, 0x0100
	mov word  [si+0], 0x10		; packet size
	mov word  [si+1], 0x00		; always 0
	mov dword [si+2], 0x0001	; num of sectors to transfer
	mov dword [si+4], 0x0010	; transfer buffer, 16 bit offset
	mov dword [si+6], 0x0010	; transfer buffer, 16 bit segment
	mov dword [si+8], 0x0000	; lower 16 bits of starting LBA
	mov dword [si+10],0x0000	; middle 16 bits of starting LBA
	mov dword [si+12],0x0000	; upper 16 bits of starting LBA
	mov dword [si+14],0x0000	; insurance

	mov ax,0x4200
	mov dl,0xe0
	mov bx,disk_address_packet
	add bx,0x7c00
	mov si,bx
	int 0x13		; es:si contain pointer to packet
	
	mov bx,ax
	call print_hex

	mov ax,0x0010
	mov es,ax
	mov si,ax
	mov bx,[es:si+0x100]
	call print_hex

	ret

.error:
	mov bx,error_text
	mov ah,0x0e
.error_loop:
	mov al,[0x7c00+bx]
	cmp al,0
	je .end
	int 0x10
	add bx,1
	jmp .error_loop
.end:
	ret


;	file reading info packet
disk_address_packet:
	db 0x10
	db 0x00
.number_of_sectors:
	db 0x0001
.transfer_buffer_offset:
	db 0x0000
.transfer_buffer_segment:
	db 0x0000
.LBA_address:
	db 0x0000
	db 0x0000
	db 0x0000

;	file writing info packet
result_buffer:
	db 0x001e



error_text db 'error!',0

hex_characters db '0123456789abcdef'

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

	;mov al,0x61
	;mov ah,0x0e
	;int 0x10

	;jmp $
