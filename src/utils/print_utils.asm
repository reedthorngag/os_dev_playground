hex_characters db '0123456789abcdef'

; number to print in bx
; preserves all registers
print_hex:
	push ax
	push bx
	push dx
	mov ax,bx
	mov bx,0x1000
	xor dx,dx	; this is necessery for some reason (div instruction dies without it)

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
	mov ax,0x0e20
	int 0x10		; add a space at the end for nice output

	pop dx
	pop bx
	pop ax
	ret


; prints string in si until a null terminator
; if max_len is set it will end early and set the OF if it hits it
; warning: this could have problems with text without spaces if max_len set
print_str:
	push ax
	push bx
	push cx
	xor bx,bx
	mov cx,[.max_len]
.loop:
	lodsb
	cmp al,0x00
	je .sucess

	mov ah,0x0e
	int 0x10

	inc bx
	cmp bx,cx
	je .overflow

	jmp .loop


.overflow:

.find_last_space_loop:
	call backspace
	dec bx
	cmp bx,0
	je .end
	dec si
	cmp byte [si],0x20
	jne .find_last_space_loop

	mov word [.max_len], 0xffff
	mov al,0x7f		; largest positive integer
	inc al			; set OF
	jmp .end

.sucess:
	mov word [.max_len], 0xffff
	test ax,ax	; unset OF

.end:
	pop cx
	pop bx
	pop ax

	ret


.max_len: dw 0xffff	; if this overflows you have a problem lol

; prints string in es:si until a null terminator
print_es_str:
	push ax
.loop:
	mov al,[es:si]
	inc si
	cmp al,0x00
	je .end
	mov ah,0x0e
	int 0x10
	jmp .loop
.end:
	pop ax
	ret

; number to print in bx
; preserves all registers
print_decimal:
	push ax
	push bx
	push dx
	mov ax,bx
	mov bx,0x2710
	xor dx,dx	; this is necessery for some reason (div instruction dies without it)

.hex_print_loop:
	div bx		; divide ax by bx, quotent in ax, remainder in dx
	push bx
	add al,0x30
	mov ah,0x0e
	int 0x10

	pop ax
	push dx
	xor dx,dx
	mov bx,0x0a
	div bx
	mov bx,ax
	pop ax
	cmp bx,0x00
	jne .hex_print_loop

.end:
	mov ax,0x0e20
	int 0x10		; add a space at the end for nice output

	pop dx
	pop bx
	pop ax
	ret
