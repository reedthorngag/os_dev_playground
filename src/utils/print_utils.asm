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