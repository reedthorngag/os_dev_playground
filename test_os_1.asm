	BITS 16
start:

	mov ax, 0x06c0		; set up 4k stack space below the bootloader (0x7c00 - 0x6c00 = 0x1000 = 4096)
	mov ss, ax
	mov sp, 4096		; point stack pointer to top of stack space

	mov ax, 0x07c0		; Set data segment to where we're loaded (unrelated from stack, this isnt the base pointer)
	mov ds, ax

	; -------------------------- file read/write testing stuff ---------------------------------

	mov ah,0x02		; set operation type
	mov dl,0x00		; drive num
	mov dh,0x0		; head num/platter num
	mov ch,0x0		; cylinder
	mov cl,0x1		; sector
	mov al,0x1		; number of sectors to read
	
	mov bx,0x7e00
	mov es,bx		; where in memory to write it to
	int 0x13

	jnz .error

	;jmp bx
	mov ax,[bx]
	mov bx,ax
	call print_hex
	ret

.error:
	mov bx,error_text
	mov ah,0x0e
.error_loop:
	mov al,[0x7c00+bx]
	cmp al,0
	je .end
	int 0x10
	add bx,1
	jmp .error_loop
.end:
	ret


error_text db 'error!',0

hex_characters db '0123456789abcdef'

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

; ------------------------- end ---------------------------------------

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature

	times 256 db 0x22

	dw 0x4444

	;mov al,0x61
	;mov ah,0x0e
	;int 0x10

	;jmp $
