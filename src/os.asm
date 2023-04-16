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


	call command_line
	; nothing after this should run

	mov si,how_tf
	call exception

; load exception error message into ds:si
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

#include "file_system/create_folder.asm"
#include "file_system/get_file.asm"


disk db 0x00

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		        ; The standard PC boot signature


#include "utils/utils.asm"
#include "utils/print_utils.asm"

#include "command_line/command_line.asm"

#include "file_system/create_file.asm"
#include "file_system/utils/utils.asm"


file_system_start dw 0x1000		; segment the file system starts at

compare_paths_exception: db 'ERR: compare paths exception! (malformed path probably)',0
corrupt_file_sys: db 'ERR: file system corrupted!',0
file_name_error: db 'ERR: a file or folder with that name already exists!',0
out_of_space_error: db 'ERR: out of memory pages!',0
how_tf: db 'ERR: how tf u manage this?',0


file_path_buffer: times 0x200 db 0x00


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
	dw 0x0200			; file offset from folder (max 0x7f00 as 0x8000 is next folder)

	db 0xff				; unset lowest bit if this isnt the end of the table (0xfe)
	dw 0x0000			; segment where the file/folder declerations continue in memory

	times 0x8180+0x400-($-$$) db 0

	db 0x01
	db 0x01
	db 0x01


	times 0x8200+0x400-($-$$) db 0

	dw 0x1ff1			; magic number to indicate a file
	db 'testfile.txt',0	; file name (obviously)
	dw 0x1000			; segment of parent folder
	dw 0x01				; number of 0x100 byte chunks file takes up
	db 0xff				; if the file is extended or not, 0xfe if it is
	dw 0x0000			; parent folder file offset of where it continues if it does

