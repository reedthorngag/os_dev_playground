OUTPUT_FORMAT(binary)
ENTRY(asm)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    .data :
    {
        *(.kernel)
    }

    . = 0x10000;

    .rodata :
    {
        *(.rodata)
    }

    .resources :
    {
        *(.data)
        *(.resources)
    }
}