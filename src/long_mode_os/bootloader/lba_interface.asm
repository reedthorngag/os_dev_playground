
; buffer in es:di
; number of sectors in cx
; drive number in dl
; lba sector in bx
read_lba_blocks:

	mov dl,[drive_number]
	mov ah,0x42
	mov si,disk_address_packet
	int 0x13
	jc .failed

    mov bx,[disk_address_packet.number_of_blocks]
    call print_hex

	ret

.failed:
	mov bx,ax
	call print_hex
	call hang



; lba disk address packet
disk_address_packet:
	db 0x10
	db 0x00
.number_of_blocks:
	dw 0x0010
.transfer_buffer_offset:
	dw 0x7e00
.transfer_buffer_segment:
	dw 0x0000
.LBA_address:
	dq 1
	dq 0

