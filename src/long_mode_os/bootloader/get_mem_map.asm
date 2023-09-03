
get_mem_map:

    xor ax,ax
    mov es,ax
    mov di, mem_map_buffer

    mov eax, 0x0000E820
    mov edx, 'SMAP'
    xor ebx,ebx
    mov ecx, 0x14

.loop:
    int 0x15
    jc .end
    cmp eax,'PAMS'
    jne .error
    cmp ebx,0
    jz .end
    add di,cx
    cmp di, mem_map_buffer_end
    jge .out_of_space_err

.end:
    cmp ah,0x86
    jne .error
    ret

.error:
    mov si, .gmm_err_str
    call print_str
    mov bx,ax
    shr bx,8
    call print_hex
    call hang

.out_of_space_err:
    mov si, .out_of_space_err_str
    call print_str
    call hang


.gmm_err_str: db 'get mem map err, code: ',0
.out_of_space_err_str: db 'ran out of space to read mem map into!',0
