	BITS 16
start:

	xor ebx,ebx
	mov bl, 0xff
	call print_decimal

;text_string db 'hello!', 0

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


	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s

.end:
	

	dw 0xAA55		        ; The standard PC boot signatureD