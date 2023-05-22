[BITS 64]
extern kernel_start

long_mode_start:

    mov ax,GDT.data
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax

    ;jmp $

    jmp kernel_start

[BITS 16]
