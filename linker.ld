OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    .out :
    {
        kernel.o
        *(.out)
    }

    .resources :
    {
        *(.resources)
        font.o
    }

    .data :
    {
        *(.rodata)
        *(.data)
    }
}