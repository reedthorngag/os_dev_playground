
long_mode_start:

    mov ds,[GDT.data]

    mov di,[screen_buff_ptr]
    mov ecx,0x500
    mov ax,0b0_11111_00000_00000
    
    rep stosw



