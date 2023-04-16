    BITS 16
start:
    xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax	# intialize stack to 0x0000:0x7C00
			    # (directly below bootloader)

	mov [disk], dl	

	mov ax, 0x0241		# ah = 0x02 (read sector function of int 0x13), al = 65 (read 65 sectors)
				# sector count could theoretically be 255, but 65 is the max that can be read
				# without crossing a segment boundary
				# 65 sectors is roughly 33k of disk space, so make sure you have disk drivers
				# up and running before your kernel binary grows beyond this size, else
				# some data will not be loaded
	mov bx, 0x7E00		# es:bx = memory location to copy data into, es already zeroed
	mov cx, 0x0002		# ch = 0x00 (track idx), cl = 0x02 (sector idx to start reading from)
	xor dh, dh		# dh = 0x00 (head idx), dl = drive number (implicitly placed in dl by BIOS on startup)
	int 0x13		# copy data

    

disk: byte 0x00



    times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature