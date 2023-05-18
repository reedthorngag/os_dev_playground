OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    . = 0x10000;

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