OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    . = ALIGN(0x8000);

    .out :
    {
        bin/kernel.o
        *(.kernel)
    }

    . = ALIGN(0x10000);

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