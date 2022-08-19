	BITS 16
start:

	cli
	xor ax,ax
	mov ss,ax
	mov sp,0x7c00
	sti

	xor ax,ax
	int 0x13

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	mov ah,0x02		; set operation type
	mov dl,0x00		; drive num
	mov dh,0x0		; head num/platter num
	mov ch,0x0		; cylinder
	mov cl,0x2		; sector
	mov al,0x1		; number of sectors to read
	
	mov bx,0x500
	mov es,bx		; where in memory to write it to
	mov bx,0
	int 0x13

	push ax

	xor bx,bx
	mov bx,0x5000

	; b0 61
	; b4 0e
	; cd 10

	mov dword [bx],0xb061b404
	add bx,0x4
	mov dword [bx],0xcd10ebfe

	sub bx,0x4

	jmp 0x5000

	mov bl,[bx]
	call print_decimal

	pop ax

	mov bl,al
	call print_decimal

	mov bl,ah
	call print_decimal

	jmp 0x50:0

	mov bl, 0xff
	call print_decimal

	jmp $
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
	add al,0x30
	mov ah,0x0e
	int 10h

	xor eax,eax
	ret

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature

	dw 0xffff

	mov al,0x61
	mov ah,0x0e
	int 0x10

	jmp $
