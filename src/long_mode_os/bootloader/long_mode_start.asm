[BITS 64]
long_mode_start:

    jmp $

    ;mov ds,[GDT.data]

    mov edi,[screen_buffer_ptr]
    mov ecx,[screen_buffer_size]
    shr ecx,1
    mov ax,0xffff
    
    rep stosw

    cli
    hlt



