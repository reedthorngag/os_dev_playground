
get_mem_map:

    xor ax,ax
    mov es,ax
    mov di, mem_map_buffer
    xor ebx,ebx
    xor bp,bp

.loop:
    mov edx, 0x0534D4150
    mov eax, 0xE820
    mov ecx,24
    mov dword [es:di+20],1

    int 0x15

    jc .end
    cmp eax,'PAMS'
    jne .error
    jcxz .loop
    cmp cl,24
    jb .loop

    mov ecx, [es:di+8]
    or ecx, [es:di+12]
    je .loop

    inc bp
    add di,24
    cmp di, mem_map_buffer_end
    jge .out_of_space_err

.end:
    mov word [mem_map_size],bp
    mov bx,di
    call print_hex
    mov bx,mem_map_buffer
    call print_hex
    call pause
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
