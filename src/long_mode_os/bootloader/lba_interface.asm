
; buffer in es:di
; number of sectors in cx
; drive number in dl
; lba sector in bx
read_lba_blocks:





; lba disk address packet
disk_address_packet:
	db 0x10
	db 0x00
.number_of_sectors:
	db 0x0001
.transfer_buffer_offset:
	db 0x0000
.transfer_buffer_segment:
	db 0x0000
.LBA_address:
	db 0x0000
	db 0x0000
	db 0x0000

