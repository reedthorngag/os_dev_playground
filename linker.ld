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
        font.o
        *(.resources)
    }

    .data :
    {
        *(.rodata)
        *(.data)
    }
}