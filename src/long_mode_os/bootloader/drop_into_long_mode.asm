
drop_into_long_mode:

    mov eax,0x80000000
    cpuid
    cmp eax,0x80000001
    jb .no_long_mode    




    
.no_long_mode:
    cli
    hlt
