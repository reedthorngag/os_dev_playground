	BITS 16

start:
	mov ax, 0x06c0		; set up 4k stack space below the bootloader (0x7c00 - 0x6c00 = 0x1000 = 4096)
	mov ss, ax
	mov sp, 4096		; point stack pointer to top of stack space

	xor edx,edx
	mov edx, 0x100000

.main_loop:
	xor eax,eax
	mov ah, 01h
	int 16h
	jz .main_loop

	mov ah,00h
	int 16h

	xor ebx,ebx
	add bx,dx
	add bx,cx
	mov [bx],al
	add cx,0x02

	cmp al,0x0D
	jne .main_loop

	xor ecx,ecx

.print_all_loop:

	xor ebx,ebx
	add bx,dx
	add bx,cx
	mov al,[bx]
	cmp al,0x0D
	je .reset
	mov ah,0x0e
	int 10h
	add cx,02h
	jmp .print_all_loop

;text_string db 'hello!', 0

print_all:
	xor eax,eax
	mov ah,0eh
.print_all_loop_02:
	int 10h
	inc al
	cmp al,0xff
	jne .print_all_loop_02
	xor eax,eax

print_decimal:

	xor eax,eax
	xor edx,edx
	mov al,bl

	xor ebx,ebx
	
	mov bl,64h		; set divisor to 100
	div ebx			; divide eax by ebx, quotent in eax, remainder in edx
	add al,30h
	mov ah,0eh
	int 10h

	xor eax,eax
	mov al,dl
	xor edx,edx
	mov bl,0ah		; set divisor to 10
	div ebx			; divide eax by ebx, quotent in eax, remainder in edx
	add al,30h
	mov ah,0eh
	int 10h

	mov al,dl
	add al,30h
	mov ah,0eh
	int 10h

	ret

print_bl:
	mov al,bl
	mov ah,0eh
	int 10h
	xor bl,bl
	ret


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
	cmp bx,0
	jne .hex_print_loop

	ret

print_decimal:

	xor ax,ax
	mov al,bl
	xor bx,bx
	xor cx,cx
	xor dx,dx


	mov bl,64h		; set divisor to 100
	div bx			; divide ax by bx, quotent in ax, remainder in dx
	add al,30h
	mov ah,0eh
	int 10h

	xor ax,ax
	mov al,dl
	xor dx,dx
	mov bl,0ah		; set divisor to 10
	div bx			; divide eax by ebx, quotent in eax, remainder in edx
	add al,30h
	mov ah,0eh
	int 10h

	mov al,dl
	add al,0x30
	mov ah,0x0e
	int 10h

	xor ax,ax
	ret

print_from_stack:
	mov ah,0eh
	pop cx
.loop:
	pop al
	cmp al,0
	je .done
	int 10h
	jmp .loop
.done:
	push cx
	ret

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s

.end:
	

	dw 0xAA55		        ; The standard PC boot signatureD