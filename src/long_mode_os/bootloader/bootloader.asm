    [BITS 16]
section .boot

global start
start:

    cli
	xor ax, ax
	mov es, ax
	mov ss, ax	; intialize stack to 0x0000:0x7C00
			    ; (directly below bootloader)
	sti

	xor ax,ax
	mov ds, ax		; this should already be set, but better safe than sorry

    mov [drive_number],dl

    mov si,disk_address_packet
    call read_lba_blocks

    call print_hex
    call hang
    call get_mem_map

    mov ax,0x08e0
    mov es,ax
    mov ax,0x1000
    mov si,ax

    mov bx, [es:si]
    mov bx, second_stage_start
    call print_hex
    call pause

    call setup_VESA_VBE

    jmp drop_into_long_mode

#include "utils.asm"
#include "lba_interface.asm"

    times 510-($-$$) db 0
    dw 0xaa55
bootloader_end:
#include "drop_into_long_mode.asm"

#include "setup_VESA_VBE.asm"
#include "get_mem_map.asm"
#include "read_acpi_tables.asm"

#include "shared_data.asm"

second_stage_start:
