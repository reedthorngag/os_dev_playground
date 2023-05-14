
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
	mov ax, 0x0000
	mov ds, ax		; this should already be set, but better safe than sorry
    mov [drive_number],dl
    call read_lba_blocks
    call setup_VESA_VBE
    call drop_into_long_mode
    cli
    hlt

hex_characters: db '0123456789abcdef'
; number to print in bx
; preserves all registers
print_hex:
	push ax
	push bx
	push dx
	mov ax,bx
	mov bx,0x1000
	xor dx,dx	; this is necessery for some reason (div instruction dies without it)
.hex_print_loop:
	div bx		; divide ax by bx, quotent in ax, remainder in dx
	push bx
	mov bx,ax
	mov al,[hex_characters+bx]
	mov bh,0
	mov ah,0x0e
	int 0x10
	pop ax
	push dx
	xor dx,dx
	mov bx,0x10
	div bx
	mov bx,ax
	pop ax
	cmp bx,0x00
	jne .hex_print_loop
.end:
	mov bh,0
	mov ax,0x0e20
	int 0x10		; add a space at the end for nice output
	pop dx
	pop bx
	pop ax
	ret
hang:
    cli
    hlt
print_str:
    mov ah,0x0e
.loop:
    lodsb
    cmp al,0
    je .end
    int 0x10
    jmp .loop
.end:
    ret


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

    times 510-($-$$) db 0
    dw 0xaa55
bootloader_end:

drop_into_long_mode:
    ; activate A20
    mov ax,0x2403
    int 0x15
    mov eax,0x80000000
    cpuid
    cmp eax,0x80000001
    jb .no_long_mode    ; extended functions not available
    mov eax,0x80000001
    cpuid
    test edx,1<<29
    jz .no_long_mode    ; long mode not available
    jmp .long_mode
.no_long_mode:
    cli
    hlt
.long_mode:
    ; setup page tables stuff
    mov edi,0x1000
    mov cr3,edi
    xor eax,eax
    mov ecx,0x1000
    rep stosd
    mov edi,cr3
    mov dword [edi],0x2003
    add edi,0x1000
    mov dword [edi],0x3003
    add edi,0x1000
    mov dword [edi],0x4003
    add edi,0x1000
    mov eax,0x00000003
    mov ecx,0x200
.add_entry:
    mov dword [edi],eax
    add eax,0x1000
    add edi,8
    loop .add_entry
    mov eax,cr4
    or eax,1<<5
    mov cr4,eax
    mov ecx,0xc0000080
    rdmsr
    or eax,1<<8
    wrmsr
    cli
    lgdt [GDT.desc]
    mov eax,cr0
    or eax,(1<<31) | (1<<0)
    mov cr0,eax
    jmp GDT.code:long_mode_start

[BITS 64]
extern kernel_start
long_mode_start:
    mov ax,GDT.data
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    jmp kernel_start
    xor eax,eax
    mov eax,kernel_start
    jmp $
    cli
    hlt
[BITS 16]

; Access bits
PRESENT  equ 1 << 7
NOT_SYS  equ 1 << 4
EXEC     equ 1 << 3
DC       equ 1 << 2
RW       equ 1 << 1
ACCESSED equ 1 << 0
 
; Flags bits
GRAN_4K    equ 1 << 7
SZ_32      equ 1 << 6
LONG_MODE  equ 1 << 5
GDT:
    .null: equ $ - GDT
        dq 0
    .code: equ $ - GDT
        dd 0xFFFF                                   ; Limit
        db 0                                        ; Base
        db PRESENT | NOT_SYS | EXEC | RW            ; Access
        db GRAN_4K | LONG_MODE | 0xF                ; Flags & Limit (high, bits 16-19)
        db 0                                        ; Base (high, bits 24-31)
    .data: equ $ - GDT
        dd 0xFFFF                                   ; Limit & Base (low, bits 0-15)
        db 0                                        ; Base (mid, bits 16-23)
        db PRESENT | NOT_SYS | RW                   ; Access
        db GRAN_4K | SZ_32 | 0xF                    ; Flags & Limit (high, bits 16-19)
        db 0                                        ; Base (high, bits 24-31)
    .TSS: equ $ - GDT
        dd 0x00000068
        dd 0x00CF8900
    .desc:
        dw $ - GDT - 1
        dq GDT


global setup_VESA_VBE
setup_VESA_VBE:
    xor ax,ax
    mov es,ax
    mov ax,0x4f00
    mov di,VBE_controller_info
    int 0x10
    cmp ax,0x004f
    jne .VESA_VBE_failed
    mov si,[VBE_controller_info.video_modes_ptr]
.find_end_loop:
    mov cx,[si]
    cmp cx,0xffff
    je .loop
    add si,2
    jmp .find_end_loop
.loop:
    sub si,2
    cmp si,[VBE_controller_info.video_modes_ptr]
    je .no_supported_modes
    mov cx,[si]
    mov di,VBE_mode_info
    mov ax,0x4f01
    int 0x10
    cmp byte [VBE_mode_info.bits_per_pixel],0x0f
    jne .loop
    mov al,[VBE_mode_info.attributes]
    and al,0x10
    jz .loop
    mov bx,cx
    mov ax,0x4f02
    int 0x10
    cmp ah,0
    jne .loop
.end:
    mov ax,[VBE_mode_info.x_res]
    mov word [screen_res_x],ax
    mov ax,[VBE_mode_info.y_res]
    mov word [screen_res_y],ax
    mov eax,[VBE_mode_info.mem_base_ptr]
    mov dword [screen_buffer_ptr],eax
    xor eax,eax
    mov ax,[VBE_mode_info.win_mem]
    shl eax,10
    mov dword [screen_buffer_size],eax
    mov bx,ax
    call print_hex
    
    ;call hang
    ret
.no_supported_modes:
    mov si,VBE_errors.no_supported_modes
    call print_str
    call hang
.VESA_VBE_failed:
    mov si,VBE_errors.controller_info_failed
    call print_str
    mov bx,ax
    call print_hex
    call hang
VBE_errors:
    .controller_info_failed db 'ERR: failed to get VESA VBA controller info! error data: ',0
    .no_supported_modes db 'ERR: no supported video modes!',0
VBE_controller_info:
    .signature      db 'VESA'
    .version        dw 0x0200
    .OEM_str_ptr    dd 0
    .capabilities   dd 0
    .video_modes_ptr dd 0
    .total_mem      dw 0 ; num of 64Kib blocks
    dw 0xffff
    .extra_data: times 0x200-($-VBE_controller_info) db 0
current_VBE_mode dw 0
VBE_mode_info:
    .attributes:        dw 0
    .win_A_attributes   db 0
    .win_B_attributes   db 0
    .granularity        dw 0    ; KB
    .win_mem            dw 0    ; KB
    .start_seg_win_A    dw 0    ; 0 if unsupported
    .start_seg_win_B    dw 0    ; 0 if unsupported
    .win_func_ptr       dd 0    ; not quite sure what this is, something to do with int 10h/ax 4f05h?
    .bytes_per_scanline dw 0
    
    .x_res              dw 0
    .y_res              dw 0
    .char_cell_width    db 0
    .char_cell_height   db 0
    .num_planes         db 0    ; number of memory planes
    .bits_per_pixel     db 0
    .num_banks          db 0    ; number of banks
    .memory_model_type  db 0    ; http://www.ctyme.com/intr/rb-0274.htm#Table82
    .bank_size          db 0    ; size of bank in KB
    .num_image_pages    db 0    ; zero based number of image pages that will fit in video ram
                        db 0    ; reserved
    .red_mask_size      db 0
    .red_field_pos      db 0
    .green_mask_size    db 0
    .green_field_pos    db 0
    .blue_mask_size     db 0
    .blue_field_pos     db 0
    .reserved_mask_size db 0
    .reserved_mask_pos  db 0
    .direct_color_info  db 0    ; direct color mode info
    .mem_base_ptr       dd 0    ; address of video buffer
    .off_scrn_mem_ptr   dd 0    ; address of off screen memory
    .off_scrn_mem_size  dw 0    ; size of off screen memory in KB
global screen_res_x
screen_res_x dw 0
global screen_res_y
screen_res_y dw 0
global screen_buffer_ptr
screen_buffer_ptr dd 0
global virtual_scrn_buf_ptr
virtual_scrn_buf_ptr dd 0
global screen_buffer_size
screen_buffer_size dd 0


get_mem_map:
.loop:
.end:
    ret
global mem_map
mem_map:
    times 0x100 db 0


read_acpi_tables:
    

global drive_number
drive_number: db 0
extern main

