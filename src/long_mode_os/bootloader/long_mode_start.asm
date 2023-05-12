[BITS 64]
extern map_screen_buffer_ptr

long_mode_start:

    mov ax,GDT.data
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax

    call map_screen_buffer_ptr

    jmp $

    mov edi,[virtual_scrn_buf_ptr]
    mov ecx,[screen_buffer_size]
    shr ecx,2
    mov ax,0xffff
    rep stosw

    jmp $

    cli
    hlt


[BITS 16]
