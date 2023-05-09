
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
	mov ax, 0x07c0
	mov ds, ax		; this should already be set, but better safe than sorry
    mov [drive_number],dl
    ;call _main
    call setup_VESA_VBE
    times 510-($-$$) db 0
    dw 0xaa55

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


global setup_VESA_VBE
setup_VESA_VBE:
    mov ax,0x07c0
    mov es,ax   ; set es to boot sector offset
    mov ax,0x4f00
    mov di,VBE_controller_info
    int 0x10
    cmp ax,0x004f
    jne .VESA_VBE_failed
    xor di,di
    mov si,[VBE_controller_info.video_modes_ptr]
.find_end_loop:
    mov cx,[si]
    cmp cx,0xffff
    je .loop
    add si,2
    jmp .find_end_loop
.loop:
    sub si,2
    cmp si,VBE_controller_info.video_modes_ptr
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
    mov ax,[VBE_mode_info.mem_base_ptr]
    mov word [screen_buff_ptr],ax
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
    .extra_data: times 512-($-VBE_controller_info) db 0
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
global screen_buff_ptr
screen_buff_ptr dd 0


get_mem_map:
.loop:
.end:
    ret
global mem_map
mem_map:
    times 256 db 0


read_acpi_tables:
    

global drive_number
drive_number: db 0
extern _main
bootloader_end:
    times 0x8400 - ($$-$) db 0 

