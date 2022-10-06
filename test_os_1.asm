	BITS 16
start:

	xor bx,bx
	mov bl,dl

	sti
	mov ax, 0x06c0		; set up 4k stack space below the bootloader (0x7c00 - 0x6c00 = 0x1000 = 4096)
	mov ss, ax
	mov sp, 4096		; point stack pointer to top of stack space
	cli

error_text db 'error!',0

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

