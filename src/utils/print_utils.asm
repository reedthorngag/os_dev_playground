hex_characters db '0123456789abcdef'

; number to print in bx
; preserves all registers
print_hex:
	;push ax
	;push bx
	;push dx
	mov ax,bx
	mov bx,0x1000
	xor dx,dx

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

.end:
	mov ax,0x0e70
	int 0x10		; add a space at the end for nice output

	;pop dx
	;pop bx
	;pop ax
	ret

; prints string in ds:si until a null terminator
printstr:
	lodsb
	cmp al,0x00
	je .end
	mov ah,0x0e
	int 0x10
	jmp printstr
.end:
	ret

; prints string in es:si until a null terminator
print_es_str:
	mov al,[es:si]
	inc si
	cmp al,0x00
	je .end
	mov ah,0x0e
	int 0x10
	jmp printstr
.end:
	ret