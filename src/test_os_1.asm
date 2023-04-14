	BITS 16
start:

	cli
	xor ax, ax
	mov es, ax
	mov ss, ax	; intialize stack to 0x0000:0x7C00
			    ; (directly below bootloader)
	sti

	mov ax, 0x07c0
	mov ds, ax		; this should already be set, but better safe than sorry


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

	mov si, folder_to_create
	call write_to_file_path_buffer

	call create_folder
	jne .sad

	mov ax,0x0e61	; it worked!
	int 0x10

	mov si, file_to_create
	call write_to_file_path_buffer

	call create_file
	jne .sad
	mov ax,0x0e61
	int 0x10

	call get_file
	jne .sad
	mov ax,0x0e61
	int 0x10

	jmp .end

.sad:
	mov ax,0x0e62
	int 0x10

.end:
	call hang


#include "utils/print_utils.asm"


disk db 0x00

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature


#include "create_folder.asm"

#include "compare_paths.asm"
#include "get_file.asm"
#include "utils/utils.asm"
#include "create_file.asm"


file_path_buffer_offset dw 0x6400	; max length 512 bytes (up to 0x0800)
file_system_start dw 0x1000			; segment the file system starts at

file_to_find: db "testfile.txt",0
folder_to_create: db "testfolder",0
file_to_create: db "testfolder/testfile.txt",0

corrupt_file_sys: db 'ERR: file system corrupted!',0

compare_paths_exception: db 'ERR: compare paths exception! (malformed path probably)',0

out_of_space_error: db 'ERR: out of memory pages!',0

file_name_error: db 'ERR: a file or folder with that name already exists!',0

exception:
	lodsb
	cmp al,0
	je .end
	mov ah,0x0e
	int 0x10
	jmp exception
.end:
	call hang


hang:
	cli	; disable interrupts
	hlt	; halt the processor


memory_usage_table:

	db 0x01					; first bit set if segment taken, calculate segment by offset from start of table * 0x0800
	db 0x01


	times 0x8000+0x400-($-$$) db 0

file_system:
	dw 0xf11f			; magic number to indicate fs table

	;db 0x01			; declares next path as a folder type		
	;db 'system',0
	;dw 0x0000			; segment

	db 0x02				; declares a file type
	db 'testfile.txt',0
	dw 0x0020			; segment_offset, modify es by the segment_offset

	db 0xff				; unset lowest bit if this isnt the end of the table (0xfe)
	dw 0x0000			; segment where the file/folder declerations continue in memory

	times 0x80180+0x400-($-$$) db 0

	db 0x01
	db 0x01
	db 0x01


	times 0x80200+0x400-($-$$) db 0

	dw 0x1ff1			; magic number to indicate a file
	db 'testfile.txt',0	; file name (obviously)
	dw 0x1000			; segment of parent folder
	dw 0x01				; number of 0x100 byte chunks file takes up
	db 0xff				; if the file is extended or not, 0xfe if it is
	dw 0x0000			; parent folder segment offset of where it continues if it does

