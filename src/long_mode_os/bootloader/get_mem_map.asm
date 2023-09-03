
get_mem_map:

    xor ax,ax
    mov es,ax
    mov di, mem_map_buffer

    mov eax, 0x0000E820
    mov edx, 0x534D4150
    xor ebx,ebx
    mov ecx, 0x14

.loop:

    int 0x15
    jc .end ; error or finished
    cmp ebx,0
    jnz .loop

.end:
    mov bx,ax
    call print_hex
    ret



