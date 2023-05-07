    [BITS 16]
section .boot

start:

    cli
	xor ax, ax
	mov es, ax
	mov ss, ax	; intialize stack to 0x0000:0x7C00
			    ; (directly below bootloader)
	sti

	mov ax, 0x07c0
	mov ds, ax		; this should already be set, but better safe than sorry


    mov [drive_number],dl

    call setup_VESA_VBE



    times 510-($-$$) db 0
    dw 0xaa55

data_to_load_start:

#include "utils.asm"

#include "setup_VESA_VBE.asm"



global drive_number
drive_number: db 0

data_to_load_end:
