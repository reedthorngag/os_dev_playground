    BITS 16
start:

	xor cl,cl
.top:
	in al,0x60
	cmp al,cl
	je .top
	mov cl,al
	xor bx,bx
	mov bl,al
	call print_hex
	jmp .top
