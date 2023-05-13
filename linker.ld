OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    .out :
    {
        bin/\*.o
        *(.out)
    }

    .resources :
    {
        *(.resources)
    }

    .data :
    {
        *(.rodata)
        *(.data)
    }
}