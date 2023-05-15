[BITS 64]
extern kernel_start

long_mode_start:

    mov ax,GDT.data
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax

    call kernel_start

    jmp $

    cli
    hlt

[BITS 16]
