    BITS 16
start:

    mov si, 0x0100
	mov word  [si+0], 0x10		; packet size
	mov word  [si+1], 0x00		; always 0
	mov dword [si+2], 0x0001	; num of sectors to transfer
	mov dword [si+4], 0x0010	; transfer buffer, 16 bit offset
	mov dword [si+6], 0x0010	; transfer buffer, 16 bit segment
	mov dword [si+8], 0x0000	; lower 16 bits of starting LBA
	mov dword [si+10],0x0000	; middle 16 bits of starting LBA
	mov dword [si+12],0x0000	; upper 16 bits of starting LBA
	mov dword [si+14],0x0000	; insurance

	mov ax,0x4200
	mov dl,0xe0
	mov bx,disk_address_packet
	add bx,0x7c00
	mov si,bx
	int 0x13		; es:si contain pointer to packet
	
	mov bx,ax
	call print_hex

	mov ax,0x0010
	mov es,ax
	mov si,ax
	mov bx,[es:si+0x100]
	call print_hex



	jmp .skip_for_now
	mov byte [disk], dl
	mov dl,0x80
	mov ax, 0x0201		; ah = 0x02 (read sector function of int 0x13), al = 1 (read 1 sectors)
						; sector count could theoretically be 255, but 65 is the max that can be read
						; without crossing a segment boundary
						; 65 sectors is roughly 33k of disk space, so make sure you have disk drivers
						; up and running before your kernel binary grows beyond this size, else
						; some data will not be loaded
	mov bx, 0x8000		; es:bx = memory location to copy data into, es already zeroed
	mov cx, 0x0002		; ch = 0x00 (track idx), cl = 0x02 (sector idx to start reading from)
	xor dh, dh		; dh = 0x00 (head idx), dl = drive number (implicitly placed in dl by BIOS on startup)
	int 0x13		; copy data

	mov al,0x01
	mov bh,ah
	cmovc bx, ax
	call print_hex
.skip_for_now:


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


;	file reading info packet
disk_address_packet:
	db 0x10
	db 0x00
.number_of_sectors:
	dw 0x0001
.transfer_buffer_offset:
	dw 0x0000
.transfer_buffer_segment:
	dw 0x0000
.LBA_address:
	dw 0x0000
	dw 0x0000
	dw 0x0000

;	file writing info packet
result_buffer:
	db 0x001e



error_text db 'error!',0