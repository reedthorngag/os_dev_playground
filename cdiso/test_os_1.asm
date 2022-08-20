	BITS 16
start:

	cli
	xor ax,ax
	mov ss,ax
	mov sp,0x7c00
	sti

	mov ax,0xffff
	call print_hex
	ret

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

	mov dword [bx],0xb061b404
	;add bx,0x4
	mov dword [bx],0xcd10ebfe

	;sub bx,0x1

	mov bx,0x5000

	mov ax,[bx]
	call print_decimal

	mov bx,0x5000

	jmp bx

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

hex_characters db 0xff,0x12,0x34,0x56,0x78,0x9a,0xbc,0xde,0xff

print_hex:

	mov bx,hex_characters
	mov bl,[hex_characters]
	call print_decimal
	ret

	; ax contains number to output
	xor dx,dx
	xor cx,cx
	xor bx,bx

	mov bx,0x1000
	
.hex_print_loop:

	div bx		; divide ax by bx, quotent in ax, remainder in dx
	mov bx,hex_characters
	add bx,ax
	mov bl,[bx]
	mov ah,0x0e
	int 0x10

	push dx
	mov ax,bx
	mov bx,0x10
	div bx
	mov bx,ax
	pop ax
	cmp bx,1
	jne .hex_print_loop
.end:
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

; -----------------------------

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature

	dw 0xffff

	mov al,0x61
	mov ah,0x0e
	int 0x10

	jmp $
