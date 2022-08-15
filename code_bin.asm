	BITS 16

start:
	mov ax, 07C0h		; Set up 4K stack space after this bootloader
	add ax, 288		    ; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096

	mov ax, 07C0h		; Set data segment to where we're loaded
	mov ds, ax


	xor edx,edx
	mov edx, 0x100000

	
.reset:
	xor ecx,ecx

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

print_from_stack:
	mov ah,0eh
	pop cx
.loop:
	pop bx
	cmp bx,0000h
	je .done
	mov al,bl
	int 10h
	mov al,bh
	int 10h
	jmp .loop
.done:
	push cx
	ret

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s

.end:
	

	dw 0xAA55		        ; The standard PC boot signatureD